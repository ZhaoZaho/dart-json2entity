import 'dart:convert';

import 'package:json2entity/src/utils.dart';

/// null -> String
/// {} -> Class without field
/// [] -> List<dynamic>

/// ClassInfo describes all info of An entity class.
class ClassInfo {
  String name;
  ClassInfo base;
  ClassInfo(this.name);

  /// All fields
  List<Field> fields = [];

  /// All ClassInfo present in fields
  List<ClassInfo> children = [];
}

class Field {
  String name;
  String type;
  Field(this.name, this.type);
}

abstract class ClassMaker {
  ClassInfo classInfo;

  ClassMaker(this.classInfo);

  buildClassDeclaration();
  buildFields();
  buildConstructor();
  buildClassName();
  buildClass();
}

abstract class JsonSerializableSupport extends ClassMaker {
  JsonSerializableSupport(ClassInfo classInfo) : super(classInfo);

  buildFromJson();
  buildToJson();
}

class SimpleClassMaker extends ClassMaker {
  SimpleClassMaker(ClassInfo classInfo) : super(classInfo);
  @override
  buildClass() {
    // TODO: implement buildClass
    return null;
  }

  @override
  buildClassDeclaration() {
    return 'class ${this.classInfo.name} extends $parentName {';
  }

  @override
  buildClassName() {
    // TODO: implement buildClassName
    return null;
  }

  @override
  buildConstructor() {
    // TODO: implement buildConstructor
    return null;
  }

  @override
  buildFields() {
    // TODO: implement buildFields
    return null;
  }
}

class JsonSerializableSupportClassMaker extends SimpleClassMaker
    implements JsonSerializableSupport {
  JsonSerializableSupportClassMaker(ClassInfo classInfo) : super(classInfo);

  @override
  buildFromJson() {
    // TODO: implement buildFromJson
    return null;
  }

  @override
  buildToJson() {
    // TODO: implement buildToJson
    return null;
  }
}

class ClassMakerFactory {
  ClassMaker getClassMaker() {}
}

abstract class ClassParser {
  ClassInfo fromJsonString(String jsonString);
  ClassInfo fromJsonMap(Map<String, dynamic> jMap);
  ClassInfo fromJsonList(List<dynamic> jList, String key);
  ClassInfo fromClass(ClassInfo oterClass);
  ClassInfo fromClassString(String classSource);
}

class SimpleClassParser extends ClassParser {
  @override
  ClassInfo fromClass(ClassInfo oterClass) {
    // TODO: implement fromClass
    return null;
  }

  @override
  ClassInfo fromClassString(String classSource) {
    // TODO: implement fromClassString
    return null;
  }

  @override
  ClassInfo fromJsonList(List jList, String key, [String className]) {
    var newMap = <String, dynamic>{};
    newMap[key] = jList;
    return fromJsonMap(newMap, className);
  }

  @override
  ClassInfo fromJsonMap(Map<String, dynamic> jMap, [String className]) {
    if (jMap == null || jMap.entries.length == 0) {
      throw FormatException('Map 不能为空');
    }
    var classInfo = ClassInfo(className ?? getDefaultClassName());
    jMap.entries.forEach((entry) {
      String key = entry.key;
      var value = entry.value;
      if (value is num) {
        classInfo.fields.add(Field(key, 'num'));
      } else if (value is bool) {
        classInfo.fields.add(Field(key, 'bool'));
      } else if (value is String) {
        classInfo.fields.add(Field(key, 'String'));
      } else if (value == null) {
        classInfo.fields.add(Field(key, 'String'));
      } else if (value is List) {
        if (value.length == 0) {
          classInfo.fields.add(Field(key, 'List<dynamic>'));
        } else {
          var listItem = value.elementAt(0);
          if (listItem is Map) {
            var classType = getListItemClassName(key);
            classInfo.fields.add(Field(key, 'List<$classType>'));
            classInfo.children.add(fromJsonMap(listItem));
          } else {
            classInfo.fields.add(Field(key, getType(listItem)));
          }
        }
      } else {
        var classType = getMapItemClassName(key);
        classInfo.fields.add(Field(key, classType));
        classInfo.children.add(fromJsonMap(value));
      }
    });
    return classInfo;
  }

  @override
  ClassInfo fromJsonString(String jsonString, [String className]) {
    try {
      var jobj = json.decode(jsonString);
      if (jobj is List) {
        return fromJsonList(jobj, getDefaultKey());
      } else {
        return fromJsonMap(jobj, className);
      }
    } on Exception catch (e) {
      throw FormatException('解析json错误');
    }
  }

  String getDefaultKey() {
    return 'JsonEntity';
  }

  String getListItemClassName(String key) {
    return '${capitalize(key)}Item';
  }

  String getMapItemClassName(String key) {
    return getListItemClassName(key);
  }

  getDefaultClassName() {
    return 'DataModel';
  }
}

main(List<String> args) {
  var json3 = '{"city":"Mumbai","streets":["address1","address2"]}';
  var json4 =
      '{"id":1,"name":"ProductName","images":[{"id":11,"imageName":"xCh-rhy"},{"id":31,"imageName":"fjs-eun"}]}';
  var classParser = SimpleClassParser();
  var classInfo = classParser.fromJsonString(json4);
  print(classInfo.children[0].fields.length);
}
