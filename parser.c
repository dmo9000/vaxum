#include <cassert>
#include <iostream>
#include <cstring>
#include <unistd.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"
#include "flex.h"
#include "tree.h"
#include "interface.h"

#define DEBUG_NONE 0
#define DEBUG_FILEIO 1
#define DEBUG_UNIMPLEMENTED 2
#define DEBUG_SCOPE 3
#define DEBUG_SCOPEDEPTH 4
#define DEBUG_MISSINGTOKEN 5
#define DEBUG_LINENUMBERS 6
#define DEBUG_SCOPENUMBERS 7

#define ANSI_NONE (ansi_colour ? "\033[0m" : "")
#define ANSI_BLACK (ansi_colour ? "\033[30m" : "")
#define ANSI_RED (ansi_colour ? "\033[31m" : "")
#define ANSI_GREEN (ansi_colour ? "\033[32m" : "")
#define ANSI_YELLOW (ansi_colour ? "\033[33m" : "")
#define ANSI_BLUE (ansi_colour ? "\033[34m" : "")
#define ANSI_MAGENTA (ansi_colour ? "\033[35m" : "")
#define ANSI_CYAN (ansi_colour ? "\033[36m" : "")
#define ANSI_WHITE (ansi_colour ? "\033[37m" : "")

#define ANSI_BRIGHT_BLACK (ansi_colour ? "\033[90m" : "")
#define ANSI_BRIGHT_RED (ansi_colour ? "\033[91m" : "")
#define ANSI_BRIGHT_GREEN (ansi_colour ? "\033[92m" : "")
#define ANSI_BRIGHT_YELLOW (ansi_colour ? "\033[93m" : "")
#define ANSI_BRIGHT_BLUE (ansi_colour ? "\033[94m" : "")
#define ANSI_BRIGHT_MAGENTA (ansi_colour ? "\033[95m" : "")
#define ANSI_BRIGHT_CYAN (ansi_colour ? "\033[96m" : "")
#define ANSI_BRIGHT_WHITE (ansi_colour ? "\033[97m" : "")

using namespace std;

extern int gdl;
bool ansi_colour = false;
bool go_interactive = false;

extern int yylex();
extern YYSTYPE yylval;
extern FILE *current_fh;
extern int yyset_in(FILE *);
extern FILE *yyin;
extern int yyrestart(FILE *);
extern YY_BUFFER_STATE get_yy_current_buffer();
YY_BUFFER_STATE buffer_state;

int alligator_scope_depth = 0;
int brackets_scope_depth = 0;
int square_brackets_scope_depth = 0;

extern char *my_yyfilename;
extern int line_num;
ZIL_Context current_context = CONTEXT_GLOBAL;

stack *file_stack = NULL;
stack *scope_stack = NULL;

int parse_recursive(int);
int parse_or();
int parse_set();
int parse_setg();

const char *current_ansi_colour = "";
const char *last_ansi_colour = "";

tree *compiler_macros = NULL;
tree *global_variables = NULL;
tree *routines = NULL;
tree *collections = NULL;
tree *rooms = NULL;
tree *objects = NULL;

void unfold(const char *s)
{
    int i = 0;
    for (i = 0; i < strlen(s); i++)
    {
        if (s[i] == '\n')
        {
            putchar('|');
        }

        if (s[i] != '\r' && s[i] != '\n')
        {
            putchar(s[i]);
        }
    }
    putchar(' ');
    return;
}

void set_ansi_colour(const char *c, const char *function, const char *file, int line)
{
    last_ansi_colour = current_ansi_colour;
    current_ansi_colour = c;
    //cerr << c << "\nnew ansi_colour (" << function << ":" << file << "," << line << ")" << flush;
    //assert(NULL);
    //cerr << "[C" << c << "C]" << flush;
    cerr << c << flush;
    return;
}

