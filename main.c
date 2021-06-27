#include <cstdio>
#include <iostream>
#include <cassert>
#include <string.h>
#include "parser.h"

using namespace std;

char *my_yyfilename;
extern int flex_main();
extern FILE *yyin;
extern int yyset_in(FILE *);

extern YYSTYPE yylval;

int main(int argc, char *argv[]) 
{
	FILE *fd;

	cout << "New Combined ZIL Compiler Ver 0.1" << endl << endl;

	if (argc > 1) {
		my_yyfilename = strdup(argv[1]);

		cout << "opening file '" <<  my_yyfilename << "'" << endl;

		fd = fopen(argv[1], "r");
		if (!fd) {
			cout << "cannot open file '" <<  my_yyfilename << "'" << endl;
			exit(250);
			}

		yyset_in(fd);
		parse_main();
		fclose(fd);
		exit(128);
	} else { 
			cout << "no filename specified" << endl; 
			exit(1);
		}

	int exit_code = 0;
	exit(exit_code);
}
