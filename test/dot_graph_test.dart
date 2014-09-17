part of graphlib.dot.test;

dotGraphTest() {
  group("DotGraph", () {
    abstractDotifyTest("DotGraph", () => new dot.DotGraph(), "Graph", () => new Graph());
  });
}