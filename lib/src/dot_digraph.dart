part of graphlib.dot;

//var CDigraph = require("graphlib").CDigraph,
//    dotify = require("./dotify");

class DotDigraph extends CDigraph {//with Dotify {

  DotDigraph() : super() {
    this.graph({});
  }

  fromDigraph(src) {
    var g = new DotDigraph(),
        graphValue = src.graph();

    if (graphValue != null) {
      g.graph(graphValue);
    }

    src.eachNode((u, value) {
      if (value == null) {
        g.addNode(u);
      } else {
        g.addNode(u, value);
      }
    });
    src.eachEdge((e, u, v, value) {
      if (value == null) {
        g.addEdge(null, u, v);
      } else {
        g.addEdge(null, u, v, value);
      }
    });
    return g;
  }

  graph([Map value=null]) => super.graph(value);

  node(u, [Map value=null]) => super.node(u, value);

  addNode([u, Map value=null]) {
    if (value == null) value = {};
    return super.addNode(u, value);
  }

  edge(e, [Map value=null]) => super.edge(e, value);

  addEdge(e, u, v, [Map value=null]) {
    if (value == null) value = {};
    return super.addEdge(e, u, v, value);
  }
}