vaxum.l
%{
  #include <cstdio>
  #include <cassert>
  #include "util.h"
  #include "vaxum.tab.h"  // to get the token types from Bison
  int line_num = 1;
  char *yylval_string_literal = NULL;
  char **current_list = NULL;
  int list_length = 0;

%}
%option noyywrap
%%
[ \t]		;
"<>"		{ return ZIL_FALSE; }
"<"		{ return LT; }
">"		{ return GT; }
"("		{ return LB; }
")"		{ return RB; }
"()"  { return PARAMETER_LIST_EMPTY ; }
"\\"  { /* ESCAPE CHARACTER - NOT SURE WHAT TO DO */ }


;\"(\\.|[^"\\])*\" ;
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }

DIRECTIONS	{  assert(current_list == NULL);
		   current_list = (char **) malloc((list_length+1) * sizeof(char *)); 
                   current_list[0] = NULL; 
                   return DIRECTIONS; }

FDESC		  { return FDESC; }
LDESC		  { return LDESC; }
DESC		  { return DESC; }
GLOBAL	  { return GLOBAL; }
OBJECT	  { return OBJECT; }
ACTION	  { return ACTION; }
SIZE		  { return SIZE; }
TVALUE    { return TVALUE; }
VALUE     { return VALUE; }
CAPACITY  { return CAPACITY; }
DESCFCN   { return DESCFCN; }
TEXT      { return TEXT; }
STRENGTH  { return STRENGTH; }

VTYPE     { return VTYPE; }



ROUTINE   { return ROUTINE; }

FLAGS		{ assert(current_list == NULL);
                   current_list = (char **) malloc((list_length+1) * sizeof(char *));
                   current_list[0] = NULL;
                   return FLAGS;
                }

SYNONYM		{ assert(current_list == NULL); 
		   current_list = (char **) malloc((list_length+1) * sizeof(char *)); 
                   current_list[0] = NULL; 
		   return SYNONYM; 
		}

ADJECTIVE         { assert(current_list == NULL);
                   current_list = (char **) malloc((list_length+1) * sizeof(char *));
                   current_list[0] = NULL;
                   return ADJECTIVE;
                }


IN		{ yylval.sval = strdup(yytext); 
  		  if (current_list) { 
			current_list[list_length] = yylval.sval;
                        list_length++;
                        current_list =(char **) realloc(current_list, (list_length+1) * sizeof(char *));
                        current_list[list_length] = NULL;
			return STRING;
			}
			return IN; }
[0-9]+          { yylval.ival = atoi(yytext); return INT; }
[#A-Za-z0-9-]+	{ yylval.sval = strdup(yytext); 
		  if (current_list) {
			current_list[list_length] = yylval.sval;
			list_length++;
			current_list =(char **) realloc(current_list, (list_length+1) * sizeof(char *));	
			current_list[list_length] = NULL;
			return STRING; 
			}
			return STRING; }
\r		{ /* printf("CR!\n"); */ /* return CR;  */}
\n		{ /* printf("LF!\n"); */ ++line_num; /* return LF */; }
<<EOF>>		{ /* printf("END OF FILE!\n"); */ return MYEOF; }
.		{ printf("<!!!> unrecognized token at line %d, length=%d\n[%02x] %c -> %s\n", line_num, strlen(yytext), yytext[0], yytext[0], yytext); exit(1); }
%%
