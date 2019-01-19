import 'dart:convert';

import 'package:json2entity/src/ast/abs.dart';
import 'package:json2entity/src/ast/class_graph.dart';
import 'package:json2entity/src/ast/class_parser.dart';
import 'package:json2entity/src/ast/list_packages.dart';

List<ClassNode> _rootNodes = <ClassNode>[];
List<Map<String, dynamic>> maps = [];
main(List<String> args) {
  var root = MyEnvironmentProvider().getPackagePath('json2entity');
  print(root);
  var files = new DartFileTraversal().traverse('$root');
//  files = files.where((f)=>f.uri.path.contains('byte_stream.dart')).toList();
  print(files);

  var cls;
  try {
    cls = files
          .map((f) => f.uri)
          .expand((u) => ParsedSourceImpl.fromUri(u).clsList)
          ?.toList();
  } catch (e) {
    print(e);
  }

  Iterable clsOuter;
  try {
    clsOuter = files
          .map((f) => f.uri)
          .expand((u) => ParsedSourceImpl.fromUri(u).findImportedClass())
          ?.toList();
  } catch (e) {
    print(e);
  }

  print(cls.length);
  cls.map((f) => f.getName()).forEach((f) => print(f));

  _rootNodes.addAll(RootFinderImpl().findRoot(cls));
  if (clsOuter != null) {
    _rootNodes.addAll(clsOuter.map((e)=>ClassNode(e)));
  }

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
