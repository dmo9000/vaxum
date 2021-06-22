%{
  #include <cstdio>
  #include <iostream>
  #include <string.h>
  #include "util.h"

  using namespace std;

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  extern int line_num;
 
  void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  Initially (by default), yystype
// is merely a typedef of "int", but for non-trivial projects, tokens could
// be of any arbitrary data type.  So, to deal with that, the idea is to
// override yystype's default typedef to be a C union instead.  Unions can
// hold all of the types of tokens that Flex could return, and this this means
// we can return ints or floats or strings cleanly.  Bison implements this
// mechanism with the %union directive:
%union {
  int ival;
  float fval;
  char *sval;
}

// define the constant-string tokens:
%token SNAZZLE TYPE
%token END ENDL

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the %union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

%%

// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "vaxum file":
vaxum:
  template body_section {
      cout << "<***> " << (line_num-1) << " lines read" << endl;
    }
  ;
template:
  typelines
  ;
typelines:
  typelines typeline
  | typeline
  ;
typeline:
  TYPE STRING ENDLS {
      cout << "new defined vaxum type: " << $2 << endl;
      free($2);
    }
  ;
body_section:
  body_lines
  ;
body_lines:
  body_lines body_line
  | body_line
  ;
body_line:
  INT INT INT INT STRING ENDL {
      cout << "new vaxum: " << $1 << $2 << $3 << $4 << $5 << endl;
      free($5);
    }
  ;
ENDLS:
     ENDLS ENDL
     | ENDL ;
  ;

%%

FILE *myfile = NULL;

const char *input_filename = NULL;

int main(int argc, char *argv[1]) {
  // Open a file handle to a particular file:
  myfile = fopen(argv[1], "r");
  // Make sure it is valid:

  if (argc > 1) {
	  if (!myfile) {
	    cout << "I can't open " << argv[1] << " file!" << endl;
	    return -1;
	  }
	  // Set Flex to read from it instead of defaulting to STDIN:
	  yyin = myfile;
	  int fnlen = 3 + strlen(argv[1]);
	  input_filename = (const char *) malloc(fnlen);
	  snprintf((char *) input_filename, fnlen, "'%s'", argv[1]);
	} else {
	  yyin = stdin;
	  input_filename = (const char *) "<stdin>";
	}
  
  // Parse through the input:
  yyparse();
  
}

void yyerror(const char *s) {
  cout << "<-!-> parse error at file " << input_filename << " line " << line_num << ": " << s << endl;
  print_line_from_file(myfile, line_num);
  // might as well halt now:
  exit(-1);
}
