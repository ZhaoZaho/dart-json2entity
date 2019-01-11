import 'package:json2entity/src/class_parser.dart';

import 'package:json2entity/json2entity.dart';
import 'package:test/test.dart';
import 'package:analyzer/analyzer.dart';

import '../example/example.dart';

main(List<String> args) {
  testGetConstructor();
}

void testGetConstructor() {
  var src = Clazz.fromJson(json1);
  print('\n---->');
  print(src);
  var classParser =
      EntityClassParser.fromSource(src: src.toString(), name: 'AutoModel');
  var constructor = classParser.getConstructor();
  print(constructor);
  print(constructor);
}
