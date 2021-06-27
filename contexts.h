#pragma once

enum ZIL_Context {
    CONTEXT_GLOBAL,
    CONTEXT_OBJECT_DEFN,
    CONTEXT_ROOM_DEFN,
    CONTEXT_ROUTINE_DEFN
};


void print_context(ZIL_Context);
