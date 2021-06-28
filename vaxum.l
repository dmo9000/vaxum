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

\\\"  { return ESCAPED_QUOTE; }
\\\.  { return FULLSTOP ; }
\\\,  { return COMMA; }
\+    { return ADDITION; }
\-    { return SUBTRACTION; }
\*    { return ASTERISK; }
\'    { return APOSTROPHE; }
\=    { return ASSIGN_EQUALS; }
"==?" { return EQUAL_EQUAL_QUESTION; }
"=?"  { return EQUAL_QUESTION; }
"<>"		{ return ZIL_FALSE; }
"<"		{ return LT; }
">"		{ return GT; }
"("		{ return LB; }
")"		{ return RB; }
\(\)  { return PARAMETER_LIST_EMPTY ; }
"\\"  { /* ESCAPE CHARACTER - NOT SURE WHAT TO DO */ }
\%    { return PERCENT; }
\/  ; 
\;    { return COMMENT; }

\,[-A-Z]+\?         { yylval.sval = strdup(yytext) ; return GLOBAL_VAR_QUERY; }
\.[-0-9A-Z?]+\?         { yylval.sval = strdup(yytext) ; return DOT_TOKEN_QUERY; }
\.[-A-Z]+         { yylval.sval = strdup(yytext) ; return DOT_TOKEN; }
\$[-A-Z]+         { yylval.sval = strdup(yytext) ; return DOLLARSTORE_STRING; }
[A-Z]+,           { yylval.sval = strdup(yytext) ; return VARIABLE_COMMA; }

;[-A-Z]+          { /* another form of end-of-line comment */ }
;\".*\" ;         { /* another form of end-of-line comment */ }
;\"(\\.|[^"\\])*\" ;
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }

DIRECTIONS	{ return DIRECTIONS; 
               }

"GASSIGNED?"	  { return GASSIGNED_QUESTION; }
GDECL     { return GDECL; }
CONSTANT  { return CONSTANT; }
BUZZ      { return BUZZ; }
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
DEFINE  { return DEFINE; }
SYNTAX  { return SYNTAX; }
FLAGS		{ return FLAGS; }
PROPDEF { return PROPDEF; }
SYNONYM		{ return SYNONYM; }
ADJECTIVE         { return ADJECTIVE; }
"INSERT-FILE" { return INSERT_FILE; }



IN		          { yylval.sval = strdup(yytext) ; return STRING; }

[0-9]+          { yylval.ival = atoi(yytext); return INT; }

\<RTRUE\>      { return RTRUE; } 
\<RFALSE\>      { return RFALSE; } 




[#A-Za-z0-9-]+"?"	{ yylval.sval = strdup(yytext); return QUESTION; }
[#A-Za-z0-9-]+"??"	{ yylval.sval = strdup(yytext); return DOUBLE_QUESTION; }

,[\?#A-Za-z0-9-]+	{ yylval.sval = strdup(yytext); return GLOBAL_VAR_DEREF; }

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

\n		{ /* printf("LF!\n"); */ ++line_num; return LF ; }

\^L   { /* form feed */ ; }
\014  { /* form FEED */ ; }

<<EOF>>		{ return MYEOF; }

.		{ cout << "\n<!!!> unrecognized token '" << yytext << "' at " << my_yyfilename << ":" << line_num; exit(1); }
%%
