%{
  #include <cstdio>
  #include <iostream>
  #include <cassert>
  #include <string.h>
  #include "contexts.h"
  #include "util.h"

  using namespace std;
 
  #define INSERT_INDENT(nnn) insert_indent((scope+bscope)*nnn)

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  extern int line_num;
  extern char *yytext;
  extern int list_length;
  extern char **current_list; 

  int scope = 0;		/* 0 is "global" scope */
  int bscope = 0;
  ZIL_Context current_context;
 
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
  char *slval;
}

// define the constant-string tokens:
%token CR
%token LF
%token MYEOF
%token LT
%token GT
%token DIRECTIONS
%token GLOBAL
%token ZIL_FALSE
%token OBJECT 
%token ROOM
%token SYNONYM
%token DESC
%token FDESC
%token DESCFCN  
%token LDESC
%token TEXT
%token FLAGS
%token ACTION
%token ADJECTIVE
%token SIZE
%token VALUE
%token TVALUE
%token CAPACITY
%token STRENGTH
%token VTYPE
%token IN
%token LB
%token RB
%token COMMENT
%token ROUTINE
%token PARAMETER_LIST_EMPTY
%token COND
%token PREDICATE_VERB
%token GLOBAL_VAR_DEREF
%token RTRUE
%token RFALSE
%token MOVE_TO
%token IF
%token VERSION
%token SETG

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the %union:
%token <ival> INT
%token <fval> FLOAT
%token STRING
%type <sval> STRING
%token <slval> STRING_LITERAL
%type <sval> PARAMETER_LIST_EMPTY
%type <sval> GLOBAL_VAR_DEREF
%%

// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "vaxum file":

vaxum: end_of_file
        | input_lines end_of_file
       {
      cout << "<***> " << (line_num-1) << " lines read" << endl;
      /* parsing complete, exit */
      exit(0);
    }
  ;

end_of_file:
   MYEOF { 
	cout << "<EOF> " << (line_num-1) << " lines read" << endl;
	exit(1);
	}
  ;	

input_lines:
   input_line input_lines
   | input_line 
  ;


input_line:
  string_literal
  | version_decl
  | set_global_variable
  | declare_global_variable
  | global_variable_false
  | directions_list 
  | inclusion_decl
  | object_decl 
  | room_decl
  | text_decl
  | size_val
  | value_val
  | tvalue_val
  | capacity_val
  | strength_val
  | synonyms_list
  | adjective_list
  | flags_list
  | desc_decl
  | fdesc_decl
  | desc_func_decl
  | ldesc_decl
  | action_func_decl
  | vtype_decl
  | routine_decl
  | conditional
  | verb_predicate
  | move_to_unconditional
  | move_to_conditional
  | moveinto_conditional
  | cant_move_custom_text
  | call_routine
  | room_local_globals
  | return_true
  | return_false
  | less_than
  | greater_than
  | left_bracket
  | right_bracket
  | CR
  | LF
  ;



set_global_variable:
  SETG STRING INT {
      INSERT_INDENT(2);
      cout << "SETG " << $2 << " " << $3 << endl;
      assert(current_context == CONTEXT_GLOBAL);
  }
  ;

version_decl:
  VERSION STRING {
      INSERT_INDENT(2);
      cout << "VERSION " << $2 << endl;
      assert(current_context == CONTEXT_GLOBAL);
    }
  ;

return_true:
  RTRUE {
        INSERT_INDENT(2);
        cout << "<RETURN TRUE (RTRUE)>" << endl;
  }
;

return_false:
  RFALSE {
        INSERT_INDENT(2);
        cout << "<RETURN FALSE (RFALSE)>" << endl;
  }
;



verb_predicate:
  PREDICATE_VERB STRING {
      /* check whether the PRSA is set to a particular VERB */
      INSERT_INDENT(2);
      cout << "VERB? " << $2 << endl;
  }
;

conditional:
  COND {
      INSERT_INDENT(2);
      cout << "COND " << endl;
  }
  ;

routine_decl:
  ROUTINE STRING PARAMETER_LIST_EMPTY {
            INSERT_INDENT(2);
            cout << "ROUTINE " << $2 << " ()" << endl;
            assert (current_context == CONTEXT_GLOBAL);
            current_context = CONTEXT_ROUTINE_DEFN;
      }
  ;

