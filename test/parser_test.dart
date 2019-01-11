import 'package:json2entity/src/class_maker.dart';
import 'package:test/test.dart';

import '../example/example.dart';

var json =
    '{"id":1,"name":"ProductName","images":[{"id":11,"imageName":"xCh-rhy"},{"id":31,"imageName":"fjs-eun"}]}';

main() {
  var classParser = SimpleClassParser();
  var classInfo = classParser.fromJsonString(json1);
  testClassInfo(classInfo, 2, 0);
  classInfo = classParser.fromJsonString(json2);
  testClassInfo(classInfo, 3, 1);
  classInfo = classParser.fromJsonString(json3);
  testClassInfo(classInfo, 2, 0);
  classInfo = classParser.fromJsonString(json4);
  testClassInfo(classInfo, 3, 1);
  classInfo = classParser.fromJsonString(json5);
  testClassInfo(classInfo, 1, 1);
  classInfo = classParser.fromJsonString(json6);
  testClassInfo(classInfo, 2, 1);
  testClassInfo(classInfo.children[0], 6, 1);
}

void testClassInfo(ClassInfo classInfo, num fieldNum, num childrenNum) {
  test('test parser fields count', () {
    expect(classInfo.fields.length, equals(fieldNum));
  });
  test('test parser children count', () {
    expect(classInfo.children.length, equals(childrenNum));
  });
}
