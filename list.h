#pragma once
#include <cstdio>

enum _listitemtype {
		  LISTITEM_FILE,
		  LISTITEM_INT16,
		  LISTITEM_STRING
		  };

union _listpayload {
			FILE *fh;
			int16_t i16;
			char *str;
		   };


struct _1listitem {
		 char *label;
		 struct _listitem *next;
		_listitemtype t;
		 };

struct _2listitem {
		 char *label;
		 struct _listitem *prev;
		 struct _listitem *next;
		_listitemtype t;
		 };

struct _singly_linked_list {
		uint32_t count;
		struct _1listitem *head;
		};

struct _doubly_linked_list {
		uint32_t count;
		struct _2listitem *head;
		struct _2listitem *tail;
		};


