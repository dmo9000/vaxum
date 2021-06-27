#include "list.h"

typedef struct _doubly_linked_list stack;
typedef struct _2listitem stackitem;

stack *stack_new();
bool stack_push(stack*, stackitem*);

stackitem *stackitem_new();

