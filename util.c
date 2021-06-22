#include <cstdio>
#include <iostream>
#include <cassert>
#include <string.h>
using namespace std;

#define MAX_LINELEN 65536

char * print_line_from_file(FILE *x, int line_num)
{
    int i = 0;
    static char line[MAX_LINELEN];
    assert(x != NULL);
    assert(line_num);
    fseek(x, 0, SEEK_SET);
    for (i = 0; i < line_num; i++) {
	memset(&line, 0, MAX_LINELEN);
	fgets((char *) &line, MAX_LINELEN - 1, x);
    	}
    cout << "<***> " << line << endl; 
    return (char *) &line;
}

int count_char_instance(char *s, char c)
{
	int i = 0;
	while (s[0] != '\0') {
		if (s[0] == c) {
			i++;
			}	
		s++;
		}
	//cout << "(" << i << "instances found" << endl;
	return i;
}

void insert_indent(int l)
{
   int i = 0;
   for (i = 0; i < l; i++) {
        putchar(' ');
        putchar(' ');
        }
   return;
}

