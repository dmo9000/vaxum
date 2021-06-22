vaxum.l
%{
  #include <cstdio>
  #include "util.h"
  #include "vaxum.tab.h"  // to get the token types from Bison
  int line_num = 1;
   char *yylval_string_literal = NULL;

%}
%%
"<"		{ printf("LESS THAN\n"); exit(1) ; return LT; };
\r\n		{ ++line_num ; printf("<CRLF>\n"); return CRLF; };
\"(\\.|[^"\\])*\" {  yylval.slval=strdup(yytext); line_num+=count_char_instance(yytext, '\n'); return STRING_LITERAL; }
[ \t]           ;
[0-9]+\.[0-9]+    { yylval.fval = atof(yytext); return FLOAT; }
[0-9]+            { yylval.ival = atoi(yytext); return INT; }
[a-zA-Z0-9!]+      {
  // We have to strdup yytext because Flex will change it for the next token.
  // Note that this memory must be freed somewhere, so that's why we call
  // free() above in the Bison section.  (Aside: we use free() instead of
  // delete because strdup is a C function that uses malloc, not a C++
  // function that uses new.)
  yylval.sval = strdup(yytext);
  return STRING;
}
\n		{ ++line_num ; return ENDL; };
.		{ printf("Unrecognized!\n"); exit(1); };
%%
