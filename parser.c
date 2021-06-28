#include <cassert>
#include <iostream>
#include <string.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"
#include "flex.h"

using namespace std;

extern int yylex();
extern YYSTYPE yylval;
extern FILE *current_fh;
extern int yyset_in(FILE *);
extern FILE *yyin;
extern int yyrestart(FILE *);
extern YY_BUFFER_STATE get_yy_current_buffer();

int alligator_scope_depth = 0;
int brackets_scope_depth = 0;

extern char *my_yyfilename;
extern int line_num;
ZIL_Context current_context = CONTEXT_GLOBAL;


stack *file_stack = NULL;
stack *scope_stack = NULL;

YY_BUFFER_STATE buffer_state;

int parse_recursive(int);
int parse_or();
int parse_set();
int parse_setg();


bool push_enclosure_type(int y)
{
    stackitem* new_enclosure_type = NULL;
    switch (y) {
    case LB:
        new_enclosure_type = stackitem_new();
        new_enclosure_type->type = LISTITEM_ENCLOSURE;
        new_enclosure_type->payload.i16 = LB;
        assert(stack_push(scope_stack, new_enclosure_type));
        brackets_scope_depth++;
        cout << "({" << brackets_scope_depth << "} ";
        return true;
        break;
    case LT:
        new_enclosure_type = stackitem_new();
        new_enclosure_type->type = LISTITEM_ENCLOSURE;
        new_enclosure_type->payload.i16 = LT;
        assert(stack_push(scope_stack, new_enclosure_type));
        alligator_scope_depth++;
        cout << "<{" << alligator_scope_depth << "} ";
        return true;
        break;
    default:
        cout << "\n+++ cannot push enclosure type '" << token_name(y) << "'\n";
        exit(1);
        break;
    }

    return false;
}

bool enforce_enclosure_type(int y, const char *function, const char *file, int line)
{
    stackitem* last_enclosure = NULL;
    assert(scope_stack);

    if (!scope_stack->count) {
        cout << "+++ got invalid request to enforce enclosure type '" << token_name(y) << "' (@ " << function << "(), " << file << ":" << line << ")\n";
        exit(1);
    }

    assert(scope_stack->count);
    last_enclosure = stack_pop(scope_stack);
    assert(last_enclosure);
    assert(last_enclosure->type == LISTITEM_ENCLOSURE);
    switch (y) {
    case GT:
        if (last_enclosure->payload.i16 == LT) {
            alligator_scope_depth --;
            cout << " {" << alligator_scope_depth << "}>\n";
            return true;
        } else {
            cout << "+++ mismatched scope enclosure, expected '>', got '" << token_name(y) << "\n";
            return false;
        }
        return false;
        break;
    case RB:
        if (last_enclosure->payload.i16 == LB) {
            brackets_scope_depth --;
            cout << " {" << brackets_scope_depth << "})\n";
            return true;
        } else {
            cout << "+++ mismatched scope enclosure, expected ')', got '" << token_name(y) << "\n";
            return false;
        }
        return false;
        break;
    default:
        cout << "\n+++ cannot pop enclosure type '" << token_name(y) << "'\n";
        exit(1);
        break;
    }

    return false;
}


bool expect_token(int y, int x, bool halt)
{
    if (x == y) {
        return y;
    }

    /* token type did not match expected */

    cout << "\n\t+++ expected '" << token_name(x) << "', but received token '" << token_name(y) << "(" << y << ")' at file " << my_yyfilename << ":" << line_num << "\n";
    if (halt) {
        exit(1);
    }
    return y;
}

void debug_token(int y) {

    switch (y) {
    case STRING:
        //cout << "\n\tSTRING = " << yylval.sval << endl;
        cout << "\n++ debug token " << y << "(" << token_name(y) << "=" << yylval.sval << ")" << " at " << my_yyfilename << " line " << line_num << "\n";
        break;
    default:
        cout << "\n++ debug token " << y << "(" << token_name(y) << ")" << " at " << my_yyfilename << " line " << line_num << "\n";

        break;
    }



    return;
}

void invalid_token(int y, const char *function, const char *file, int line) {
    cout << "++ invalid token " << y << "(" << token_name(y) << ")"
         << " at " << my_yyfilename << " line " << line_num << " at " << function
         << "():" << file << ":" << line << endl;
    switch (y) {
    case STRING:
        cout << "\tSTRING = " << yylval.sval << endl;
        break;
    default:
        break;
    }
    exit(1);
}

