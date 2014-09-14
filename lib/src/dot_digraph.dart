part of graphlib.dot;

//var CDigraph = require("graphlib").CDigraph,
//    dotify = require("./dotify");

class DotDigraph extends CDigraph with Dotify {

  DotDigraph() : super();

//module.exports = DotDigraph;

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
}