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
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }
\r		{ printf("CR!\n"); return CR; }
\n		{ printf("LF!\n"); ++line_num; return LF; }
<<EOF>>		{ printf("END OF FILE!\n"); return MYEOF; }
.		{ printf("Unrecognized! len=%d\n[%02x]\n", strlen(yytext), yytext[0]); exit(1); }
%%
