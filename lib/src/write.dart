part of graphlib.dot;

//var Writer = require('./Writer');
//
//module.exports = write;

var UNESCAPED_ID_PATTERN = r"^[a-zA-Z\200-\377_][a-zA-Z\200-\377_0-9]*$";

/*
 * Writes a string representation of the given graph in the DOT language.
 *
 * Note: this is exported as the module export
 *
 * @param {Graph|Digraph} g the graph to serialize
 */
write(g) {
  var ec = g.isDirected() ? '->' : '--';
  var writer = new Writer();

  writer.writeLine((g.isDirected() ? 'digraph' : 'graph') + ' {');
  writer.indent();

  var graphAttrs = g.graph();

  if(graphAttrs) {
    Object.keys(graphAttrs).map((k) {
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

writeSubgraph(g, u, writer) {
  var children = g.children ? g.children(u) : (u == null ? g.nodes() : []);
  children.forEach((v) {
    if (!g.children || g.children(v).length == 0) {
      writeNode(g, v, writer);
    } else {
      writer.writeLine('subgraph ' + id(v) + ' {');
      writer.indent();

      var attrs = g.node(v);
      Object.keys(attrs).map((k) {
        writer.writeLine(id(k) + '=' + id(attrs[k]) + ';');
      });

      writeSubgraph(g, v, writer);
      writer.unindent();
      writer.writeLine('}');
    }
  });
}

id(obj) {
  if (typeof(obj) == 'number' || obj.toString().match(UNESCAPED_ID_PATTERN)) {
    return obj;
  }

  return '"' + obj.toString().replace('"'/*g*/, '\\"') + '"';
}

writeNode(g, u, writer) {
  var attrs = g.node(u);
  writer.write(id(u));

  if (attrs) {
    var attrStrs = Object.keys(attrs).map((k) {
      return id(k) + '=' + id(attrs[k]);
    });

    if (attrStrs.length) {
      writer.write(' [' + attrStrs.join(',') + ']');
    }
  }

  writer.writeLine();
}

writeEdge(g, e, ec, writer) {
  var attrs = g.edge(e),
      incident = g.incidentNodes(e),
      u = incident[0],
      v = incident[1];

  writer.write(id(u) + ' ' + ec + ' ' + id(v));
  if (attrs) {
    var attrStrs = Object.keys(attrs).map((k) {
      return id(k) + '=' + id(attrs[k]);
    });

    if (attrStrs.length) {
      writer.write(' [' + attrStrs.join(',') + ']');
    }
  }

  writer.writeLine();
}

