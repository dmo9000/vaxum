#include <cstdio>
#include <iostream>
#include <cassert>
#include <string.h>
#include <getopt.h>
#include "parser.h"

int gdl = 0;
using namespace std;

char *my_yyfilename;
extern int flex_main();
extern FILE *yyin;
extern int yyset_in(FILE *);
FILE *current_fh;
extern YYSTYPE yylval;

extern bool ansi_colour;







int main(int argc, char *argv[])
{
    int c = 0;

    cout << "Vaxum ZIL Compiler Ver 0.2" << endl << endl;



    for(;;)
    {
        switch(getopt(argc, argv, "d:axh")) // note the colon (:) to indicate that 'b' has a parameter and is not a switch
        {
        case 'd':
            //cout << "Global debug level is set to " << optarg << "\n";
            gdl = atoi(optarg);
            continue;

        case 'a':
            /* ansi colour enabled */
            ansi_colour = true;
            continue;
        case '?':
        case 'h':
        default :
            printf("Help/Usage Example\n");
            break;

        case -1:
            break;
        }

        break;
    }

    //cout << "optind = " << optind << ", argc = " << argc << "\n";

    if (!(argc == optind + 1)) {
        cout << "fatal - you must specify an input file\n";
        exit(251);
    }

    while (optind < argc) {
        //cout << "input file: " << argv[optind] << "\n";
        my_yyfilename = strdup(argv[optind]);
        optind ++;
    }
    //cout << "opening file '" <<  my_yyfilename << "'" << endl;

    current_fh = fopen(my_yyfilename, "r");
    if (!current_fh) {
        cout << "cannot open file '" <<  my_yyfilename << "'" << endl;
        exit(250);
    }

    yyset_in(current_fh);
    parse_main();
    fclose(current_fh);
    exit(128);

    int exit_code = 0;
    exit(exit_code);
}
