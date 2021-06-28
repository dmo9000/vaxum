#include "list.h"

typedef struct _doubly_linked_list stack;
typedef struct _2listitem stackitem;

stack *stack_new();
bool stack_push(stack*, stackitem*);
stackitem *stack_pop(stack *);

stackitem *stackitem_new();