bool push_enclosure_type(int y)
{
    stackitem *new_enclosure_type = NULL;
    switch (y)
    {
    case LB:
        new_enclosure_type = stackitem_new();
        new_enclosure_type->type = LISTITEM_ENCLOSURE;
        new_enclosure_type->payload.i16 = LB;
        assert(stack_push(scope_stack, new_enclosure_type));
        brackets_scope_depth++;
        if (gdl > DEBUG_UNIMPLEMENTED)
        {
            set_ansi_colour(ANSI_GREEN, __FUNCTION__, __FILE__, __LINE__);
        }
        if (gdl >= DEBUG_SCOPENUMBERS)
        {
            cerr << "({" << brackets_scope_depth << "} ";
        }
        else
        {
            if (gdl >= DEBUG_SCOPE)
                cerr << "(";
        }

        return true;
        break;
    case LT:
        new_enclosure_type = stackitem_new();
        new_enclosure_type->type = LISTITEM_ENCLOSURE;
        new_enclosure_type->payload.i16 = LT;
        assert(stack_push(scope_stack, new_enclosure_type));
        alligator_scope_depth++;

        if (gdl > DEBUG_UNIMPLEMENTED)
        {
            set_ansi_colour(ANSI_BLUE, __FUNCTION__, __FILE__, __LINE__);
        }

        if (gdl >= DEBUG_SCOPENUMBERS)
        {
            cerr << "<{" << alligator_scope_depth << "} ";
        }
        else
        {
            if (gdl >= DEBUG_SCOPE)
                cerr << "<";
        }

        return true;
        break;
    case LSB:
        new_enclosure_type = stackitem_new();
        new_enclosure_type->type = LISTITEM_ENCLOSURE;
        new_enclosure_type->payload.i16 = LSB;
        assert(stack_push(scope_stack, new_enclosure_type));
        square_brackets_scope_depth++;
        if (gdl >= DEBUG_UNIMPLEMENTED)
            set_ansi_colour(ANSI_RED, __FUNCTION__, __FILE__, __LINE__);
        if (gdl >= DEBUG_SCOPENUMBERS)
        {
            cerr << "[{" << square_brackets_scope_depth << "} ";
        }
        else
        {
            if (gdl >= DEBUG_SCOPE)
                cerr << "[";
        }

        return true;
        break;
    default:
        cerr << "\n+++ cannot push enclosure type '" << token_name(y) << "'\n";
        exit(1);
        break;
    }

    return false;
}