size_val: 
	SIZE INT {
                INSERT_INDENT(2);
                cout << "SIZE :=" << $2 << endl;
		}
    ;

value_val: 
	VALUE INT {
                INSERT_INDENT(2);
                cout << "VALUE :=" << $2 << endl;
		}
    ;

tvalue_val: 
	TVALUE INT {
                INSERT_INDENT(2);
                cout << "TVALUE :=" << $2 << endl;
		}
    ;    

capacity_val: 
	CAPACITY INT {
                INSERT_INDENT(2);
                cout << "CAPACITY :=" << $2 << endl;
		}
    ;        


strength_val: 
	STRENGTH INT {
                INSERT_INDENT(2);
                cout << "STRENGTH :=" << $2 << endl;
		}
    ;       

action_func_decl:
        ACTION STRING {
                INSERT_INDENT(2);
                cout << "ACTION " << $2 << endl;
                }
        ;

desc_func_decl:
        DESCFCN STRING {
                INSERT_INDENT(2);
                cout << "DESCFCN " << $2 << endl;
                }
        ;

vtype_decl:
  VTYPE INT
  | VTYPE STRING {
    INSERT_INDENT(2);
    cout << "VTYPE " << $2 << endl;
  }
  ;

desc_decl:
	DESC STRING_LITERAL {
		INSERT_INDENT(2);
		cout << "DESC " << $2 << endl;
		}
	;

fdesc_decl:
	FDESC STRING_LITERAL {
		INSERT_INDENT(2);
		cout << "FDESC " << $2 << endl;
		}
	;

ldesc_decl:
	LDESC STRING_LITERAL {
		INSERT_INDENT(2);
		cout << "LDESC " << $2 << endl;
		}
	;

text_decl:
	TEXT STRING_LITERAL {
		INSERT_INDENT(2);
		cout << "TEXT " << $2 << endl;
		}
	;


inclusion_decl:
	IN STRING {
		INSERT_INDENT(2);
		cout << "IN " << $2 << endl;
		}
	;

object_decl:
	OBJECT STRING {
	INSERT_INDENT(2);
	cout << "OBJECT " << $2 << endl;
  assert(current_context == CONTEXT_GLOBAL);
  current_context = CONTEXT_OBJECT_DEFN;
	}
;	

room_decl:
	ROOM STRING {
	INSERT_INDENT(2);
  cout << "ROOM " << $2 << endl;
  assert(current_context == CONTEXT_GLOBAL);
  current_context = CONTEXT_ROOM_DEFN;
	}
;	

declare_global_variable:
  GLOBAL STRING INT { 
	INSERT_INDENT(2);
	cout << "GLOBAL " << $2 << " := " << $3 << endl;
	}
;

global_variable_false:
  GLOBAL STRING ZIL_FALSE {
	INSERT_INDENT(2);
        cout << "GLOBAL " << $2 << " := " << "ZIL_FALSE" << endl;
        }
;

room_local_globals:
  GLOBAL list_of_strings {
	int ii = 0;
	INSERT_INDENT(2);
 	cout << "GLOBAL(ROOM_LOCAL_GLOBALS) := ";
  if (list_length != -1) {
	  for (ii = 0; ii < list_length; ii++) {
		  cout << current_list[ii] << " " ; 
		  }
 	  cout << "(" << list_length << ")" << endl;
	  current_list = NULL;
	  list_length = -1;
  } else {
    cout << "VERY CONFUSED in CONTEXT ";
    print_context(current_context);
    assert(current_context == CONTEXT_ROOM_DEFN);
    assert(NULL);
    }
  }
  ;


directions_list:
  DIRECTIONS list_of_strings {
	int ii = 0;
	INSERT_INDENT(2);
 	cout << "DIRECTIONS := ";
  assert(list_length != -1);
	for (ii = 0; ii < list_length; ii++) {
		cout << current_list[ii] << " " ; 
		}
 	cout << "(" << list_length << ")" << endl;
	current_list = NULL;
	list_length = -1;
	}
  ;

synonyms_list:
  SYNONYM list_of_strings {
        int ii = 0;
        INSERT_INDENT(2);
        cout << "SYNONYM := ";
        assert(list_length != -1);
        for (ii = 0; ii < list_length; ii++) {
                cout << current_list[ii] << " " ;
                }
        cout << "(" << list_length << ")" << endl;
        current_list = NULL;
        list_length = -1;
        }
  ;

