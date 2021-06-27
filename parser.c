#include <cassert>
#include <iostream>
#include <string.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"

using namespace std;

extern int yylex();
extern YYSTYPE yylval;
extern FILE *current_fh;
extern int yyset_in(FILE *);
extern FILE *yyin;
extern int yyrestart(FILE *);

int alligator_scope_depth = 0;
int brackets_scope_depth = 0;

extern char *my_yyfilename;
extern int line_num;
ZIL_Context current_context = CONTEXT_GLOBAL;


stack *file_stack = NULL;
stack *scope_stack = NULL;

int parse_recursive(int);
int parse_or();
int parse_set();
int parse_setg();

void debug_token(int y) {
    cout << "++ debug token " << y << "(" << token_name(y) << ")"
         << " at " << my_yyfilename << " line " << line_num;
    switch (y) {
    case STRING:
        cout << "\n\tSTRING = " << yylval.sval << endl;
        break;
    default:
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

    stackitem* nsi = stackitem_new();
    assert(nsi);
    nsi->type = LISTITEM_FILEREF;
    memcpy(&nsi->payload.fr, fr, sizeof(struct _fileref));
    assert(nsi->payload.fr.offset == fr->offset);
    assert(nsi->payload.fr.handle == fr->handle);
    assert(nsi->payload.fr.line_num == fr->line_num);
    assert(stack_push(file_stack, nsi));

    cout << "old_filehandle: " << current_fh << endl;
    current_fh = NULL;
    current_fh = fopen(new_full_file_name, "r");
    assert(current_fh);
    my_yyfilename = strdup(new_full_file_name);
    line_num = 0;

    cout << "+++ switched to input file " << new_full_file_name << endl;
    yyset_in(current_fh);
    yyin = current_fh;

    yyrestart(current_fh);

    cout << "new_filehandle: " << current_fh << endl;
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
    y = yylex();
    assert(y == LT);
    alligator_scope_depth++;
    cout << "<OR <";
    y = yylex();
    assert(y == GASSIGNED_QUESTION);
    cout << "GASSIGN? ";
    y = yylex();
    assert(y == STRING);
    cout << yylval.sval;
    y = yylex();
    assert(y == GT);
    cout << ">";
    alligator_scope_depth--;
    y = yylex();
    assert(y == LT);
    cout << ">";
    alligator_scope_depth++;
    y = yylex();
    assert(y == SETG);
    parse_recursive(y);
    // parse_setg();
    y = yylex();
    assert(y == GT);
    alligator_scope_depth--;
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
    assert(y == GT);
    alligator_scope_depth--;
    cout << ">" << endl;
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
        assert(y == GT);
        alligator_scope_depth--;
        cout << ">" << endl;
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

int parse_version() {

    /* set VERSION - no idea what this is for, backend maybe? */

    int y = 0;
    assert(alligator_scope_depth == 1);
    y = yylex();
    assert(y == STRING);
    cout << "VERSION [" << yylval.sval << "]";
    y = yylex();
    assert(y == GT);
    alligator_scope_depth--;
    cout << ">" << endl;
    return 1;
}

int parse_main() {

    assert(alligator_scope_depth == 0);
    assert(brackets_scope_depth == 0);
    assert(current_context == CONTEXT_GLOBAL);

    file_stack = stack_new();
    assert(file_stack);
    file_stack->label = "open filehandles list";
    scope_stack = stack_new();
    assert(scope_stack);
    scope_stack->label = "open scoping list";

    int y = yylex();
    return parse_recursive(y);
}

int parse_recursive(int y) {

    /* get first token in stream */

    while (y != MYEOF) {

        assert(alligator_scope_depth >= 0);
        assert(brackets_scope_depth >= 0);
        assert(current_context == CONTEXT_GLOBAL);

        switch (y) {
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
            assert(alligator_scope_depth == 0);
            break;

        case LT:
            cout << "<";
            alligator_scope_depth++;
            break;

        case GT:
            cout << ">" << endl;
            alligator_scope_depth--;
            break;

        case STRING_LITERAL:
            assert(alligator_scope_depth == 0);
            assert(brackets_scope_depth == 0);
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
