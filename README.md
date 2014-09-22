# graphlib_dot

A DOT language parser / writer for [graphlib](https://pub.dartlang.org/packages/graphlib).
Ported to Dart from [graphlib-dot](https://github.com/cpettitt/graphlib-dot)
by [Richard Lincoln](http://git.io/rwl).

# Example

```dart
var file = new File('your-dot-file.dot');
var graph = dot.parse(file.readAsStringSync());
// You can pass `graph` to dagre or some other graphlib compatible
// graph library.

// You can also write a graph to a graphviz string.
print(dot.write(graph))
```

# API

## Graph Objects

This library introduces two new types of graphs:

1. `DotGraph`
2. `DotDigraph`

These graphs differ from the graphlib compound graphs in that they always contain
an Map for their value. This is similar to how attributes work with graphs
in graphviz.

It is possible to serialize regular graphlib graphs provided the values used
for nodes, edges, and subgraphs are either `null` or are Maps.

## Functions

### parse(str)

Parses a single DOT graph from the `str` and returns it as one of:

* `DotDigraph` if the input graph is `digraph`
* `DotGraph` if the input graph is a `graph`

```dart
var digraph = dot.parse("digraph { 1; 2; 1 -> 2 [label="label"] }");
digraph.nodes();
// => [ 1, 2 ]

digraph.edge(digraph.edges()[0]);
// => { label: "label", id: /* unique id here */ }
```

This function treats subgraphs in the input as nodes in the final DOT graph,
which will have one or more children. Empty subgraphs in the input are not
included in the final graph.

```dart
var digraph = dot.parse("digraph { 1; 2; subgraph X { 3; 4 }; subgraph Y {} }");
digraph.nodes();
// => [ 1, 2, 3, 4, "X" ]
// Note in particular that "Y" was not included because it was empty.

digraph.children(null);
// => [ 1, 2, "X" ]
// Note that `null` represents the root graph.

digraph.children("X");
// => [ 3, 4 ]
```

Defaults in the input graph are applied to objects (`node`, `edge`, `graph`) as
described by the rules of the DOT language. However, the default information
itself is not preserved during the parsing process. Graphviz's DOT also loses
default information under most circumstances; however we've opted to make it
consistently always the case.

Also, unless otherwise specified we automatically add a label attribute to
each node that uses the node's id.

```dart
var digraph = dot.parse("digraph { 1; node [foo=bar]; 2 }");
digraph.nodes();
// => [ 1, 2 ]

digraph.node(1);
// => { label: "1" }

digraph.node(2);
// => { label: "2", foo: "bar" }
```

### parseMany(str)

Parses one or more DOT graphs from `str` in a manner similar to that used
by parse for individual graphs.

```dart
List digraphs = dot.parseMany("digraph { 1; 2; 1 -> 2 [label=\"label\"] }\n" +
                             "digraph { A; B; }");
digraphs.length;
// => 2
```

### write(graph)

Writes a `String` representation of the given `graph` in the DOT language.

```dart
var digraph = new Digraph();
digraph.addNode(1);
digraph.addNode(2);
digraph.addEdge("A", 1, 2, { label: "A label" });
print(dot.write(digraph));
// Prints:
//
//  digraph {
//      1
//      2
//      1 -> 2 ["label"="A label"]
//  }
```

# Limitations

* The parser does not work for HTML strings.
* The parser ignores port and compass statements when handling node statements.
  For example, a node `a:port:nw [attr1=val]' will be treated as though it were
  defined `a [attr1=val]`.
* Defaults are expanded during parsing and are otherwise not preserved. This is
  similar to the behavior exhibited by `dot`.

# License

graphlib_dot is licensed under the terms of the MIT License. See the LICENSE file
for details.
