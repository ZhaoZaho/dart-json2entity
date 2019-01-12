import 'package:json2entity/src/class_parser.dart';

main(List<String> args) {
  testGetConstructor();
}


var src = '''

class Model extends Object {
  num result;
  String msg;

  Model(this.result, this.msg);
}
''';

var src2 = '''

class Model {
  num result;
  String msg;

  Model({this.result, this.msg});
}
''';

void testGetConstructor() {
  // var src = Clazz.fromJson(json1);
  // src = src2;
  print('\n---->');
  // print(src);
  var classParser =
      // EntityClassParser.fromSource(src.toString(), 'Model');
      EntityClassParser.fromUri(Uri.parse('/Users/etiantian/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.0/lib/dart/ast/ast.dart'), 'LibraryIdentifier');
  // NodeList<FormalParameter> param = classParser.getConstructor().parameters.parameters;
  // print(param.toList().elementAt(0).isNamed);
  // print(param);
  print(classParser.clazz.extendsClause);
  print(classParser.clazz.metadata);
  // print(classParser.clazz.parent);
  // print(classParser.clazz.childEntities);
  print(classParser.getSuper().name);
}