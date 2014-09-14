part of graphlib.dot;
//var CGraph = require("graphlib").CGraph,
//    dotify = require("./dotify");

class DotGraph extends CGraph with Dotify {

  DotGraph() : super();

//module.exports = DotGraph;

  fromGraph(src) {
    var g = new DotGraph(),
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
