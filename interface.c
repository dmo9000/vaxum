#include <cassert>
#include <iostream>
#include <string.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"
#include "flex.h"
#include "tree.h"
#include "interface.h"

using namespace std;

extern int parse_recursive(int);


extern int yylex();
extern YYSTYPE yylval;
extern FILE *current_fh;
extern int yyset_in(FILE *);
extern FILE *yyin;
extern int yyrestart(FILE *);
extern YY_BUFFER_STATE get_yy_current_buffer();
extern YY_BUFFER_STATE buffer_state;


extern FILE *current_fh;
extern const char *my_yyfilename;
extern int line_num;


int parse_interface(int );

int parse_interface(int y)
{
    switch (y) {
    case STRING:
        //cout << "TOKEN: " << y << ":" << token_name(y) << ":" << yylval.sval << endl << flush;
        return 0;
        break;
    default:
        cout << "TOKEN: " << y << ":" << token_name(y) << endl;
        return 0;
        break;
    }

    return 1;
}

void run_interface()
{

    int y = 0;
    cout << "run_interface()\n" << flush;

    current_fh = stdin;
    assert(current_fh);
    my_yyfilename = strdup("<STDIN>");
    line_num = 1;

    yyset_in(current_fh);
    yyin = current_fh;

    buffer_state = yy_create_buffer( current_fh, YY_BUF_SIZE );
    yy_switch_to_buffer( buffer_state);

    cerr << "# Entering interactive mode " << my_yyfilename << " ... \n" << flush;

    cerr << "> " << flush;
    y= yylex();
    while (1) {
        while (y != LF) {
                if (y == MYEOF) {
                        cout << "\n*** Exiting interactive mode.\n" << flush; 
                        exit(0);
                }
            if (!parse_interface(y)) {
                cerr << "syntax error at line num " << line_num << endl << flush;
                while (y != LF) {
                    y= yylex();
                }

            }
        }
        cerr << "> " << flush;
        y = yylex();
    }


    return;
}
