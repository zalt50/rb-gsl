/////////////////////////////////////////////////////////////////////
// = NMatrix
//
// A linear algebra library for scientific computation in Ruby.
// NMatrix is part of SciRuby.
//
// NMatrix was originally inspired by and derived from NArray, by
// Masahiro Tanaka: http://narray.rubyforge.org
//
// == Copyright Information
//
// SciRuby is Copyright (c) 2010 - 2012, Ruby Science Foundation
// NMatrix is Copyright (c) 2012, Ruby Science Foundation
//
// Please see LICENSE.txt for additional copyright notices.
//
// == Contributing
//
// By contributing source code to SciRuby, you agree to be bound by
// our Contributor Agreement:
//
// * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
//
// == sl_list.h
//
// Singly-linked list implementation

#ifndef SL_LIST_H
#define SL_LIST_H

/*
 * Standard Includes
 */

#include <stdlib.h>

/*
 * Project Includes
 */

#include "types.h"

#include "data/data.h"

/*
 * Macros
 */

/*
 * Types
 */

/* Singly-linked ordered list
 * - holds keys and values
 * - no duplicate keys
 * - keys are ordered
 * - values may be lists themselves
 */
typedef struct l_node {
  size_t key;
  void*  val;
  struct l_node* next;
} NODE;

typedef struct {
  NODE* first;
} LIST;

/*
 * Data
 */
 

/*
 * Functions
 */
 
////////////////
// Lifecycle //
///////////////

LIST*	list_create(void);
void	list_delete(LIST* list, size_t recursions);
void	list_mark(LIST* list, size_t recursions);

///////////////
// Accessors //
///////////////

NODE* list_insert(LIST* list, bool replace, size_t key, void* val);
NODE* list_insert_after(NODE* node, size_t key, void* val);
void* list_remove(LIST* list, size_t key);

///////////
// Tests //
///////////

template <typename LDType, typename RDType>
bool list_eqeq_list_template(const LIST* left, const LIST* right, const void* left_val, const void* right_val, size_t recursions, size_t* checked);

template <typename LDType, typename RDType>
bool list_eqeq_value_template(const LIST* l, const void* v, size_t recursions, size_t* checked);

/////////////
// Utility //
/////////////

NODE* list_find(LIST* list, size_t key);
NODE* list_find_preceding_from(NODE* prev, size_t key);
NODE* list_find_nearest(LIST* list, size_t key);
NODE* list_find_nearest_from(NODE* prev, size_t key);

/////////////////////////
// Copying and Casting //
/////////////////////////

void list_cast_copy_contents(LIST* lhs, LIST* rhs, dtype_t lhs_dtype, dtype_t rhs_dtype, size_t recursions);

#endif // SL_LIST_H
