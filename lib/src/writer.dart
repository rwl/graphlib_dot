part of graphlib.dot;

// A simple class for pretty printing strings with indentation

//module.exports = Writer;

var INDENT = "    ";

class Writer {
  var _indent = "";
  var _content = "";
  var _shouldIndent = true;

  indent() {
    this._indent += INDENT;
  }

  unindent() {
    this._indent = this._indent.slice(INDENT.length);
  }

  writeLine([line=""]) {
    this.write(line + "\n");
    this._shouldIndent = true;
  }

  write(str) {
    if (this._shouldIndent) {
      this._shouldIndent = false;
      this._content += this._indent;
    }
    this._content += str;
  }

  toString() {
    return this._content;
  }
}