flags_list:
  FLAGS list_of_strings {
        int ii = 0;
        INSERT_INDENT(2);
        cout << "FLAGS := ";
        assert(list_length != -1);
        for (ii = 0; ii < list_length; ii++) {
                cout << current_list[ii] << " " ;
                }
        cout << "(" << list_length << ")" << endl;
        current_list = NULL;
        list_length = -1;
        }
  ;

adjective_list:
  ADJECTIVE list_of_strings {
        int ii = 0;
        INSERT_INDENT(2);
        assert(list_length != -1);
        cout << "ADJECTIVE := ";
        for (ii = 0; ii < list_length; ii++) {
                cout << current_list[ii] << " " ;
                }
        cout << "(" << list_length << ")" << endl;
        current_list = NULL;
        list_length = -1;
        }
  ;

move_to_unconditional:
  STRING MOVE_TO STRING {
      INSERT_INDENT(2);
      /* unconditional move */
      cout << "MOVE_TO(" << $1 << ") TO " << $3 << endl;
      }
      ;

move_to_conditional:
  STRING MOVE_TO STRING IF STRING {
      INSERT_INDENT(2);
      /* unconditional move */
      cout << "MOVE_TO(" << $1 << ") TO " << $3 << " IF " << $5 << endl;
      }
      ;

 moveinto_conditional:
   IN MOVE_TO STRING IF STRING {
      INSERT_INDENT(2);
      /* unconditional move */
      cout << "MOVE_TO(IN)" << " TO " << $3 << " IF " << $5 << endl;
      }
      ;    

cant_move_custom_text:
  STRING STRING_LITERAL {
    INSERT_INDENT(2);
    /* can't move, custom text supplied */
    cout << "DIRECTION(" << $1 << "): " << $2 << endl;
  }
  ;


call_routine:
  STRING GLOBAL_VAR_DEREF {
      INSERT_INDENT(2);
      /* any otherwise unmatched string is presumed to be a call to a ROUTINE */
      cout << "-> " << $1 << " " << $2 << endl;
  }
  ;

list_of_strings:
    list_of_strings STRING 
    | STRING
	;

less_than:
	 LT { 
		//INSERT_INDENT(2);
		scope++ ;  //cout <<  "<LT scope=" << scope << ">" << endl; 
		}
	;

greater_than:
	 GT { 
		//INSERT_INDENT(2);
		scope-- ;  //cout <<  "<GT scope=" << scope << ">" << endl; 
    //assert(current_context != CONTEXT_GLOBAL);
    switch (current_context) {
        case CONTEXT_GLOBAL:
          /* nothing to do */
          break;
        case CONTEXT_OBJECT_DEFN:
          current_context = CONTEXT_GLOBAL;
          break;
        case CONTEXT_ROUTINE_DEFN:
          current_context = CONTEXT_GLOBAL;
          break;
        default:
          cout << "+++ Leaving invalid context!";
          print_context(current_context);
          assert(NULL);
          break;
      }
		}
	;

left_bracket:
	LB {
		//INSERT_INDENT(2);
		bscope++ ;  //cout <<  "<LB scope=" << bscope << ">" << endl; 
	   };

right_bracket:
	RB {
		//INSERT_INDENT(2);
		bscope-- ;  //cout <<  "<RB scope=" << bscope << ">" << endl; 
	   };

string_literal:
  STRING_LITERAL {
	INSERT_INDENT(2);
	cout << endl << "string_literal: [" << $1 << "]" << endl << endl;
	free ($1);
	}
  ;

%%

FILE *myfile = NULL;

const char *input_filename = NULL;

int main(int argc, char *argv[1]) {
  current_context = CONTEXT_GLOBAL;
  //yydebug = 1;
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
  int x = 0; 
  char *l = NULL;
  cout << "<-!-> parse error at file " << input_filename << " line " << line_num << ": " << s << endl;
  cout << "yytext: " << yytext << endl; 
  l = print_line_from_file(myfile, line_num);
  /* hex debugging 
  cout << endl << "Length: " << strlen(l) << endl;
  for (x =0 ; x < strlen(l); x++) {
	printf("[%02x]", l[x]);
	}
  printf("\n");
	*/
  exit(-1);
}
