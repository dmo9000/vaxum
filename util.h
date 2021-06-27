#include "list.h"
#include "contexts.h"


#define MAX_STRING 65536

char * print_line_from_file(FILE *, int);
int count_char_instance(char *, char);
void insert_indent(int l);
char *dequote(char *);
char *lowercase(char *);
