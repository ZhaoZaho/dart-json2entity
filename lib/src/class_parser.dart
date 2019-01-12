import 'dart:io';

import 'package:analyzer/analyzer.dart';


abstract class ClassParser {
  getConstructor();
  getFields();
  getMethods();
  getSuper();
}

class EntityClassParser extends ClassParser {
  ClassDeclaration _clazz;

  EntityClassParser.fromSource(String src, String name) {
    CompilationUnit compilationUnit = parseCompilationUnit(src);
    if (compilationUnit.declarations.length < 1) {
      throw Exception('NO CLASS DECLARATION FOUND ERROR!');
    }
    var classes = compilationUnit.declarations.toList().where((d) =>
        (d is ClassDeclaration) &&
        d.name.toString() == name);

    if (classes == null) {
      throw Exception('No class named $name found');
    }

    if (classes.length < 1) {
      throw Exception('No class named $name found');
    }
    _clazz = classes.elementAt(0);
  }

  @override
  ConstructorDeclaration getConstructor() {
    return _clazz.getConstructor(null);
  }

  @override
  getFields() {
    // TODO: implement getFields
    return null;
  }

  @override
  getMethods() {
    // TODO: implement getMethods
    return null;
  }

  @override
  TypeName getSuper() {
    ExtendsClause ex = _clazz.extendsClause;
    if (ex != null) {
      return ex.superclass;
    }
    return null;
  }

  getSuperName() {
    if (getSuper() != null) {
      return getSuper().name;
    }
    return null;
  }

  EntityClassParser.fromClassDeclaration(CompilationUnitMember cls) {
    _clazz = cls;
  }

  ClassDeclaration get clazz => _clazz;

  EntityClassParser.fromUri(Uri uri, String name) {
    String src = File.fromUri(uri).readAsStringSync();
    EntityClassParser.fromSource(src, name);
  }

  String getName() {
    if (_clazz == null) {
      return null;
    }
    return _clazz.name.name;
  }
}