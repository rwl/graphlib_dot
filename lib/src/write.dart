part of graphlib.dot;

//var Writer = require('./Writer');
//
//module.exports = write;

final UNESCAPED_ID_PATTERN = new RegExp(r"^[a-zA-Z\200-\377_][a-zA-Z\200-\377_0-9]*$");

/*
 * Writes a string representation of the given graph in the DOT language.
 *
 * Note: this is exported as the module export
 *
 * @param {Graph|Digraph} g the graph to serialize
 */
write(BaseGraph g) {
  var ec = g.isDirected() ? '->' : '--';
  var writer = new Writer();

  writer.writeLine((g.isDirected() ? 'digraph' : 'graph') + ' {');
  writer.indent();

  Map graphAttrs = g.graph();

  if (graphAttrs != null) {
    graphAttrs.keys.map((k) {
      writer.writeLine(id(k) + '=' + id(graphAttrs[k]) + ';');
    });
  }

  writeSubgraph(g, null, writer);

  g.edges().forEach((e) {
    writeEdge(g, e, ec, writer);
  });

  writer.unindent();
  writer.writeLine('}');

  return writer.toString();
}

writeSubgraph(BaseGraph g, u, Writer writer) {
  var children = g.isCompound() ? g.children(u) : (u == null ? g.nodes() : []);
  children.forEach((v) {
    if (!g.isCompound() || g.children(v).length == 0) {
      writeNode(g, v, writer);
    } else {
      writer.writeLine('subgraph ' + id(v) + ' {');
      writer.indent();

      Map attrs = g.node(v);
      attrs.keys.map((k) {
        writer.writeLine(id(k) + '=' + id(attrs[k]) + ';');
      });

      writeSubgraph(g, v, writer);
      writer.unindent();
      writer.writeLine('}');
    }
  });
}

id(obj) {
  if (obj is num || UNESCAPED_ID_PATTERN.hasMatch(obj.toString())) {
    return obj;//.toString();
  }

  return '"' + obj.toString().replaceAll('"'/*g*/, '\\"') + '"';
}

writeNode(BaseGraph g, u, Writer writer) {
  var attrs = g.node(u);
  writer.write(id(u).toString());

  if (attrs != null) {
    var attrStrs = attrs.keys.map((k) {
      return id(k) + '=' + id(attrs[k]);
    });

    if (attrStrs.length != 0) {
      writer.write(' [' + attrStrs.join(',') + ']');
    }
  }

  writer.writeLine();
}

writeEdge(BaseGraph g, e, ec, Writer writer) {
  var attrs = g.edge(e),
      incident = g.incidentNodes(e),
      u = incident[0],
      v = incident[1];

  writer.write('${id(u)} $ec ${id(v)}');
  if (attrs != null) {
    var attrStrs = attrs.keys.map((k) {
      return '${id(k)}=${id(attrs[k])}';
    });

    if (attrStrs.length) {
      writer.write(' [' + attrStrs.join(',') + ']');
    }
  }

  writer.writeLine();
}

