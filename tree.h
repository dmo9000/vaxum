#pragma once
#include <iostream>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cassert>

enum _treeitemtype {
    TREEITEM_NULL,
    TREEITEM_INT16,
    TREEITEM_INT32,
    TREEITEM_STRING,
    TREEITEM_SUBTREE, 
    TREEITEM_UNKNOWN
};

union _treeitempayload {
    int16_t i16;
    int32_t i32;
    char *str;
    struct _tree *t;
};

struct _treeitem {
    const char *label;
    struct _treeitem *parent;
    struct _treeitem *left;
    struct _treeitem *right;
    _treeitemtype type;
    _treeitempayload payload;
};

struct _tree {
    const char *label;
    uint32_t count;
    struct _treeitem *root;
};

typedef struct _treeitem treeitem;
typedef struct _tree tree;


tree* tree_new(const char *);