int parse_nested_alligator_list_of_crap() {

    int y = 0;
    int ssd = 0;
    int fsd = 0;

    cout << " < ";
    //	cout << endl << "1alligator_scope_depth: " << alligator_scope_depth <<
    // endl;
    ssd = alligator_scope_depth;
    alligator_scope_depth++;

    y = yylex();

    while (alligator_scope_depth > ssd) {
        // cout << endl << "2alligator_scope_depth: " << alligator_scope_depth <<
        // endl; debug_token(y);
        switch (y) {
        case GLOBAL_VAR_DEREF:
            /* don't do anything */
            cout << yylval.sval << " ";
            break;
        case ESCAPED_QUOTE:
            cout << "\\\" ";
            /* don't do anything */
            break;
        case BANG:
            cout << "! ";
            /* don't do anything */
            break;
        case STRING:
            /* don't do anything */
            cout << yylval.sval << " ";
            break;
        case LT:
            cout << " < ";
            alligator_scope_depth++;
            break;
        case GT:
            cout << " > " << endl;
            alligator_scope_depth--;
            break;
        default:
            invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
            exit(1);
            break;
        }

        y = yylex();
    }
    assert(ssd = alligator_scope_depth);
    alligator_scope_depth--;
    return 1;
}

int parse_nested_bracket_list_of_crap() {

    int y = 0;
    int ssd = 0;
    int fsd = 0;

    cout << " < ";
    ssd = brackets_scope_depth;
    alligator_scope_depth++;

    y = yylex();

    while (brackets_scope_depth > ssd) {
        // cout << endl << "2alligator_scope_depth: " << alligator_scope_depth <<
        // endl; debug_token(y);
        switch (y) {
        case STRING_LITERAL:
            cout << yylval.sval << " ";
            break;
        case GLOBAL_VAR_DEREF:
            /* don't do anything */
            cout << yylval.sval << " ";
            break;
        case ESCAPED_QUOTE:
            cout << "\\\" ";
            /* don't do anything */
            break;
        case BANG:
            cout << "! ";
            /* don't do anything */
            break;
        case STRING:
            /* don't do anything */
            cout << yylval.sval << " ";
            break;
        case LB:
            cout << " ( ";
            brackets_scope_depth++;
            break;
        case RB:
            cout << " ) " << endl;
            brackets_scope_depth--;
            break;

        default:
            invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
            exit(1);
            break;
        }

        y = yylex();
    }
    cout << "ssd=" << ssd << ", brackets_scope_depth=" << brackets_scope_depth << endl;
    assert(ssd == brackets_scope_depth);
    brackets_scope_depth--;
    return 1;
}




int parse_insert_file() {
    FILE *nfh = NULL;
    _fileref *fr = NULL;
    char new_full_file_name[MAX_STRING];
    char *working_path = NULL;
    char *filename = NULL;
    char *p = (char *) &new_full_file_name;
    int y = 0;
    y = yylex();
    assert(y == STRING_LITERAL);
    cout << "INSERT-FILE " << yylval.sval << " ";
    working_path=dirname(strdup(my_yyfilename));

    /* dont know what this third argument is for yet */

    /* WARNING: leaks */
    memset(&new_full_file_name, 0, MAX_STRING);
    strncat(p, working_path, strlen(working_path));
    p+=strlen(working_path);

    filename = strdup(dequote(yylval.sval));
    filename = strdup(lowercase(filename));
    strncat(p, "/", 2);
    p+=1;
    strncat(p, filename, strlen(filename));
    p+=strlen(filename);
    strncat(p, ".zil", 5);
    p+=4;
    cout << "[" << new_full_file_name << "] ";

    y = yylex();
    assert(y == STRING);
    assert(yylval.sval[0] == 'T' && strlen(yylval.sval) == 1);
    cout << "T";
    y = yylex();
    assert(y == GT);
    alligator_scope_depth--;
    cout << ">" << endl;

    /* create new fileref */

    fr = (struct _fileref*) malloc(sizeof(struct _fileref));
    memset(fr, 0, sizeof(struct _fileref));
    fr->filename=strdup(my_yyfilename);
    fr->line_num = line_num;
    fr->handle = current_fh;
    fr->offset = ftell(current_fh);
    //fr->buffer_state = yy_create_buffer(fr->handle, YY_BUF_SIZE);
    //fr->buffer_state = buffer_state;
    fr->buffer_state = get_yy_current_buffer();

    //buffer_state = yy_create_buffer( current_fh, YY_BUF_SIZE ));

    stackitem* nsi = stackitem_new();
    assert(nsi);
    nsi->type = LISTITEM_FILEREF;
    memcpy(&nsi->payload.fr, fr, sizeof(struct _fileref));
    assert(nsi->payload.fr.offset == fr->offset);
    assert(nsi->payload.fr.handle == fr->handle);
    assert(nsi->payload.fr.line_num == fr->line_num);
    assert(stack_push(file_stack, nsi));

    //cout << "old_filehandle: " << current_fh << endl;
    current_fh = NULL;
    current_fh = fopen(new_full_file_name, "r");
    assert(current_fh);
    my_yyfilename = strdup(new_full_file_name);
    line_num = 0;


    //cout << "+++ switched to input file " << new_full_file_name << endl;
    yyset_in(current_fh);
    yyin = current_fh;

    buffer_state = yy_create_buffer( current_fh, YY_BUF_SIZE );
    yy_switch_to_buffer( buffer_state);

    // cout << "new_filehandle: " << current_fh << endl;
    y= yylex();
    parse_recursive(y);
    return 1;
}

