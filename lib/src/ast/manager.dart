import 'dart:convert';

import 'package:json2entity/src/ast/class_graph.dart';
import 'package:json2entity/src/ast/class_parser.dart';
import 'package:json2entity/src/ast/list_packages.dart';

List<ClassNode> _rootNodes = <ClassNode>[];
List<Map<String, dynamic>> maps = [];
main(List<String> args) {
  var root = MyEnvironmentProvider().getPackagePath('http');
  print(root);
  var files = new DartFileTraversal().traverse('$root');
  files = files.where((f)=>f.uri.path.contains('byte_stream.dart')).toList();
  print(files);

  var cls = files
      .map((f) => f.uri)
      .expand((u) => ClassGraph.fromUri(u).clsList)
      ?.toList();

  Iterable clsOuter;
  try {
    clsOuter = files
          .map((f) => f.uri)
          .expand((u) => ClassGraph.fromUri(u).importedEntityClassParser)
          ?.toList();
  } catch (e) {
    print(e);
  }

  print(cls.length);
  cls.map((f) => f.getName()).forEach((f) => print(f));

  _findRootNode(cls);
  _rootNodes.addAll(clsOuter.map((e)=>ClassNode(e)));

  clsOuter ??= <EntityClassParser>[];
  (clsOuter as List).addAll(cls);

  for (var node in _rootNodes) {
    TreeBuilderImpl().buildTree(node, clsOuter);
  }
  for (var node in _rootNodes) {
    var map = TreeToMapConverter().convert(node);
    maps.add(map);
  }
  var jsons = maps.map((m) => jsonEncode(m)).toList();
  jsons.forEach((j) => print(j));
}

void _findRootNode(dynamic _clsList) {
  if (_clsList == null) {
    return;
  }

  Iterator<EntityClassParser> it = _clsList.iterator;

  // find out all root node.
  // 找到所有没有extends语句的类，把他们作为顶级类，加入到rootNodes
  while (it.moveNext()) {
    EntityClassParser cls = it.current;
    ClassNode node = ClassNode(cls);
    if (cls.getSuper() == null) {
      // print(cls.clazz.name.name);
      _rootNodes.add(node);
    }
  }
}
