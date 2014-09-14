part of graphlib.dot;

// Returns an array of all values for properties of **o**.
values(o) {
  return Object.keys(o).map((k) { return o[k]; });
}
