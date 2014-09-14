//var DotGraph = require("..").DotGraph,
//    Graph = require("graphlib").Graph;

dotGraphTest() {
  group("DotGraph", () {
    abstractDotifyTest("DotGraph", DotGraph, "Graph", Graph);
  });
}