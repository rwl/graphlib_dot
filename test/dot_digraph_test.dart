//var DotDigraph = require("..").DotDigraph,
//    Digraph = require("graphlib").Digraph;

dotDigraphTest() {
  group("DotDigraph", () {
    abstractDotifyTest("DotDigraph", DotDigraph, "Digraph", Digraph);
  });
}