int parse_princ() {
    int y = 0;
    y = yylex();
    assert(y == STRING_LITERAL);
    cout << "PRINC " << yylval.sval ;
    return 1;
}

int parse_or() {
    /* this looks complicated */

    int y = 0;
    assert(alligator_scope_depth == 1);

    cout << "OR ";

    y = yylex();
    while (alligator_scope_depth > 0) {

        switch (y) {
        /* fallthrough */
        case GLOBAL_VAR_DEREF:
            cout << "{" << yylval.sval << "} ";
            break;
        case STRING_LITERAL:
            cout << "{STRING_LITERAL=[" << yylval.sval << "]} ";
            break;
        case STRING:
            cout << "{STRING=[" << yylval.sval << "]} ";
            break;
        case GT:
            enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__);
            break;
        case RB:
            enforce_enclosure_type(RB, __FUNCTION__, __FILE__, __LINE__);
            break;
        case LT:
            push_enclosure_type(LT);
            break;
        case LB:
            push_enclosure_type(LB);
            break;
        default:
            cout << "{" << token_name(y) << "} ";
            break;
        }

        y = yylex();
    }

    assert(NULL);
    return 1;
}

int parse_set() {

    /* set global variable (character?) */

    int y = 0;
    assert(alligator_scope_depth == 1);
    y = yylex();
    assert(y == STRING);
    cout << "SET [" << yylval.sval << "] ";
    y = yylex();
    assert(y == STRING);
    cout << yylval.sval;
    y = yylex();
    if (!enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__)) {
        cout << "can't enforce enclosure type '" << token_name(GT) << "'\n";
        assert(NULL);
    }

    assert(y == GT);
    return 1;
}


int parse_defmac() {

    /* set global variable (integer?) */

    int y = 0;
    assert(alligator_scope_depth >= 0);
    y = yylex();
    switch(y) {
    case QUESTION:
        break;
    case STRING:
        break;
    default:
        cout << "parse_defmac: invalid argument #1" << endl;
        exit(1);
    }

    cout << "DEFMAC [" << yylval.sval << "] ";
    y = yylex();

    switch (y) {
    case LB:
        parse_nested_bracket_list_of_crap();
        break;
    case LT:
        /* stream of random crap */
        parse_nested_alligator_list_of_crap();
        break;

    default:
        invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
        exit(1);
        break;
    }

    return 1;
}

int parse_setg() {

    /* set global variable (integer?) */

    int y = 0;
    assert(alligator_scope_depth >= 0);
    y = yylex();
    switch(y) {
    case QUESTION:
        break;
    case STRING:
        break;
    default:
        cout << "parse_setg: invalid argument #1" << endl;
        exit(1);
    }


    cout << "SETG [" << yylval.sval << "] ";
    y = yylex();

    switch (y) {
    case INT:
        assert(y == INT);
        cout << yylval.ival;
        y = yylex();
        if (!enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__)) {
            cout << "can't enforce enclosure type '" << token_name(GT) << "'\n";
            assert(NULL);
        }
        break;
    case LT:
        /* stream of random crap */
        parse_nested_alligator_list_of_crap();
        assert(NULL);
        break;

    default:
        invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
        exit(1);
        break;
    }

    return 1;
}

int parse_version() {
    /* set VERSION - no idea what this is for, backend maybe? */

    int y = 0;
    assert(alligator_scope_depth == 1);
    y = yylex();
    assert(y == STRING);
    cout << "VERSION [" << yylval.sval << "]";
    y = yylex();
    expect_token(y, GT, true);
    assert(y == GT);
    if (!enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__)) {
        cout << "can't enforce enclosure type '" << token_name(GT) << "'\n";
        assert(NULL);
    };

    return 1;
}

