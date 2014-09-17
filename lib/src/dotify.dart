part of graphlib.dot;

// This file provides a helper function that mixes-in Dot behavior to an
// existing graph prototype.

//module.exports = dotify;

// Extends the given SuperConstructor with DOT behavior and returns the new
// constructor.
//class Dotify {//(SuperConstructor) {
////  Constructor() {
////    SuperConstructor.call(this);
////    this.graph({});
////  }
////
////  Constructor.prototype = new SuperConstructor();
////  constructor = Constructor;
//
//  graph(value) {
//    if (arguments.length < 1) {
//      return Supergraph.call(this);
//    }
//    this._checkValueType(value);
//    return Supergraph.call(this, value);
//  }
//
//  node(u, value) {
//    if (arguments.length < 2) {
//      return Supernode.call(this, u);
//    }
//    this._checkValueType(value);
//    return Supernode.call(this, u, value);
//  }
//
//  addNode(u, value) {
//    if (arguments.length < 2) {
//      value = {};
//    }
//    this._checkValueType(value);
//    return SuperaddNode.call(this, u, value);
//  }
//
//  edge(e, value) {
//    if (arguments.length < 2) {
//      return Superedge.call(this, e);
//    }
//    this._checkValueType(value);
//    return Superedge.call(this, e, value);
//  }
//
//  addEdge(e, u, v, value) {
//    if (arguments.length < 4) {
//      value = {};
//    }
//    this._checkValueType(value);
//    return SuperaddEdge.call(this, e, u, v, value);
//  }
//
//  _checkValueType(value) {
//    if (value == null || typeof(value) != "object") {
//      throw new Error("Value must be non-null and of type 'object'");
//    }
//  }
//}
