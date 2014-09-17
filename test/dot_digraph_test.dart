part of graphlib.dot.test;

dotDigraphTest() {
  group("DotDigraph", () {
    abstractDotifyTest("DotDigraph", () => new dot.DotDigraph(), "Digraph", () => new Digraph());
  });
}