bool enforce_enclosure_type(int y, const char *function, const char *file, int line)
{
    stackitem *last_enclosure = NULL;
    stackitem *prev_enclosure = NULL;
    assert(scope_stack);

    if (!scope_stack->count)
    {
        cerr << "+++ got invalid request to enforce enclosure type '" << token_name(y) << "' (@ " << function << "(), " << file << ":" << line << ")\n";
        exit(1);
    }

    assert(scope_stack->count);
    last_enclosure = stack_pop(scope_stack);
    assert(last_enclosure);
    assert(last_enclosure->type == LISTITEM_ENCLOSURE);
    switch (y)
    {
    case GT:
        if (last_enclosure->payload.i16 == LT)
        {
            alligator_scope_depth--;

            const char *prev_colour = (const char *)"";
            prev_enclosure = stack_peek(scope_stack);
            if (!prev_enclosure)
            {
                /* at outer scope ? */
            }
            else
            {
                assert(prev_enclosure->type == LISTITEM_ENCLOSURE);
                //cerr << "token_type " << token_name(last_enclosure->payload.i16) << "\n" << flush;
                //assert(NULL);

                switch (prev_enclosure->payload.i16)
                {
                case LB:
                    prev_colour = (const char *)ANSI_GREEN;
                    break;
                case LT:
                    prev_colour = (const char *)ANSI_BLUE;
                    break;
                default:
                    cerr << "+++ cannot get colour for outer scope\n"
                         << flush;
                    assert(NULL);
                }
            }

            if (gdl >= DEBUG_SCOPENUMBERS)
            {
                set_ansi_colour(ANSI_BLUE, __FUNCTION__, __FILE__, __LINE__);
                cerr << "{" << alligator_scope_depth << "}> ";
                if (gdl >= DEBUG_UNIMPLEMENTED)
                {
                    set_ansi_colour(prev_colour, __FUNCTION__, __FILE__, __LINE__);
                }
            }
            else
            {
                if (gdl >= DEBUG_SCOPE)
                {
                    set_ansi_colour(ANSI_BLUE, __FUNCTION__, __FILE__, __LINE__);
                    cerr << ">";
                }
                if (gdl >= DEBUG_UNIMPLEMENTED)
                {
                    set_ansi_colour(prev_colour, __FUNCTION__, __FILE__, __LINE__);
                }
            }

            return true;
        }
        else
        {
            cerr << "\n\t+++ gt: mismatched scope enclosure, expected '>', got '" << token_name(y) << "'\n"
                 << flush;
            cerr << "\t\t+++     at " << my_yyfilename << ":" << line_num << flush;
            assert(NULL);
            return false;
        }
        return false;
        break;

    case RB:
        if (last_enclosure->payload.i16 == LB)
        {
            brackets_scope_depth--;

            const char *prev_colour = (const char *)"";
            prev_enclosure = stack_peek(scope_stack);
            if (!prev_enclosure)
            {
                /* at outer scope ? */
            }
            else
            {
                assert(prev_enclosure->type == LISTITEM_ENCLOSURE);
                //cerr << "token_type " << token_name(last_enclosure->payload.i16) << "\n";
                //assert(NULL);
                switch (prev_enclosure->payload.i16)
                {
                case LB:
                    prev_colour = (const char *)ANSI_GREEN;
                    break;
                case LT:
                    prev_colour = (const char *)ANSI_BLUE;
                    break;
                default:
                    cerr << "+++ cannot get colour for outer scope\n"
                         << flush;
                    assert(NULL);
                }
            }

            if (gdl >= DEBUG_SCOPENUMBERS)
            {
                set_ansi_colour(ANSI_GREEN, __FUNCTION__, __FILE__, __LINE__);
                cerr << "{" << brackets_scope_depth << "}) ";
                if (gdl >= DEBUG_UNIMPLEMENTED)
                {
                    set_ansi_colour(prev_colour, __FUNCTION__, __FILE__, __LINE__);
                }
            }
            else
            {
                if (gdl >= DEBUG_SCOPE)
                {
                    set_ansi_colour(ANSI_GREEN, __FUNCTION__, __FILE__, __LINE__);
                    cerr << ")";
                }
                if (gdl >= DEBUG_UNIMPLEMENTED)
                {
                    set_ansi_colour(prev_colour, __FUNCTION__, __FILE__, __LINE__);
                }
            }

            return true;
        }
        else
        {
            cerr << "\n\t+++ rb: mismatched scope enclosure, expected ')', got '" << token_name(y) << "'\n"
                 << flush;
            cerr << "\t\t+++     at " << my_yyfilename << ":" << line_num << flush;
            assert(NULL);
            return false;
        }
        return false;
        break;

    case RSB:
        if (last_enclosure->payload.i16 == LSB)
        {
            square_brackets_scope_depth--;

            const char *prev_colour = (const char *)"";
            prev_enclosure = stack_peek(scope_stack);
            if (!prev_enclosure)
            {
                /* at outer scope ? */
                assert(NULL);
            }
            else
            {
                assert(prev_enclosure->type == LISTITEM_ENCLOSURE);
                //cerr << "token_type " << token_name(last_enclosure->payload.i16) << "\n";
                //assert(NULL);
                switch (prev_enclosure->payload.i16)
                {
                case LB:
                    prev_colour = (const char *)ANSI_GREEN;
                    break;
                case LT:
                    prev_colour = (const char *)ANSI_BLUE;
                    break;
                default:
                    cerr << "+++ cannot get colour for outer scope\n"
                         << flush;
                    assert(NULL);
                }
            }

            if (gdl >= DEBUG_SCOPENUMBERS)
            {
                cerr << "{" << square_brackets_scope_depth << "}] ";
            }
            else
            {
                if (gdl >= DEBUG_SCOPE)
                    cerr << "])";
            }

            return true;
        }
        else
        {
            cerr << "\n\t+++ rsb: mismatched scope enclosure, expected ']', got '" << token_name(y) << "'\n"
                 << flush;
            cerr << "\t\t+++     at " << my_yyfilename << ":" << line_num << flush;
            assert(NULL);
            return false;
        }
        return false;
        break;

    default:
        cerr << "\n+++ cannot pop enclosure type '" << token_name(y) << "'\n";
        exit(1);
        break;
    }

    return false;
}

