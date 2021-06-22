#include <cstdio>
#include <iostream>
#include <cassert>
#include <string.h>
using namespace std;

#define MAX_LINELEN 65536

int print_line_from_file(FILE *x, int line_num)
{
    int i = 0;
    char line[MAX_LINELEN];
    assert(x != NULL);
    assert(line_num);
    fseek(x, 0, SEEK_SET);
    for (i = 0; i < line_num; i++) {
	memset(&line, 0, MAX_LINELEN);
	fgets((char *) &line, MAX_LINELEN - 1, x);
    	}
    cout << "<***> " << line << endl; 
    return 1;
}


