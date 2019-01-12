import 'dart:convert';
import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:json2entity/src/class_parser.dart';

// Uri srcUri = Uri.parse(
// '/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.1/lib/src/dart/ast/ast.dart');
Uri srcUri = Uri.parse(
    '/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.1/lib/dart/ast/ast.dart');

typedef classFilter = int Function(Object a, Object b);

class MyNode {
  EntityClassParser curr;
  MyNode pre;
  List<MyNode> children = [];

  MyNode(this.curr, [this.pre, MyNode child]) {
    if (child != null) {
      children.add(child);
    }
  }
}

MyNode root;
List<MyNode> rootNodes = <MyNode>[];
List<MyNode> sortedNodes = <MyNode>[];

main(List<String> args) {
  var src = File.fromUri(srcUri).readAsStringSync();
  CompilationUnit compilationUnit = parseCompilationUnit(src);
  if (compilationUnit.declarations.length < 1) {
    throw Exception('NO CLASS DECLARATION FOUND ERROR!');
  }
  var clsList = compilationUnit.declarations
      .toList()
      .where((item) => item is ClassDeclaration)
      .map((cls) => EntityClassParser.fromClassDeclaration(cls));
  // for (var cls in clsList) {
  //   if (cls.getSuper() != null) {
  //     print('${cls.clazz.name}  -->  ${cls.getSuper().name}');
  //   }
  // }
  convert(clsList);
}

Iterable<EntityClassParser> findChildren(
    Iterable<EntityClassParser> clsList, String superName) {
  return clsList.where((cls) {
    return cls.getSuper() != null && cls.getSuper().name.name == superName;
  }).toList();
}

void convert(Iterable<EntityClassParser> clsList) {
  Iterator<EntityClassParser> it = clsList.iterator;

  // find out all root node.
  while (it.moveNext()) {
    EntityClassParser cls = it.current;
    MyNode node = MyNode(cls);
    if (cls.getSuper() == null) {
      print(cls.clazz.name.name);
      sortedNodes.add(node);
    }
  }

  Iterator<MyNode> it2 = sortedNodes.iterator;

  for (var node in sortedNodes) {
    // For every root node

    Iterable<EntityClassParser> children;
    List<MyNode> pending = [node];
    while (pending.length > 0) {
      MyNode the = pending.removeAt(0);
      children = findChildren(clsList, the.curr.clazz.name.name);

      // nil node, continue
      if (children == null || children.length == 0) continue;

      for (var child in children) {
        // she cNode's parent
        MyNode cNode = MyNode(child, the);

        // parent's child
        the.children.add(cNode);
        pending.add(cNode);
      }
    }
  }
  print('object');
  printTree(sortedNodes.elementAt(3));
}

get emptyMap => <String, dynamic>{};

printTree(MyNode root) {
  if (root == null) {
    return;
  }
  String name = root.curr.getName();

  Map<String, dynamic> rootMap = emptyMap;
  rootMap[name] = emptyMap;
  List<MyNode> pending = [root];
  while (pending.length > 0) {
    // travel curr node,
    MyNode currNode = pending.removeAt(0);
    String key = currNode.curr.getName();
    Map<String, dynamic> innerMap = getCurrMap(currNode, rootMap);
    if (currNode.children.length == 0) continue;

    for (var child in currNode.children) {
      String key = child.curr.getName();
      innerMap[key] = emptyMap;
      pending.add(child);
    }
  }

  String json = jsonEncode(rootMap);
  print(json);
}

getCurrMap(MyNode node, Map<String, dynamic> rootMap) {
  MyNode tmp = node;
  List<String> path = [];
  path.add(tmp.curr.getName());
  while (tmp.pre != null) {
    tmp = tmp.pre;
    path.add(tmp.curr.getName());
  }
  Map<String, dynamic> tmpMap = rootMap;

  for (var i = path.length - 1; i >= 0; i--) {
    var key = path[i];
    tmpMap = tmpMap[key];
  }
  return tmpMap;
}