bool expect_token(int y, int x, bool halt)
{
    if (x == y)
    {
        return y;
    }

    /* token type did not match expected */

    cerr << "\n\t+++ expected '" << token_name(x) << "', but received token '" << token_name(y) << "(" << y << ")' at file " << my_yyfilename << ":" << line_num << "\n";
    if (halt)
    {
        exit(1);
    }
    return y;
}

void debug_token(int y)
{

    switch (y)
    {
    case STRING:
        //cerr << "\n\tSTRING = " << yylval.sval << endl;
        cerr << "\n++ debug token " << y << "(" << token_name(y) << "=" << yylval.sval << ")"
             << " at " << my_yyfilename << " line " << line_num << "\n";
        break;
    default:
        cerr << "\n++ debug token " << y << "(" << token_name(y) << ")"
             << " at " << my_yyfilename << " line " << line_num << "\n";

        break;
    }
    return;
}

void invalid_token(int y, const char *function, const char *file, int line)
{
    cerr << "++ invalid token " << y << "(" << token_name(y) << ")"
         << " at " << my_yyfilename << " line " << line_num << " at " << function
         << "():" << file << ":" << line << endl;
    switch (y)
    {
    case STRING:
        cerr << "\tSTRING = " << yylval.sval << endl;
        break;
    default:
        break;
    }
    exit(1);
}

int parse_insert_file()
{
    FILE *nfh = NULL;
    _fileref *fr = NULL;
    char new_full_file_name[MAX_STRING];
    char *working_path = NULL;
    char *filename = NULL;
    char *p = (char *)&new_full_file_name;
    int y = 0;
    y = yylex();
    assert(y == STRING_LITERAL);
    if (gdl >= DEBUG_FILEIO)
        cerr << "INSERT-FILE " << yylval.sval << " ";
    working_path = dirname(strdup(my_yyfilename));

    /* dont know what this third argument is for yet */

    /* WARNING: leaks */
    memset(&new_full_file_name, 0, MAX_STRING);
    strncat(p, working_path, strlen(working_path));
    p += strlen(working_path);

    filename = strdup(dequote(yylval.sval));
    filename = strdup(lowercase(filename));
    strncat(p, "/", 2);
    p += 1;
    strncat(p, filename, strlen(filename));
    p += strlen(filename);
    strncat(p, ".zil", 5);
    p += 4;
    if (gdl >= DEBUG_FILEIO)
        cerr << "[" << new_full_file_name << "] ";

    y = yylex();
    assert(y == STRING);
    assert(yylval.sval[0] == 'T' && strlen(yylval.sval) == 1);
    if (gdl >= DEBUG_FILEIO)
        cerr << "T";
    y = yylex();

    assert(enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__));

    if (gdl >= DEBUG_FILEIO)
    {
        cerr << "\n"
             << flush;
    }

    /* create new fileref */

    fr = (struct _fileref *)malloc(sizeof(struct _fileref));
    memset(fr, 0, sizeof(struct _fileref));
    fr->filename = strdup(my_yyfilename);
    fr->line_num = line_num;
    fr->handle = current_fh;
    fr->offset = ftell(current_fh);

    fr->buffer_state = get_yy_current_buffer();

    stackitem *nsi = stackitem_new();
    assert(nsi);
    nsi->type = LISTITEM_FILEREF;
    memcpy(&nsi->payload.fr, fr, sizeof(struct _fileref));
    assert(nsi->payload.fr.offset == fr->offset);
    assert(nsi->payload.fr.handle == fr->handle);
    assert(nsi->payload.fr.line_num == fr->line_num);
    assert(stack_push(file_stack, nsi));

    current_fh = NULL;
    current_fh = fopen(new_full_file_name, "r");
    assert(current_fh);
    my_yyfilename = strdup(new_full_file_name);
    line_num = 1;

    yyset_in(current_fh);
    yyin = current_fh;

    buffer_state = yy_create_buffer(current_fh, YY_BUF_SIZE);
    yy_switch_to_buffer(buffer_state);

    set_ansi_colour(ANSI_WHITE, __FUNCTION__, __FILE__, __LINE__);
    if (gdl > DEBUG_UNIMPLEMENTED)
    {
        cerr << "\n";
    }
    cerr << "# Parsing " << my_yyfilename << " ... \n"
         << flush;
    y = yylex();
    parse_recursive(y);

    return 1;
}

