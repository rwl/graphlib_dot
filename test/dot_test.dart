part of graphlib.dot.test;

dotTest() {
  group('dot', () {
    group('parse', () {
      test('can parse an empty digraph', () {
        var g = dot.parse('digraph {}');
        expect(g, new isInstanceOf<dot.DotDigraph>());
      });

      test('can parse an empty graph', () {
        var g = dot.parse('graph {}');
        expect(g, new isInstanceOf<dot.DotGraph>());
      });

      test('can parse and ignore the strict keyword', () {
        // We do not currently use the strict keyword, but we should not fail if
        // we see it in the input.
        var g = dot.parse('strict digraph { a }');
        expect(g.graph(), equals({}));
        expect(g.nodes(), unorderedEquals(['a']));
      });

      test('can parse a graph with a single line comment', () {
        var g = dot.parse('graph { a // comment\n }');
        expect(g.nodes(), unorderedEquals(['a']));
      });

      test('can parse a graph with a multi-line comment', () {
        var g = dot.parse('graph { a /* comment */ }');
        expect(g.nodes(), unorderedEquals(['a']));
      });

      test('can parse a simple node', () {
        var g = dot.parse('digraph { a }');
        expect(g.nodes(), unorderedEquals(['a']));
      });

      test('can parse a node with an empty attribute', () {
        var g = dot.parse('digraph { a [label=""]; }');
        expect(g.node('a')['label'], equals(''));
      });

      test('can parse multiple comma-separated attributes', () {
        var g = dot.parse('digraph { a [label="l", foo="f", bar="b"]; }');
        expect(g.node('a')['label'], equals('l'));
        expect(g.node('a')['foo'], equals('f'));
        expect(g.node('a')['bar'], equals('b'));
      });

      test('can parse a numeric id', () {
        var g = dot.parse('digraph { 12; -12; 12.34; -12.34; .34; -.34 }');
        expect(g.nodes().length, equals(6));
        ['12', '12', '12.34', '-12.34', '.34', '-.34'].forEach((x) {
          expect(g.nodes(), anyElement(isIn(x)));
        });
      });

      group('ignores port and compass information', () {
        // While we don't use the port information, we should not fail to parse
        // a graph with it.

        test('ignores ports', () {
          var g = dot.parse('digraph { a:port }');
          expect(g.nodes(), unorderedEquals(['a']));
        });

        var compass = ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'c', '_'];
        compass.forEach((c) {
          test('ignores the compass_pt "' + c + '"', () {
            var g = dot.parse('digraph { a:' + c + ' }');
            expect(g.nodes(), unorderedEquals(['a']));
          });
        });

        compass.forEach((c) {
          test('ignores the port and compass_pt "port:$c"', () {
            var g = dot.parse('digraph { a:port:' + c + ' }');
            expect(g.nodes(), unorderedEquals(['a']));
          });
        });
      });

      test('does not treat the id attribute for a node specially', () {
        var g = dot.parse('digraph { a [id="b"]; }');
        expect(g.nodes(), unorderedEquals(['a']));
      });

      test('can parse a simple undirected edge', () {
        var g = dot.parse('graph { a -- b }');
        expect(g.nodes(), unorderedEquals(['a', 'b']));
        expect(g.edges().length, equals(1));
        expect(g.incidentNodes(g.edges()[0]), unorderedEquals(['a', 'b']));
      });

      test('can parse a simple directed edge', () {
        var g = dot.parse('digraph { a -> b }');
        expect(g.nodes(), unorderedEquals(['a', 'b']));
        expect(g.edges().length, equals(1));
        expect(g.source(g.edges()[0]), equals('a'));
        expect(g.target(g.edges()[0]), equals('b'));
      });

      test('can parse an edge with an id attribute', () {
        var g = dot.parse('digraph { a -> b [id="A"]; }');
        expect(g.edges(), unorderedEquals(['A']));
        expect(g.source('A'), equals('a'));
        expect(g.target('A'), equals('b'));
      });

      test('fails to parse a path with an id attribute', () {
        expect(() { dot.parse('digraph { a -> b -> c [id="A"]; }'); }, throws,
                      reason: ".*Graph already has edge 'A'.*");
      });

      test('can parse graph-level attributes', () {
        var g = dot.parse('digraph { foo = bar; }');
        expect(g.graph()['foo'], equals('bar'));
      });

      test('does not include empty subgraphs', () {
        expect(dot.parse('digraph { subgraph X {} }').nodes().length, equals(0));
        expect(dot.parse('digraph { subgraph {} }').nodes().length, equals(0));
        expect(dot.parse('digraph { {} }').nodes().length, equals(0));
      });

      test('can parse nodes in a subgraph', () {
        var g = dot.parse('digraph { subgraph X { a; b }; c }');
        expect(g.nodes(), unorderedEquals(['X', 'a', 'b', 'c']));
        expect(g.children(null), unorderedEquals(['X', 'c']));
        expect(g.children('X'), unorderedEquals(['a', 'b']));
      });

      test('can parse edges in a subgraph', () {
        var g = dot.parse('digraph { subgraph X { a; b; a -> b } }');
        expect(g.nodes(), unorderedEquals(['X', 'a', 'b']));
        expect(g.children(null), unorderedEquals(['X']));
        expect(g.edges().length, equals(1));
        expect(g.children('X'), unorderedEquals(['a', 'b']));
      });

      test('can parse attributes in a subgraph', () {
        var g = dot.parse('digraph { subgraph X { foo = bar; a; } }');
        expect(g.node('X')['foo'], equals('bar'));
      });

      test('can parse nested subgraphs', () {
        var g = dot.parse('digraph { subgraph X { subgraph Y { a; b } c } }');
        expect(g.nodes(), unorderedEquals(['X', 'Y', 'a', 'b', 'c']));
        expect(g.children(null), unorderedEquals(['X']));
        expect(g.children('X'), unorderedEquals(['Y', 'c']));
        expect(g.children('Y'), unorderedEquals(['a', 'b']));
      });

      test('adds default attributes to nodes', () {
        var d = 'digraph { node [color=black shape=box]; n1 [label="n1"]; n2 [label="n2"]; n1 -> n2; }';
        var g = dot.parse(d);
        expect(g.node('n1')['color'], equals('black'));
        expect(g.node('n1')['shape'], equals('box'));
        expect(g.node('n1')['label'], equals('n1'));

        expect(g.node('n2')['color'], equals('black'));
        expect(g.node('n2')['shape'], equals('box'));
        expect(g.node('n2')['label'], equals('n2'));
      });

      test('combines multiple default attribute statements', () {
        var d = 'digraph { node [color=black]; node [shape=box]; n1 [label="n1"]; }';
        var g = dot.parse(d);
        expect(g.node('n1')['color'], equals('black'));
        expect(g.node('n1')['shape'], equals('box'));
      });

      test('takes statement order into account when applying default attributes', () {
        var d = 'digraph { node [color=black]; n1 [label="n1"]; node [shape=box]; n2 [label="n2"]; }';
        var g = dot.parse(d);
        expect(g.node('n1')['color'], equals('black'));
        expect(g.node('n1')['shape'], isNull);

        expect(g.node('n2')['color'], equals('black'));
        expect(g.node('n2')['shape'], equals('box'));
      });

      test('overrides redefined default attributes', () {
        var d = 'digraph { node [color=black]; n1 [label="n1"]; node [color=green]; n2 [label="n2"]; n1 -> n2; }';
        var g = dot.parse(d);
        expect(g.node('n1')['color'], equals('black'));
        expect(g.node('n2')['color'], equals('green'));

        // Implementation detail:
        // parse::handleStmt wants to assure that nodes used in an edge definition
        // are defined by calling createNode for those nodes. If these nested createNode
        // calls don't skip merging the default attributes, the attributes of already
        // defined nodes could be overwritten, causing both nodes in this test case to
        // have 'color' set to green.
      });

      test('does not carry attributes from one node over to the next', () {
        var d = 'digraph { node [color=black]; n1 [label="n1" fontsize=12]; n2 [label="n2"]; n1 -> n2; }';
        var g = dot.parse(d);
        expect(g.node('n1')['fontsize'], equals('12'));
        expect(g.node('n2')['fontsize'], isNull, reason: 'n2.fontsize should not be defined');
      });

      test('applies default attributes to nodes created in an edge statement', () {
        var d = 'digraph { node [color=blue]; n1 -> n2; }';
        var g = dot.parse(d);
        expect(g.node('n1')['color'], equals('blue'));
        expect(g.node('n2')['color'], equals('blue'));
      });

      test('applies default label if an explicit label is not set', () {
        var d = 'digraph { node [label=xyz]; n2 [label=123]; n1 -> n2; }';
        var g = dot.parse(d);
        expect(g.node('n1')['label'], equals('xyz'));
        expect(g.node('n2')['label'], equals('123'));
      });

      test('supports an implicit subgraph statement', () {
        var d = 'digraph { x; {y; z} }';
        var g = dot.parse(d);
        expect(g.hasNode('x'), isTrue);
        expect(g.hasNode('y'), isTrue);
        expect(g.hasNode('z'), isTrue);
      });

      test('supports an explicit subgraph statement', () {
        var d = 'digraph { x; subgraph {y; z} }';
        var g = dot.parse(d);
        expect(g.hasNode('x'), isTrue);
        expect(g.hasNode('y'), isTrue);
        expect(g.hasNode('z'), isTrue);
      });

      test('supports a subgraph as the RHS of an edge statement', () {
        var d = 'digraph { x -> {y; z} }';
        var g = dot.parse(d);
        expect(g.predecessors('y'), equals(['x']));
        expect(g.predecessors('z'), equals(['x']));
      });

      test('supports a subgraph as the LHS of an edge statement', () {
        var d = 'digraph { {x; y} -> {z} }';
        var g = dot.parse(d);
        expect(g.successors('x'), equals(['z']));
        expect(g.successors('y'), equals(['z']));
      });

      test('applies edge attributes to all nodes in a subgraph', () {
        var d = 'digraph { x -> {y; z} [prop=123] }';
        var g = dot.parse(d);
        expect(g.edge(g.outEdges('x', 'y')[0])['prop'], equals('123'));  // TODO: String prop '123'
        expect(g.edge(g.outEdges('x', 'z')[0])['prop'], equals('123'));  // TODO: String prop '123'
      });

      test('only applies attributes in a subgraph to nodes created in that subgraph', () {
        var d = 'digraph { x; subgraph { node [prop=123]; y; z; } }';
        var g = dot.parse(d);
        expect(g.node('x')['prop'], isNull);
        expect(g.node('y')['prop'], equals('123'));  // TODO: String prop '123'
        expect(g.node('z')['prop'], equals('123'));  // TODO: String prop '123'
      });

      test('applies parent defaults to subgraph nodes when appropriate', () {
        var d = 'digraph { node [prop=123]; subgraph { x; subgraph { y; z [prop=456]; } } }';
        var g = dot.parse(d);
        expect(g.node('x')['prop'], equals('123'));  // TODO: String prop '123'
        expect(g.node('y')['prop'], equals('123'));  // TODO: String prop '123'
        expect(g.node('z')['prop'], equals('456'));  // TODO: String prop '456'
      });

      test('can handle quoted unicode', () {
        var d = 'digraph { "♖♘♗♕♔♗♘♖" }';
        var g = dot.parse(d);
        expect(g.nodes(), equals(['♖♘♗♕♔♗♘♖']));
      });

      test('fails on unquoted unicode', () {
        var d = 'digraph { ♖♘♗♕♔♗♘♖ }';
        expect(() { dot.parse(d); }, throws);
      });

      group('it can parse all files in test-data', () {
        final testDataDir = new Directory(path.join(Uri.base.toFilePath(), "test-data"));
        testDataDir.listSync(followLinks: false)
            .where((x) { return FileSystemEntity.isFileSync(x.path); })
            .forEach((file) {
          test(path.basename(file.path), () {
            final input = file.readAsStringSync();
            dot.parse(input);
          });
        });
      });
    });

//    group('it can write and parse without loss', () {
//      final testDataDir = new Directory(path.join(Uri.base.toFilePath(), "test-data"));
//      testDataDir.listSync(followLinks: false)
//          .where((x) { return FileSystemEntity.isFileSync(x.path); })
//          .forEach((file) {
//        test(path.basename(file.path), () {
//          final input = file.readAsStringSync();
//          var g = dot.parse(input);
//          expect(dot.parse(dot.write(g)), equals(g));
//        });
//      });
//    });

    /*
     * When this library is consumed by other libraries it is possible for
     * instanceof checks to fail, so we want to be sure all decisions about how
     * a graph is serialized are based on properties (e.g. `isDirected`), not
     * instanceof checks. To do this, we swap DotGraph / DotDigraph locally,
     * reverse the `isDirected` behavior and assert that the output is based on
     * `isDirected`.
     */
    /*group('write consistency', () {
      swapGraphBehaviors() {
        var tmp = DotDigraph;
        DotDigraph = DotGraph;
        DotGraph = tmp;

        var tmpDirected = DotDigraph.prototype.isDirected;
        DotDigraph.prototype.isDirected = DotGraph.prototype.isDirected;
        DotGraph.prototype.isDirected = tmpDirected;
      }

      setUp(() {
        swapGraphBehaviors();
      });

      tearDown(() {
        swapGraphBehaviors();
      });

      test('uses directed edges for directed graphs', () {
        var g = new DotDigraph();
        g.addNode(1);
        g.addNode(2);
        g.addEdge(null, 1, 2);

        var d = dot.write(g);
        expect(d,    matches(r"/^digraph {"));
        expect(d, not(matches(r"^graph {")));
        expect(d,    matches(r"->"));
        expect(d, not(matches(r"--")));
      });

      test('uses undirected edges for undirected graphs', () {
        var g = new DotGraph();
        g.addNode(1);
        g.addNode(2);
        g.addEdge(null, 1, 2);

        var d = dot.write(g);
        expect(d,    matches(r"^graph {"));
        expect(d, not(matches(r"^digraph {")));
        expect(d,    matches(r"--"));
        expect(d, not(matches(r"->")));
      });
    });*/

    group('parseMany', () {
      test('fails for an empty string', () {
        expect(() { dot.parse(''); }, throws);
      });

      test('parses a single graph', () {
        var gs = dot.parseMany('digraph { A; B; C; A -> B }');
        expect(gs.length, equals(1));

        var g = gs[0];
        expect(g.nodes()..sort(), equals(['A', 'B', 'C']));
        expect(g.outEdges('A', 'B').length, equals(1));
      });

      test('parses multiple graphs', () {
        var gs = dot.parseMany('digraph { A } digraph { B }');
        expect(gs.length, equals(2));
        expect(gs[0].nodes()..sort(), equals(['A']));
        expect(gs[1].nodes()..sort(), equals(['B']));
      });
    });

    group('write', () {
      test('escapes attr keys as needed', () {
        var g = new dot.DotDigraph();
        g.addNode(1, { 'this.key.needs.quotes': 'some value' });
        expect(new RegExp(r'\"this.key.needs.quotes\"').hasMatch(dot.write(g)), isTrue, reason: 'key was not quoted');

        var g2 = dot.parse(dot.write(g));
        expect(g2.node('1'), contains('this.key.needs.quotes')); // TODO: String key '1'
      });

      test('escapes attr values as needed', () {
        var g = new dot.DotDigraph();
        g.addNode(1, { 'key': 'this.val.needs.quotes' });
        expect(new RegExp(r'\"this.val.needs.quotes\"').hasMatch(dot.write(g)), isTrue, reason: 'value was not quoted');

        var g2 = dot.parse(dot.write(g));
        expect(g2.node('1')['key'], equals('this.val.needs.quotes')); // TODO: String key '1'
      });

      test('can write a non-compound graph', () {
        var g = new Digraph();
        g.graph({});

        var g2 = dot.parse(dot.write(g));
        expect(g2.nodes(), unorderedEquals([]));
        expect(g2.edges(), unorderedEquals([]));
        expect(g2.graph(), equals({}));
      });

      test('can write a graph without graph attributes', () {
        var g = new Digraph();

        var g2 = dot.parse(dot.write(g));
        expect(g2.nodes(), unorderedEquals([]));
        expect(g2.edges(), unorderedEquals([]));
        expect(g2.graph(), equals({}));
      });

      test('can write a node without attributes', () {
        var g = new Digraph();
        g.addNode(1);

        var g2 = dot.parse(dot.write(g));
        expect(g2.nodes(), unorderedEquals(['1']));
      });

      test('can write an edge without attributes', () {
        var g = new Digraph();
        g.addNode(1);
        g.addNode(2);
        g.addEdge('A', 1, 2);

        var g2 = dot.parse(dot.write(g));
        // edges don't have an id in the DOT language, so we can only assert we
        // got one edge back.
        expect(g2.edges().length, equals(1));
      });
    });
  });
}