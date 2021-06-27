#include <iostream>
#include <cassert>
#include "parser.h"


const char *token_name(int t)
{

    switch(t) {
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
        return((const char *) "\\\"");
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
        return((const char *) "<unknown>");
        break;

    }

    return((const char*) "<unreachable>");

}

