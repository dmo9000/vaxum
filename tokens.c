#include <cassert>
#include <iostream>
#include <string.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"
#include "flex.h"

using namespace std;


const char *token_name(int t)
{


    switch(t) {
    case LB:
        return ((const char *) "(");
        break;
    case LSB:
        return ((const char *) "[");
        break;
    case RSB:
        return ((const char *) "]");
        break;
    case BLOAT:
        /* required for Deadline */
        return ((const char *) "BLOAT");
        break;
    case SNAME:
        /* required for Zork3, Enchanter */
        return ((const char *) "SNAME");
        break;

    case VARIABLE_COMMA:
        return ((const char *) "VARIABLE_COMMA");
        break;

    case GDECL:
        return ((const char *) "GDECL");
        break;

    case DOUBLE_QUESTION:
        return ((const char *) "DOUBLE_QUESTION");
        break;

    case PRINC:
        return ((const char *) "PRINC");
        break;

    case COMMENT:
        return ((const char *) "COMMENT");
        break;

    case CONSTANT:
        return ((const char *) "CONSTANT");
        break;

    case PROPDEF:
        return ((const char *) "PROPDEF");
        break;

    case PERCENT:
        return ((const char *) "\%");
        break;

    case MYEOF:
        return ((const char *) "<<EOF>>");
        break;

    case RTRUE:
        return ((const char *) "RTRUE");
        break;

    case IF:
        return ((const char *) "IF");
        break;

    case ROOM:
        return ((const char*) "ROOM");
        break;

    case RFALSE:
        return ((const char *) "RFALSE");
        break;

    case VTYPE:
        return ((const char *) "VTYPE");
        break;

    case STRENGTH:
        return ((const char *) "STRENGTH");
        break;

    case TEXT:
        return ((const char *) "TEXT");
        break;

    case CAPACITY:
        return ((const char *) "CAPACITY");
        break;

    case TVALUE:
        return ((const char *) "TVALUE");
        break;

    case VALUE:
        return ((const char *) "VALUE");
        break;


    case LDESC:
        return ((const char *) "LDESC");
        break;

    case FDESC:
        return ((const char *) "FDESC");
        break;

    case DESCFCN:
        return ((const char *) "DESCFCN");
        break;

    case SIZE:
        return ((const char *) "SIZE");
        break;

    case ADJECTIVE:
        return ((const char*) "ADJECTIVE");
        break;

    case FLAGS:
        return ((const char*) "FLAGS");
        break;

    case ACTION:
        return ((const char*) "ACTION");
        break;

    case DESC:
        return ((const char*) "DESC");
        break;

    case ZIL_FALSE:
        return ((const char *) "<>");
        break;

    case GLOBAL:
        return ((const char *) "GLOBAL");
        break;

    case DIRECTIONS:
        return ((const char *) "DIRECTIONS");
        break;

    case MOVE_TO:
        return ((const char *) "MOVE_TO");
        break;

    case OBJECT:
        return ((const char*) "OBJECT");
        break;

    case DOLLARSTORE_STRING:
        return ((const char*) "DOLLARSTORE_STRING");
        break;

    case VERSION:
        return ((const char *) "VERSION");
        break;

    case ASSIGN_EQUALS:
        return ((const char*) "=");
        break;
    case SYNTAX:
        return ((const char* ) "SYNTAX")	;
        break;

    case SYNONYM:
        return ((const char *) "SYNONYM");
        break;

    case COND:
        return ((const char *) "COND");
        break;

    case COMMA:
        return ((const char *) ",");
        break;
    case FULLSTOP:
        return ((const char *) ".");
        break;
    case BUZZ:
        return ((const char *) "BUZZ");
        break;
    case GLOBAL_VAR_QUERY:
        return ((const char*) "GLOBAL_VAR_QUERY");
        break;

    case PREDICATE_VERB:
        return ((const char*) "VERB?");
        break;

    case ADDITION:
        return ((const char*) "+");
        break;

    case SUBTRACTION:
        return ((const char*) "-+");
        break;

    case DOT_TOKEN_QUERY:
        return ((const char*) ".TOKEN?");
        break;
    case DOT_TOKEN:
        return ((const char*) ".TOKEN");
        break;
    case ASTERISK:
        return ((const char*) "*");
        break;
    case ROUTINE:
        return((const char*) "ROUTINE");
        break;

    case EQUAL_EQUAL_QUESTION:
        return ((const char*) "==?");
        break;

    case DEFINE:
        return ((const char*) "DEFINE");
        break;

    case APOSTROPHE:
        return((const char*) "'");
        break;
    case EQUAL_QUESTION:
        return((const char*) "=?");
        break;
    case INT:
        return((const char*) "INTEGER");
        break;
    case SET:
        return((const char*) "SET");
        break;
    case GASSIGNED_QUESTION:
        return ((const char*) "GASSIGNED?");
        break;
    case DEFMAC:
        return ((const char*) "DEFMAC");
        break;
    case QUESTION:
        return ((const char *) "QUESTION");
        break;
    case INSERT_FILE:
        return((const char *) "INSERT-FILE");
        break;
    case GLOBAL_VAR_DEREF:
        return((const char *) "*GLOBAL DEREF*");
        break;
    case ESCAPED_QUOTE:
        return((const char *) "\"");
        break;
    case BANG:
        return ((const char *) "!");
        break;
    case OR:
        return((const char*) "OR");
        break;

    case STRING:
        return((const char*) "STRING");
        break;
    case SETG:
        return((const char*) "SETG");
        break;
    case GT:
        return((const char *) ">");
        break;
    case LT:
        return((const char *) "<");
        break;
    case STRING_LITERAL:
        return((const char *) "STRING_LITERAL");
        break;
    default:
        //return((const char *) "<unknown>");
        cout << "\n\t+++ unknown token type " << t << endl;
        assert(NULL);
        break;

    }

    return((const char*) "<unreachable>");

}

