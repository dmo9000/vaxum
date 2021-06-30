#include <cstdlib>
#include <cstring>
#include <cassert>
#include "list.h"

doubly_linked_listitem* new_doubly_linked_listitem()
{
    doubly_linked_listitem* ndlli = NULL;
    ndlli = (doubly_linked_listitem*) malloc(sizeof(doubly_linked_listitem));
    assert(ndlli);
    memset(ndlli, 0, sizeof(doubly_linked_listitem));
    ndlli->label = NULL;;
    ndlli->prev = NULL;
    ndlli->next = NULL;
    ndlli->type = LISTITEM_UNKNOWN;
    return(ndlli);
}
