part of graphlib.dot.test;

abstractDotifyTest(name, BaseGraph Constructor(), superName, SuperConstructor) {
  BaseGraph g;

  setUp(() {
    g = Constructor();
  });

  group("new $name()", () {
    test("has no nodes", () {
      expect(g.order(), equals(0));
      expect(g.nodes().length, equals(0));
      expect(g.graph(), new isInstanceOf<Map>());
    });

    test("has no edges", () {
      expect(g.size(), equals(0));
      expect(g.edges().length, equals(0));
    });
  });

  group("graph", () {
    test("only allows objects for value", () {
      expect(() { g.graph("string"); }, throws);
    });
  });

  group("addNode", () {
    test("defaults to an empty object for value", () {
      g.addNode(1);
      expect(g.node(1), equals({}));
    });

    test("only allows objects for value", () {
      g.addNode(1, {});
      expect(() { g.addNode(2, "string"); }, throws);
    });
  });

  group("node", () {
    test("only allows objects for value", () {
      g.addNode(1);
      expect(() { g.node(1, "string"); }, throws);
    });
  });

  group("addEdge", () {
    test("defaults to an empty object for value", () {
      g.addNode(1);
      g.addEdge("A", 1, 1);
      expect(g.edge("A"), equals({}));
    });

    test("only allows objects for value", () {
      g.addNode(1);
      g.addEdge("A", 1, 1, {});
      expect(() { g.addEdge("B", 1, 1, "string"); }, throws);
    });

    test("returns the id used for the edge", () {
      g.addNode(1);
      expect(g.addEdge("A", 1, 1, {}), equals("A"));
      expect(g.addEdge(null, 1, 1, {}), isNot(isNull));
    });
  });

  group("edge", () {
    test("only allows objects for value", () {
      g.addNode(1);
      g.addEdge("A", 1, 1);
      expect(() { g.edge("A", "string"); }, throws);
    });
  });

  group("copy", () {
    test("copies basic nodes and edges", () {
      g.addNode(1);
      g.addNode(2);
      g.addEdge("A", 1, 2);

      var copy = g.copy();

      expect(copy.nodes(), unorderedEquals([1, 2]));
      expect(copy.edges(), unorderedEquals(["A"]));
      expect(copy.incidentNodes("A"), unorderedEquals([1, 2]));
    });

    test("shallow copies graph values", () {
      g.graph()['foo'] = "bar";
      var copy = g.copy();

      expect(copy.graph()['foo'], equals("bar"));
      copy.graph()['foo'] = "baz";
      expect(g.graph()['foo'], equals("baz"));
    });

    test("shallow copies node values", () {
      g.addNode(1, {'foo': "bar"});
      var copy = g.copy();

      expect(copy.node(1)['foo'], equals("bar"));
      copy.node(1)['foo'] = "baz";
      expect(g.node(1)['foo'], equals("baz"));
    });

    test("shallow copies edge values", () {
      g.addNode(1);
      g.addNode(2);
      g.addEdge("A", 1, 2, { 'foo': "bar" });
      var copy = g.copy();

      expect(copy.edge("A")['foo'], equals("bar"));
      copy.edge("A")['foo'] = "baz";
      expect(g.edge("A")['foo'], equals("baz"));
    });

    test("copies subgraphs", () {
      g.addNode(1);
      g.addNode("sg1");
      g.parent(1, "sg1");
      var copy = g.copy();

      expect(copy.children("sg1"), unorderedEquals([1]));
    });
  });

  /*group("from" + superName, () {
    var fromSuper = Constructor["from" + superName];

    test("returns a " + name, () {
      var g = new SuperConstructor();
      expect(fromSuper(g), instanceOf(Constructor));
    });

    test("includes the graph value", () {
      var g = new SuperConstructor();
      g.graph({a: "a-value"});
      expect(fromSuper(g).graph(), equals({'a': "a-value"}));
    });

    test("fails to convert a graph with a non-object value", () {
      var g = new SuperConstructor();
      g.graph("foo");
      expect(() { fromSuper(g); }, throws);
    });

    test("includes nodes from the source graph", () {
      var g = new SuperConstructor();
      g.addNode(1);
      g.addNode(2);
      expect(fromSuper(g).nodes(), unorderedEquals([1, 2]));
    });

    test("includes node attributes from the source graph", () {
      var g = new SuperConstructor();
      g.addNode(1, {a: "a-value"});
      expect(fromSuper(g).node(1), equals({'a': "a-value"}));
    });

    test("fails to convert a graph with non-object node values", () {
      var g = new SuperConstructor();
      g.addNode(1, "foo");
      expect(() { fromSuper(g); }, throws);
    });

    test("includes edges from the source graph", () {
      var g = new SuperConstructor();
      g.addNode(1);
      var edgeId = g.addEdge(null, 1, 1);
      expect(fromSuper(g).edges(), unorderedEquals([edgeId]));
    });

    test("includes edge attributes from the source graph", () {
      var g = new SuperConstructor();
      g.addNode(1);
      var edgeId = g.addEdge(null, 1, 1, {'a': "a-value"});
      expect(fromSuper(g).edge(edgeId), equals({'a': "a-value"}));
    });

    test("has the same incidentNodes for edges from the source graph", () {
      var g = new SuperConstructor();
      g.addNode(1);
      g.addNode(2);
      var edgeId = g.addEdge(null, 1, 2);
      expect(fromSuper(g).incidentNodes(edgeId), equals([1, 2]));
    });

    test("fails to convert a graph with non-object edge values", () {
      var g = new SuperConstructor();
      g.addNode(1);
      g.addEdge(null, 1, 1, "foo");
      expect(() { fromSuper(g); }, throws);
    });
  });*/
}
