#include "tree.h"



tree* tree_new(const char *label)
{
	tree *nt = NULL;
	assert(label);
	nt = (tree *) malloc(sizeof(tree));
	assert(nt);
	memset(nt, 0, sizeof(tree));
	nt->label = strdup(label);
	return nt;
}
