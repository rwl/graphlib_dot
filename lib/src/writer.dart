part of graphlib.dot;

// A simple class for pretty printing strings with indentation

//module.exports = Writer;

var INDENT = "    ";

class Writer {
  String _indent = "";
  String _content = "";
  bool _shouldIndent = true;

  indent() {
    this._indent += INDENT;
  }

  unindent() {
    this._indent = this._indent.substring(INDENT.length);
  }

  writeLine([String line=""]) {
    this.write(line + "\n");
    this._shouldIndent = true;
  }

  write(String str) {
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