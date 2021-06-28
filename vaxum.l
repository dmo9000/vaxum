vaxum.l
%{
  #include <cstdio>
  #include <cassert>
  #include <iostream>
  #include "util.h"
  using namespace std;

/*  #include "vaxum.tab.h"  // to get the token types from Bison */

#include "parser.h"

  YYSTYPE yylval;
  int line_num = 1;
  char *yylval_string_literal = NULL;
  char **current_list = NULL;
  int list_length = -1;
  extern char *my_yyfilename;

YY_BUFFER_STATE get_yy_current_buffer()
{

	return YY_CURRENT_BUFFER;
}

%}
%option noyywrap
%%
[ \t]		;
"<>"		{ return ZIL_FALSE; }
"<"		{ return LT; }
">"		{ return GT; }
"("		{ return LB; }
")"		{ return RB; }
\(\)  { return PARAMETER_LIST_EMPTY ; }
"\\"  { /* ESCAPE CHARACTER - NOT SURE WHAT TO DO */ }
\\\"  { return ESCAPED_QUOTE; }


;\"(\\.|[^"\\])*\" ;
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }

DIRECTIONS	{  assert(current_list == NULL);
               assert(list_length == -1);
               list_length = 0;
		           current_list = (char **) malloc((list_length+1) * sizeof(char *)); 
               current_list[0] = NULL; 
               return DIRECTIONS; 
               }
"GASSIGNED?"	  { return GASSIGNED_QUESTION; }
FDESC		  { return FDESC; }
LDESC		  { return LDESC; }
DESC		  { return DESC; }
GLOBAL	  { return GLOBAL; }
OBJECT	  { return OBJECT; }
ROOM	    { return ROOM; }
ACTION	  { return ACTION; }
SIZE		  { return SIZE; }
TVALUE    { return TVALUE; }
VALUE     { return VALUE; }
CAPACITY  { return CAPACITY; }
DESCFCN   { return DESCFCN; }
TEXT      { return TEXT; }
STRENGTH  { return STRENGTH; }
VTYPE     { return VTYPE; }
COND      { return COND; }
VERB\?    { return PREDICATE_VERB; }
ROUTINE   { return ROUTINE; }
TO        { return MOVE_TO; }
IF        { return IF; }
VERSION   { return VERSION; }
SET 	  { return SET; }
SETG      { return SETG; }
OR	  { return OR; }
\!    { return BANG; }
PRINC   { return PRINC; }
DEFMAC  { return DEFMAC; }
"INSERT-FILE" { return INSERT_FILE; }


FLAGS		{ assert(current_list == NULL);
          assert(list_length == -1);
          list_length = 0;
          current_list = (char **) malloc((list_length+1) * sizeof(char *));
          current_list[0] = NULL;
          return FLAGS;
          }

SYNONYM		{ assert(current_list == NULL); 
            assert(list_length ==-1);
            list_length = 0;
		        current_list = (char **) malloc((list_length+1) * sizeof(char *)); 
            current_list[0] = NULL; 
		        return SYNONYM; 
		}

ADJECTIVE         { 
                  assert(current_list == NULL);
                  assert(list_length == -1);
                  list_length = 0;
                  current_list = (char **) malloc((list_length+1) * sizeof(char *));
                  current_list[0] = NULL;
                  return ADJECTIVE;
                }


IN		{ yylval.sval = strdup(yytext); 
  		  if (list_length != -1) { 
			  current_list[list_length] = yylval.sval;
        list_length++;
        current_list =(char **) realloc(current_list, (list_length+1) * sizeof(char *));
        current_list[list_length] = NULL;
        return STRING;
			}
			return IN; }

[0-9]+          { yylval.ival = atoi(yytext); return INT; }

\<RTRUE\>      { return RTRUE; } 
\<RFALSE\>      { return RFALSE; } 


[#A-Za-z0-9-]+"?"	{ yylval.sval = strdup(yytext); return QUESTION; }

,[#A-Za-z0-9-]+	{ yylval.sval = strdup(yytext); return GLOBAL_VAR_DEREF; }

[#A-Za-z0-9-]+	{ yylval.sval = strdup(yytext); 
		  if (list_length != -1) {
			current_list[list_length] = yylval.sval;
			list_length++;
			current_list =(char **) realloc(current_list, (list_length+1) * sizeof(char *));	
			current_list[list_length] = NULL;
			return STRING; 
			}
			return STRING; }

\r		{ /* printf("CR!\n"); */ /* return CR;  */}

\n		{ /* printf("LF!\n"); */ ++line_num; /* return LF */; }

\014  { /* FORM FEED */ ; }

<<EOF>>		{ cout << "<<EOF>> (" << my_yyfilename << ")" << endl ; return MYEOF; }

.		{ printf("<!!!> unrecognized token at line %d, length=%d\n[%02x] %c -> %s\n", line_num, strlen(yytext), yytext[0], yytext[0], yytext); exit(1); }
%%