int parse_princ()
{
    int y = 0;
    y = yylex();
    assert(y == STRING_LITERAL);
    cerr << "PRINC " << yylval.sval;
    return 1;
}

int parse_skip_unimplemented(const char *s)
{
    int y = 0;
    y = yylex();
    char *bn = NULL;

    //cerr << "PSU-BEGIN()" << endl << flush;

    assert(s);

    bn = basename(my_yyfilename);
    assert(bn);

    if (gdl >= DEBUG_UNIMPLEMENTED)
    {

        set_ansi_colour(ANSI_RED, __FUNCTION__, __FILE__, __LINE__);

        if (gdl >= DEBUG_LINENUMBERS)
        {
            cerr << "[::" << s << "] ";
        }
        else
        {
            cerr << "[::" << s << " (" << bn << "," << line_num << ")] ";
        }

        set_ansi_colour(last_ansi_colour, __FUNCTION__, __FILE__, __LINE__);
    }
    if (gdl >= DEBUG_UNIMPLEMENTED && gdl < DEBUG_SCOPE)
    {
        //cerr << "\nZZ" << flush;
        cerr << "\n";
    }

    /* should this be while any depth? remains to be seen, as the alligator brackets always seem to be outermost */

    while (alligator_scope_depth > 0)
    {
        /* in case it got reset */
        if (gdl > DEBUG_UNIMPLEMENTED)
        {
            set_ansi_colour(current_ansi_colour, __FUNCTION__, __FILE__, __LINE__);
        }

        switch (y)
        {

        case MYEOF:
            //cerr << "EOF! reached during parse_skip_unimplemented()\n" ;
            return 1;
            break;

        case VARIABLE_COMMA:
        case DOUBLE_QUESTION:
        case DOLLARSTORE_STRING:
            if (gdl >= DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            break;

        case DEFINE:
        case IF:
        case SYNTAX:
        case RTRUE:
        case BLOAT:
        case PRINC:
        case COMMENT:
        case CONSTANT:
        case GLOBAL:
        case PROPDEF:
        case ROUTINE:
        case INSERT_FILE:
        case PREDICATE_VERB:
        case PERCENT:
        case SETG:
        case ROOM:
        case RFALSE:
        case VTYPE:
        case STRENGTH:
        case TEXT:
        case SIZE:
        case DESCFCN:
        case CAPACITY:
        case VALUE:
        case TVALUE:
        case LDESC:
        case FDESC:
        case ADJECTIVE:
        case FLAGS:
        case ACTION:
        case DESC:
        case ZIL_FALSE:
        case MOVE_TO:
        case OBJECT:
        case VERSION:
        case ASSIGN_EQUALS:
        case SYNONYM:
        case BUZZ:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << token_name(y) << " ";
            break;

        case ESCAPED_QUOTE:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "\" ";
            break;
        case COMMA:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << ", ";
            break;
        case FULLSTOP:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << ". ";
            break;
        case GASSIGNED_QUESTION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "GASSIGNED?"
                     << " ";
            break;
        case GLOBAL_VAR_QUERY:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            cerr << flush;
            //assert(NULL);
            break;
        case ADDITION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "+ ";
            break;

        case SUBTRACTION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "-+ ";
            break;

        case ASTERISK:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "* ";
            break;
        case BANG:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "! ";
            break;
        case APOSTROPHE:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "' ";
            break;
        case EQUAL_QUESTION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "=? ";
            break;
        case EQUAL_EQUAL_QUESTION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "==? ";
            break;
        case OR:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "OR ";
            break;
        case SET:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "SET ";
            break;
        case INT:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.ival << " ";
            break;
        case DOT_TOKEN:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            break;
        case DOT_TOKEN_QUERY:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            break;
        case QUESTION:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            break;
        case COND:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "COND ";
            break;
        case PARAMETER_LIST_EMPTY:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "() ";
            break;
        case LF:
            //cerr << "<LINEFEED:1>" << flush;
            if (gdl >= DEBUG_LINENUMBERS)
            {
                //cerr << "\n" << flush;
                //cerr << "\n<ZZ3>" << flush;
            }
            else
            {
                if (gdl > DEBUG_UNIMPLEMENTED && gdl < DEBUG_SCOPEDEPTH)
                {
                    //cerr << "\nZ2";
                    //cerr << "<ZZ4>\n" << flush;
                    //cerr << "\n";
                    insert_indent(alligator_scope_depth + brackets_scope_depth);
                }
            }

            //cerr << "<END-LINEFEED:1>" << flush;
            break;
        case GLOBAL_VAR_DEREF:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << yylval.sval << " ";
            break;
        case STRING_LITERAL:

            /* unfold string literal */
            if (gdl > DEBUG_UNIMPLEMENTED)
            {
                set_ansi_colour(ANSI_YELLOW, __FUNCTION__, __FILE__, __LINE__);
            }
            if (gdl > DEBUG_UNIMPLEMENTED)
            {
                //cerr << yylval.sval << " ";
                //cerr << "UNFOLD";
                unfold(yylval.sval);
            }
            if (gdl > DEBUG_UNIMPLEMENTED)
            {
                set_ansi_colour(last_ansi_colour, __FUNCTION__, __FILE__, __LINE__);
            }

            break;
        case STRING:
            if (gdl > DEBUG_UNIMPLEMENTED)
                cerr << "" << yylval.sval << " ";
            break;
        case GT:
            enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__);
            break;
        case RB:
            enforce_enclosure_type(RB, __FUNCTION__, __FILE__, __LINE__);
            break;
        case RSB:
            enforce_enclosure_type(RSB, __FUNCTION__, __FILE__, __LINE__);
            break;
        case LT:

            if (gdl >= DEBUG_LINENUMBERS)
            {
                set_ansi_colour(ANSI_WHITE, __FUNCTION__, __FILE__, __LINE__);
                //cerr << "\n(X4)" << flush;
                cerr << "\n";
                cerr << basename(my_yyfilename) << "," << line_num << ": " << flush;
                set_ansi_colour(last_ansi_colour, __FUNCTION__, __FILE__, __LINE__);
            }

            if (gdl > DEBUG_UNIMPLEMENTED && gdl < DEBUG_LINENUMBERS)
            {
                //cerr << "\n<X6>" << flush;
                cerr << "\n";
            }

            if (gdl > DEBUG_UNIMPLEMENTED)
            {
                insert_indent(alligator_scope_depth + brackets_scope_depth);
            }

            push_enclosure_type(LT);

            break;
        case LB:
            if (gdl >= DEBUG_SCOPE && gdl < DEBUG_LINENUMBERS)
            {
                if (gdl >= DEBUG_SCOPEDEPTH && gdl <= DEBUG_LINENUMBERS)
                {
                    //cerr << "\n<X2>" << flush;
                }
            }
            if (gdl >= DEBUG_SCOPEDEPTH && gdl <= DEBUG_LINENUMBERS)
            {
                //cerr << "<X3>\n" << flush;

                if (gdl >= DEBUG_LINENUMBERS)
                {
                    //cerr << "<V2>\n" << flush;
                    //cerr << "\n";
                    //insert_indent(alligator_scope_depth + brackets_scope_depth);
                }
            }
            push_enclosure_type(LB);
            break;
        case LSB:
            if (gdl >= DEBUG_SCOPE && gdl <= DEBUG_LINENUMBERS)
            {
                cerr << "<Y1>\n"
                     << flush;

                if (gdl == DEBUG_UNIMPLEMENTED)
                {
                    cerr << "<V3>\n"
                         << flush;
                    insert_indent(alligator_scope_depth + brackets_scope_depth);
                }
            }
            push_enclosure_type(LSB);

            break;

        default:
            if (gdl > DEBUG_MISSINGTOKEN)
            {
                cerr << "{unhandled token=" << token_name(y) << "=" << y << "} ";
                assert(NULL);
            }
            break;
        }

        y = yylex();
        cerr << flush;
        cerr << flush;
    }
    //cerr << "PSU-END()" << endl << flush;
    return parse_recursive(y);
}