int parse_main() {

    assert(alligator_scope_depth == 0);
    assert(brackets_scope_depth == 0);
    assert(current_context == CONTEXT_GLOBAL);

    file_stack = stack_new();
    assert(file_stack);
    file_stack->label = (const char *) "open filehandles list";
    scope_stack = stack_new();
    assert(scope_stack);
    scope_stack->label = (const char *) "open scoping list";

    buffer_state = yy_create_buffer( current_fh, YY_BUF_SIZE );

    yy_switch_to_buffer(buffer_state);

    int y = yylex();
    return parse_recursive(y);
}

int parse_recursive(int y) {


    /* get first token in stream */

    while (1) {

        if (brackets_scope_depth < 0) {
            cout << "FATAL: brackets_scope_depth: " << brackets_scope_depth << endl;
            exit(1);
        }

        assert(alligator_scope_depth >= 0);
        assert(brackets_scope_depth >= 0);
        assert(current_context == CONTEXT_GLOBAL);

        //cout << "current position in " << my_yyfilename << " is " << ftell(current_fh) << endl;

        switch (y) {



        case MYEOF:
            /* if this is the last file in the chain, exit on EOF, otherwise pop the most recent file off the stack and continue processing */
            //cout << "[???] file_stack->count = " << file_stack->count << endl;
            if (!file_stack->count) {
                /* all files on stack have been processed, and we have hit the end of the input */
                //cout << "[***] Input completed. " << endl;
                exit(0);
            } else {
                /* there are files remaining on the stack, pop the last one and continue */
                //cout << "[***] error need to switch back" << endl;
                cout << "* (file stack depth is currently " << file_stack->count << "; ";
                stackitem* lsi = stack_pop(file_stack);
                assert(lsi);
                assert(lsi->type == LISTITEM_FILEREF);
                assert(lsi->payload.fr.buffer_state);
                //cout << "filename: " << lsi->payload.fr.filename << endl;
                //cout << "offset: " << lsi->payload.fr.offset << endl;
                //cout << "line_number: " << lsi->payload.fr.line_num << endl;
                my_yyfilename = strdup(lsi->payload.fr.filename);
                current_fh = lsi->payload.fr.handle;
                line_num = lsi->payload.fr.line_num;
                cout << "switching back to " << my_yyfilename << ", line " << line_num <<  ")" << endl;
                //fseek(current_fh, SEEK_SET, lsi->payload.fr.offset);
                yyset_in(current_fh);
                yyin = current_fh;
                //yyrestart(current_fh);
                yy_switch_to_buffer( lsi->payload.fr.buffer_state);
                //yyrestart(current_fh);
                y = yylex();
                parse_recursive(y);
                //invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
            }
            break;


        case QUESTION:
            cout << "QUESTION [" << yylval.sval << "]" ;
            break;

        case INSERT_FILE:
            if (!parse_insert_file()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            }
            break;

        case DEFMAC:
            if (!parse_defmac()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            }

        case PRINC:
            if (!parse_princ()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            }
            break;

        case OR:
            assert(alligator_scope_depth == 1);
            if (!parse_or()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            };
            assert(alligator_scope_depth == 0);
            break;

        case SET:
            assert(alligator_scope_depth == 1);
            if (!parse_set()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            };
            assert(alligator_scope_depth == 0);
            break;

        case SETG:
            assert(alligator_scope_depth >= 1);
            if (!parse_setg()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            };
            assert(alligator_scope_depth >= 0);
            break;

        case VERSION:
            assert(alligator_scope_depth == 1);
            if (!parse_version()) {
                cout << "Fatal error" << endl;
                assert(NULL);
            };
            //assert(alligator_scope_depth == 0);
            break;




        case LT:
            push_enclosure_type(LT);
            break;

        case GT:
            if (!enforce_enclosure_type(GT, __FUNCTION__, __FILE__, __LINE__)) {
                cout << "can't enforce enclosure type '" << token_name(GT) << "'\n";
                assert(NULL);
            }
            break;


        case LB:
            push_enclosure_type(LB);
            break;

        case RB:
            if (!enforce_enclosure_type(RB, __FUNCTION__, __FILE__, __LINE__)) {
                cout << "can't enforce enclosure type '" << token_name(LB) << "'\n";
                assert(NULL);
            }
            break;


        case STRING_LITERAL:
            assert(current_context == CONTEXT_GLOBAL);
            cout << yylval.sval << endl;
            break;

        default:
            invalid_token(y, __FUNCTION__, __FILE__, __LINE__);
            break;
        }

        /* get next token in stream */
        y = yylex();
    }

    return 0;
}
