part of graphlib.dot;

//var DotDigraph = require("./DotDigraph"),
//    DotGraph = require("./DotGraph");

var dot_parser = new Parser();

//module.exports = parse;
//module.exports.parseMany = parseMany;

class SubDigraph {
  final _attrs = new Map<String, Map>();
  final SubDigraph parent;
  SubDigraph(this.parent);
  Map operator [](String x) => _attrs[x];
  void operator []=(String x, Map v) { _attrs[x] = v; }
}

/**
 * We use a chain of prototypes to maintain properties as we descend into
 * subgraphs. This allows us to simply get the value for a property and have
 * the VM do appropriate resolution. When we leave a subgraph we simply set
 * the current context to the prototype of the current defaults object.
 * Alternatively, this could have been written using a stack.
 */
class DefaultAttrs {
  SubDigraph _default = new SubDigraph(null);

  get(String type, attrs) {
    //if (typeof(this._default[type]) != "undefined") {
    if (this._default[type] != null) {
      var mergedAttrs = {};
      // clone default attributes so they won't get overwritten in the next step
      mergeAttributes(this._default[type], mergedAttrs);
      // merge statement attributes with default attributes, precedence give to stmt attributes
      mergeAttributes(attrs, mergedAttrs);
      return mergedAttrs;
    } else {
      return attrs;
    }
  }

  set(type, attrs) {
    this._default[type] = this.get(type, attrs);
  }

  enterSubDigraph() {
//    SubDigraph() {}
//    SubDigraph.prototype = this._default;
    var subgraph = new SubDigraph(this._default);
    this._default = subgraph;
  }

  exitSubDigraph() {
    //this._default = Object.getPrototypeOf(this._default);
    this._default = this._default.parent;
  }
}

/**
 * Parses a single DOT graph from the given string and returns it as one of:
 *
 * * `Digraph` if the input graph is a `digraph`.
 * * `Graph` if the input graph is a `graph`.
 *
 * Note: this is exported as the module export.
 *
 * @param {String} str the DOT string representation of one or more graphs
 */
parse(str) {
  var parseTree = dot_parser.parse(str, "graphStmt");
  return buildGraph(parseTree);
}

/**
 * Parses one or more DOT graphs in the given string and returns them using
 * the same rules as described in [parse][] for individual graphs.
 *
 * [parse]: parse.js.html#parse
 *
 * @param {String} str the DOT string representation of one or more graphs
 */
parseMany(str) {
  var parseTree = dot_parser.parse(str);

  return parseTree.map((subtree) {
    return buildGraph(subtree);
  });
}

buildGraph(parseTree) {
  var g = parseTree.type == "graph" ? new DotGraph() : new DotDigraph();

  final defaultAttrs = new DefaultAttrs();

  createNode(id, attrs, sg) {
    if (!(g.hasNode(id))) {
      // We only apply default attributes to a node when it is first defined.
      // If the node is subsequently used in edges, we skip apply default
      // attributes.
      g.addNode(id, defaultAttrs.get("node", {}));

      // The "label" attribute is given special treatment: if it is not
      // defined we set it to the id of the node.
      if (g.node(id).label == null) {
        g.node(id).label = id;
      }

      if (sg != null) {
        g.parent(id, sg);
      }
    }
    if (attrs) {
      mergeAttributes(attrs, g.node(id));
    }
  }

  createEdge(source, target, attrs) {
    var edge = {};
    mergeAttributes(defaultAttrs.get("edge", attrs), edge);
    var id = attrs.id ? attrs.id : null;
    g.addEdge(id, source, target, edge);
  }

  collectNodeIds(stmt) {
    var ids = {},
        stack = [],
        curr;
    pushStack(e) { stack.add(e); }

    pushStack(stmt);
    while (stack.length != 0) {
      curr = stack.removeLast();
      switch (curr.type) {
        case "node": ids[curr.id] = true; break;
        case "edge":
          curr.elems.forEach(pushStack);
          break;
        case "subgraph":
          curr.stmts.forEach(pushStack);
          break;
      }
    }
    return ids.keys;
  }

  /*
   * We use a chain of prototypes to maintain properties as we descend into
   * subgraphs. This allows us to simply get the value for a property and have
   * the VM do appropriate resolution. When we leave a subgraph we simply set
   * the current context to the prototype of the current defaults object.
   * Alternatively, this could have been written using a stack.
   */
  /*var defaultAttrs = {
    _default: {},

    'get': get(type, attrs) {
      if (typeof(this._default[type]) != "undefined") {
        var mergedAttrs = {};
        // clone default attributes so they won't get overwritten in the next step
        mergeAttributes(this._default[type], mergedAttrs);
        // merge statement attributes with default attributes, precedence give to stmt attributes
        mergeAttributes(attrs, mergedAttrs);
        return mergedAttrs;
      } else {
        return attrs;
      }
    },

    'set': set(type, attrs) {
      this._default[type] = this.get(type, attrs);
    },

    'enterSubDigraph': () {
      SubDigraph() {}
      SubDigraph.prototype = this._default;
      var subgraph = new SubDigraph();
      this._default = subgraph;
    },

    'exitSubDigraph': () {
      this._default = Object.getPrototypeOf(this._default);
    }
  };*/

  handleStmt(stmt, sg) {
    var attrs = stmt.attrs;
    switch (stmt.type) {
      case "node":
        createNode(stmt.id, attrs, sg);
        break;
      case "edge":
        var prev,
            curr;
        stmt.elems.forEach((elem) {
          handleStmt(elem, sg);

          switch(elem.type) {
            case "node": curr = [elem.id]; break;
            case "subgraph": curr = collectNodeIds(elem); break;
            default:
              // We don't currently support subgraphs incident on an edge
              throw new Exception("Unsupported type incident on edge: ${elem.type}");
          }

          if (prev) {
            prev.forEach((p) {
              curr.forEach((c) {
                createEdge(p, c, attrs);
              });
            });
          }
          prev = curr;
        });
        break;
      case "subgraph":
        defaultAttrs.enterSubDigraph();
        stmt.id = g.addNode(stmt.id);
        if (sg != null) { g.parent(stmt.id, sg); }
        if (stmt.stmts) {
          stmt.stmts.forEach((s) { handleStmt(s, stmt.id); });
        }
        // If no children we remove the subgraph
        if (g.children(stmt.id).length == 0) {
          g.delNode(stmt.id);
        }
        defaultAttrs.exitSubDigraph();
        break;
      case "attr":
        defaultAttrs.set(stmt.attrType, attrs);
        break;
      case "inlineAttr":
        if (stmt.attrs) {
          mergeAttributes(attrs, sg == null ? g.graph() : g.node(sg));
        }
        break;
      default:
        throw new Exception("Unsupported statement type: ${stmt.type}");
    }
  }

  if (parseTree.stmts) {
    parseTree.stmts.forEach((stmt) {
      handleStmt(stmt, null);
    });
  }

  return g;
}

// Copies all key-value pairs from `src` to `dst`. This copy is destructive: if
// a key appears in both `src` and `dst` the value from `src` will overwrite
// the value in `dst`.
mergeAttributes(Map src, Map dst) {
  //Object.keys(src).forEach((k) { dst[k] = src[k]; });
  src.keys.forEach((k) { dst[k] = src[k]; });
}