int parse_main()
{

    assert(alligator_scope_depth == 0);
    assert(brackets_scope_depth == 0);
    assert(current_context == CONTEXT_GLOBAL);

    file_stack = stack_new();
    assert(file_stack);
    file_stack->label = (const char *)"open filehandles list";
    scope_stack = stack_new();
    assert(scope_stack);
    scope_stack->label = (const char *)"open scoping list";

    compiler_macros = (tree *)tree_new("compiler_macros");
    assert(compiler_macros);
    global_variables = (tree *)tree_new("global_variables");
    assert(global_variables);

    buffer_state = yy_create_buffer(current_fh, YY_BUF_SIZE);

    yy_switch_to_buffer(buffer_state);

    set_ansi_colour(ANSI_WHITE, __FUNCTION__, __FILE__, __LINE__);
    cerr << "# Parsing " << my_yyfilename << " ... \n"
         << flush;

    int y = yylex();

    return parse_recursive(y);
}

int parse_recursive(int y)
{

    /* get first token in stream */
    //cerr << "<PR-BEGIN()>\n" << flush;
    while (1)
    {

        if (brackets_scope_depth < 0)
        {
            cerr << "FATAL: brackets_scope_depth: " << brackets_scope_depth << endl;
            exit(1);
        }

        assert(alligator_scope_depth >= 0);
        assert(brackets_scope_depth >= 0);
        assert(current_context == CONTEXT_GLOBAL);

        //cerr << "current position in " << my_yyfilename << " is " << ftell(current_fh) << endl << flush;

        switch (y)
        {

        case MYEOF:
            /* if this is the last file in the chain, exit on EOF, otherwise pop the most recent file off the stack and continue processing */

            if (!file_stack->count)
            {
                /* all files on stack have been processed, and we have hit the end of the input */
                set_ansi_colour(ANSI_WHITE, __FUNCTION__, __FILE__, __LINE__);
                cerr << "\n\n"
                     << "[***] Input completed.\n\n";
                set_ansi_colour(ANSI_NONE, __FUNCTION__, __FILE__, __LINE__);

                if (isatty(fileno(stdin)) && go_interactive)
                {
                    run_interface();
                }

                exit(0);
            }
            else
            {
                /* there are files remaining on the stack, pop the last one and continue */

                // cerr << "\n\t* (file stack depth is currently " << file_stack->count << "; ";
                stackitem *lsi = stack_pop(file_stack);
                assert(lsi);
                assert(lsi->type == LISTITEM_FILEREF);
                assert(lsi->payload.fr.buffer_state);

                current_fh = lsi->payload.fr.handle;
                line_num = lsi->payload.fr.line_num;

                /* must be balanced by end of file? */

                assert(alligator_scope_depth == 0);
                assert(brackets_scope_depth == 0);

                // cerr << "switching back to " << lsi->payload.fr.filename << ", line " << line_num << " from " << my_yyfilename <<  ")" << endl;
                my_yyfilename = strdup(lsi->payload.fr.filename);

                yyset_in(current_fh);
                yyin = current_fh;

                yy_switch_to_buffer(lsi->payload.fr.buffer_state);

                y = yylex();
                parse_recursive(y);
            }
            break;

            /* general unimplemented */

        case QUESTION:
        case PRINC:
        case SET:
        case VERSION:
        case BLOAT:
        case BUZZ:
        case COND:
        case OR:
        case ROUTINE:
        case SNAME:
        case GDECL:
        case COMMENT:
        case SETG:
        case PERCENT:
        case CONSTANT:
        case PROPDEF:
        case ROOM:
        case OBJECT:
        case GLOBAL:
        case DIRECTIONS:
        case SYNTAX:
        case DEFMAC:
        case DEFINE:
        case SYNONYM:
            if (!parse_skip_unimplemented((const char *)token_name(y)))
            {
                cerr << "Fatal error" << endl;
                assert(NULL);
            }
            break;

        case INSERT_FILE:
            if (!parse_insert_file())
            {
                cerr << "Fatal error" << endl;
                assert(NULL);
            }
            break;

        case LF:
            //cerr << "<LINEFEED:0>" << endl << flush;
            if (gdl >= DEBUG_LINENUMBERS)
            {
                set_ansi_colour(ANSI_WHITE, __FUNCTION__, __FILE__, __LINE__);
                //cerr << "\n(ZZ1)" << basename(my_yyfilename) << "," << line_num << ": " << flush;
                cerr << "\n"
                     << basename(my_yyfilename) << "," << line_num << ": " << flush;
                set_ansi_colour(ANSI_NONE, __FUNCTION__, __FILE__, __LINE__);
            }
            else if (gdl > DEBUG_UNIMPLEMENTED && gdl != DEBUG_LINENUMBERS)
            {
                //cerr << "\n(ZZ2)" << flush;
                //cerr << "\nX9" << flush;
                cerr << "\n"
                     << flush;
            }
            break;

        case LT:
            push_enclosure_type(LT);
            break;

        case GT:
            if (!enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__))
            {
                cerr << "can't enforce enclosure type '" << token_name(GT) << "'\n";
                assert(NULL);
            }
            break;

        case RSB:
            assert(NULL);
        case LSB:
            assert(NULL);
            break;

        case LB:
            push_enclosure_type(LB);
            break;

        case RB:
            if (!enforce_enclosure_type(RB, __FUNCTION__, __FILE__, __LINE__))
            {
                cerr << "can't enforce enclosure type '" << token_name(LB) << "'\n";
                assert(NULL);
            }
            break;

        case STRING_LITERAL:
            assert(current_context == CONTEXT_GLOBAL);
            if (gdl >= DEBUG_SCOPE)
            {
                //cerr << "X9" << yylval.sval;
            }
            break;

        default:
            cerr << "\n\t";
            print_line_from_file(current_fh, my_yyfilename, line_num);
            invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
            break;
        }

        /* get next token in stream */
        y = yylex();
    }

    //cerr << "<PR-END()>\n" << endl << flush;

    return 0;
}
