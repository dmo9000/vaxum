vaxum.l
%{
  #include <cstdio>
  #include "util.h"
  #include "vaxum.tab.h"  // to get the token types from Bison
  int line_num = 1;
   char *yylval_string_literal = NULL;

%}
%option noyywrap
%%
[ \t]		;
"<"		{ return LT; }
">"		{ return GT; }
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }
DIRECTIONS	{ return DIRECTIONS; }
GLOBAL		{ return GLOBAL; }
[0-9]+          { yylval.ival = atoi(yytext); return INT; }
[A-Za-z0-9-]+	{ yylval.sval = strdup(yytext); return STRING; }
\r		{ /* printf("CR!\n"); */ return CR; }
\n		{ /* printf("LF!\n"); */ ++line_num; return LF; }
<<EOF>>		{ /* printf("END OF FILE!\n"); */ return MYEOF; }
.		{ printf("<!!!> unrecognized token: len=%d\n[%02x] %c -> %s\n", strlen(yytext), yytext[0], yytext[0], yytext); exit(1); }
%%
