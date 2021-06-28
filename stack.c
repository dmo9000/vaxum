#include <cassert>
#include <iostream>
#include <cstdbool>
#include <string.h>
#include "libgen.h"
#include "parser.h"
#include "list.h"
#include "stack.h"

using namespace std;

stack *stack_new()
{
    stack *ns = NULL;
    ns = (stack*) malloc(sizeof(stack));
    memset(ns, 0, sizeof(stack));
    assert(ns);
    ns->count = 0;
    ns->head = NULL;
    ns->tail = NULL;
    return ns;
}


stackitem *stackitem_new()
{
    return (stackitem*) new_doubly_linked_listitem();
}

stackitem* stack_pop(stack *s)
{

    stackitem *lsi = NULL;

    if (!s->count) {
            /* can't pop item from empty stack */
            assert(s->head == NULL);
            assert(s->tail == NULL);
            return NULL;
    }

    lsi = (stackitem *) s->head;
    lsi->prev = NULL;
    lsi->next = NULL;

    s->count --;
    assert(s->count >= 0);

    if (s->count > 0) {
        s->head = lsi->next;
        s->head->prev = NULL;
        assert(lsi->next);
    } else {
        s->head = NULL;
        s->tail = NULL;     
    }
    cout << "\n<stack_pop " << s->label << ":stack_size=" << s->count << ">\n";
    return lsi;
}


bool stack_push(stack* s, stackitem* si)
{

    /* stack is valid */

    assert(s);

    /*
    if (s->label) {
        cout << "+++ stack_push(" << s->label << ", count=" << s->count << "-> " << s->count+1 << ")";
        if (si->label) {
            cout << ":" << si->label << endl;
        } else {
            cout << endl;
        }
    }
    */

    /* if stack has zero count, verify that head/tail links are NULL too */

    if (!s->count) {
        assert(s->head == NULL);
        assert(s->tail == NULL);
        /* first item is a special case, insert it */
        s->head = si;
        s->tail = si;
        s->count++;
        cout << "\n<stack_push " << s->label << ":stack_size=" << s->count << ">\n";
        return true;
    }

    /* otherwise stack already has head/tail links */

    assert (s->head);
    assert (s->tail);

    /* link the previously first item to this one */

    si->next = s->head;
    s->head->prev = si;
    s->head = si;
    s->count++;

    cout << "\n<stack_push " << s->label << ":stack_size=" << s->count << ">\n";
    return true;
}
