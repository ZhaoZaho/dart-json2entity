import 'package:analyzer/analyzer.dart';


abstract class ClassParser {
  getConstructor();
  getFields();
  getMethods();
}

class EntityClassParser extends ClassParser {
  ClassDeclaration _clazz;

  EntityClassParser.fromSource({String src, String name}) {
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
  getConstructor() {
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
}