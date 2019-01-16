import 'dart:convert';

import 'package:json2entity/src/class_graph.dart';
import 'package:json2entity/src/class_parser.dart';
import 'package:json2entity/src/list_packages.dart';

List<ClassNode> _rootNodes = <ClassNode>[];
List<Map<String, dynamic>> maps = [];
main(List<String> args) {
  var root = MyEnvironmentProvider().getPackagePath('analyzer');
  print(root);
  var files = new DartFileTraversal().traverse('$root');
  print(files);

  var cls = files
      .map((f) => f.uri)
      .expand((u) => ClassGraph.fromUri(u).clsList)
      ?.toList();
  print(cls.length);

  _findRootNode(cls);

  for (var node in _rootNodes) {
    TreeBuilderImpl().buildTree(node, cls);
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
      print(cls.clazz.name.name);
      _rootNodes.add(node);
    }
  }
}
