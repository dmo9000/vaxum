#pragma once
#include <iostream>
#include "util.h"
#include "tokens.h"

#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    CR = 258,
    LF = 259,
    MYEOF = 260,
    LT = 261,
    GT = 262,
    DIRECTIONS = 263,
    GLOBAL = 264,
    ZIL_FALSE = 265,
    OBJECT = 266,
    ROOM = 267,
    SYNONYM = 268,
    DESC = 269,
    FDESC = 270,
    DESCFCN = 271,
    LDESC = 272,
    TEXT = 273,
    FLAGS = 274,
    ACTION = 275,
    ADJECTIVE = 276,
    SIZE = 277,
    VALUE = 278,
    TVALUE = 279,
    CAPACITY = 280,
    STRENGTH = 281,
    VTYPE = 282,
    IN = 283,
    LB = 284,
    RB = 285,
    COMMENT = 286,
    ROUTINE = 287,
    PARAMETER_LIST_EMPTY = 288,
    COND = 289,
    PREDICATE_VERB = 290,
    GLOBAL_VAR_DEREF = 291,
    RTRUE = 292,
    RFALSE = 293,
    MOVE_TO = 294,
    IF = 295,
    VERSION = 296,
    SETG = 297,
    INT = 298,
    FLOAT = 299,
    STRING = 300,
    STRING_LITERAL = 301,
    SET = 302,
    OR = 303,
    GASSIGNED_QUESTION = 304,
    BANG = 305,
    ESCAPED_QUOTE = 306,
    PRINC = 307,
    INSERT_FILE = 308,
    QUESTION = 309
  
  };
#endif

union YYSTYPE
{
#line 37 "vaxum.y" /* yacc.c:1909  */

  int ival;
  float fval;
  char *sval;
  char *slval;

#line 108 "vaxum.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1


int parse_main();
