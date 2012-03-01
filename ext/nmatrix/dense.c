#ifndef DENSE_C
#define DENSE_C

#include <ruby.h>

#include "nmatrix.h"


/* Calculate the number of elements in the dense storage structure, based on shape and rank */
size_t count_dense_storage_elements(DENSE_STORAGE* s) {
  size_t i;
  size_t count = 1;
  for (i = 0; i < s->rank; ++i) count *= s->shape[i];
  return count;
}


size_t dense_storage_pos(DENSE_STORAGE* s, size_t* coords) {
  size_t k, l;
  size_t inner, outer = 0;
  for (k = 0; k < s->rank; ++k) {
    inner = coords[k];
    for (l = k+1; l < s->rank; ++l) {
      inner *= s->shape[l];
    }
    outer += inner;
  }
  return outer;
}


void* dense_storage_get(DENSE_STORAGE* s, size_t* coords) {
  return (char*)(s->elements) + dense_storage_pos(s, coords) * nm_sizeof[s->dtype];
}


/* Does not free passed-in value! Different from list_storage_insert. */
void dense_storage_set(DENSE_STORAGE* s, size_t* coords, void* val) {
  memcpy((char*)(s->elements) + dense_storage_pos(s, coords) * nm_sizeof[s->dtype], val, nm_sizeof[s->dtype]);
}


DENSE_STORAGE* copy_dense_storage(DENSE_STORAGE* rhs) {
  DENSE_STORAGE* lhs;
  size_t count = count_dense_storage_elements(rhs), p;
  size_t* shape = malloc(nm_sizeof[rhs->dtype] * rhs->rank);
  if (!shape) return NULL;

  // copy shape array
  for (p = 0; p < rhs->rank; ++p)
    shape[p] = rhs->shape[p];

  //fprintf(stderr, "copy_dense_storage\n");

  lhs = create_dense_storage(rhs->dtype, shape, rhs->rank, NULL, 0);

  if (lhs && count) // ensure that allocation worked before copying
    memcpy(lhs->elements, rhs->elements, nm_sizeof[rhs->dtype] * count);

  return lhs;
}


// Note that elements and elements_length are for initial value(s) passed in. If they are the correct length, they will
// be used directly. If not, they will be concatenated over and over again into a new elements array. If elements is NULL,
// the new elements array will not be initialized.
DENSE_STORAGE* create_dense_storage(int8_t dtype, size_t* shape, size_t rank, void* elements, size_t elements_length) {
  DENSE_STORAGE* s;
  size_t count, i, copy_length = elements_length;

  if (!(s = malloc(sizeof(DENSE_STORAGE)))) return NULL;
  s->rank       = rank;
  s->shape      = shape;
  s->dtype      = dtype;

  //fprintf(stderr, "create_dense_storage: %p\n", s);

  count         = count_dense_storage_elements(s);
  //fprintf(stderr, "count_dense_storage_elements: %d\n", count);

  if (elements_length == count) s->elements = elements;
  else if (!(s->elements   = malloc(nm_sizeof[dtype] * count))) {
    // allocation failed
    free(s->shape);
    free(s);
    s = NULL;
  } else {
    // allocation succeeded

    if (elements_length > 0) {
      // repeat elements over and over again until the end of the matrix
      for (i = 0; i < count; i += elements_length) {
        if (i + elements_length > count) copy_length = count - i;
        memcpy((char*)(s->elements)+i*nm_sizeof[dtype], (char*)(elements)+(i % elements_length)*nm_sizeof[dtype], copy_length*nm_sizeof[dtype]);
      }

      // get rid of the init_val
      free(elements);
    }
  }

  return s;
}


void delete_dense_storage(DENSE_STORAGE* s) {
  if (s) { // sometimes Ruby passes in NULL storage for some reason (probably on copy construction failure)
    free(s->shape);
    free(s->elements);
    free(s);
  }
}



#endif