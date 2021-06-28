#pragma once
#include <cstdio>
#include "flex.h"

struct _fileref {
    char *filename;
    int line_num;
    FILE *handle;
    off_t offset;
	YY_BUFFER_STATE buffer_state;
};


enum _listitemtype {
    LISTITEM_UNKNOWN,
    LISTITEM_FILEREF,
    LISTITEM_INT16,
    LISTITEM_STRING,
	LISTITEM_ENCLOSURE

};

union _listitempayload {
    struct _fileref fr;
    int16_t i16;
    char *str;
};

struct _1listitem {
    const char *label;
    struct _1listitem *next;
    _listitemtype type;
    _listitempayload payload;
};

struct _2listitem {
    const char *label;
    struct _2listitem *prev;
    struct _2listitem *next;
    _listitemtype type;
    _listitempayload payload;
};

struct _singly_linked_list {
    const char *label;
    uint32_t count;
    struct _1listitem *head;
};

struct _doubly_linked_list {
    const char *label;
    uint32_t count;
    struct _2listitem *head;
    struct _2listitem *tail;
};



typedef struct _1listitem singly_linked_listitem;
typedef struct _2listitem doubly_linked_listitem;
typedef struct _singly_linked_list singly_linked_list;
typedef struct _doubly_linked_list doubly_linked_list;


doubly_linked_listitem* new_doubly_linked_listitem();