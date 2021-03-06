//source: less/tree/url.js 3.0.0 20160714

part of tree.less;

///
class URL extends Node {
  @override String          type = 'Url';
  @override covariant Node  value;

  ///
  bool  isEvald;

  ///
  URL(Node this.value,
      {int index, FileInfo currentFileInfo, bool this.isEvald = false})
      : super.init(currentFileInfo: currentFileInfo, index: index);

//3.0.0
// var URL = function (val, index, currentFileInfo, isEvald) {
//     this.value = val;
//     this._index = index;
//     this._fileInfo = currentFileInfo;
//     this.isEvald = isEvald;
// };

  /// Fields to show with genTree
  @override Map<String, dynamic> get treeField => <String, dynamic>{
    'value': value
  };

  ///
  @override
  void accept(covariant VisitorBase visitor) {
    value = visitor.visit(value);

//2.3.1
//  URL.prototype.accept = function (visitor) {
//      this.value = visitor.visit(this.value);
//  };
  }

  ///
  @override
  void genCSS(Contexts context, Output output) {
    output.add('url(');
    value.genCSS(context, output);
    output.add(')');

//2.3.1
//  URL.prototype.genCSS = function (context, output) {
//      output.add("url(");
//      this.value.genCSS(context, output);
//      output.add(")");
//  };
  }

  ///
  @override
  URL eval(Contexts context) {
    final Node val = value.eval(context);
    String rootpath;

    if (!isEvald) {
      // Add the base path if the URL is relative
      rootpath = currentFileInfo?.rootpath;
      if (rootpath.isNotEmpty &&
          (val.value is String) &&
          context.isPathRelative(val.value)) {
        if (val is! Quoted) {
          rootpath = rootpath.replaceAllMapped(
              new RegExp(r'''[\(\)'"\s]'''), (Match match) => '\\${match[0]}');
        }
        // ignore: prefer_interpolation_to_compose_strings
        val.value = rootpath + val.value;
      }
      val.value = context.normalizePath(val.value);

      // Add url args if enabled
      if (isNotEmpty(context.urlArgs)) {
        final RegExp reData = new RegExp(r'^\s*data:');
        final Match match = reData.firstMatch(val.value);
        if (match == null) {
          final String delimiter =
              !(val.value as String).contains('?') ? '?' : '&';
          // ignore: prefer_interpolation_to_compose_strings
          final String urlArgs = delimiter + context.urlArgs;
          if ((val.value as String).contains('#')) {
            val.value = (val.value as String).replaceFirst('#', '$urlArgs#');
          } else {
            // ignore: prefer_interpolation_to_compose_strings
            val.value += urlArgs;
          }
        }
      }
    }
    return new URL(val,
        index: index,
        currentFileInfo: currentFileInfo,
        isEvald: true);

//3.0.0 20160714
// URL.prototype.eval = function (context) {
//     var val = this.value.eval(context),
//         rootpath;
//
//     if (!this.isEvald) {
//         // Add the base path if the URL is relative
//         rootpath = this.fileInfo() && this.fileInfo().rootpath;
//         if (rootpath &&
//             typeof val.value === "string" &&
//             context.isPathRelative(val.value)) {
//
//             if (!val.quote) {
//                 rootpath = rootpath.replace(/[\(\)'"\s]/g, function(match) { return "\\" + match; });
//             }
//             val.value = rootpath + val.value;
//         }
//
//         val.value = context.normalizePath(val.value);
//
//         // Add url args if enabled
//         if (context.urlArgs) {
//             if (!val.value.match(/^\s*data:/)) {
//                 var delimiter = val.value.indexOf('?') === -1 ? '?' : '&';
//                 var urlArgs = delimiter + context.urlArgs;
//                 if (val.value.indexOf('#') !== -1) {
//                     val.value = val.value.replace('#', urlArgs + '#');
//                 } else {
//                     val.value += urlArgs;
//                 }
//             }
//         }
//     }
//
//     return new URL(val, this.getIndex(), this.fileInfo(), true);
// };
  }

  @override
  String toString() {
    final Output output = new Output();
    genCSS(null, output);
    return output.toString();
  }
}
