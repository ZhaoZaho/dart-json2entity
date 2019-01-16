// import 'dart:io';

// import 'package:analyzer/analyzer.dart';
// import 'package:json2entity/src/class_parser.dart';

// Uri srcUri = Uri.parse(
//     '/Users/etiantian/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.0/lib/dart/ast/ast.dart');

// typedef classFilter = int Function(Object a, Object b);

// class MyNode {
//   EntityClassParser curr;
//   MyNode pre;
//   List<MyNode> children = [];

//   MyNode(this.curr, [this.pre, MyNode child]) {
//     if (child != null) {
//       children.add(child);
//     }
//   }
// }

// MyNode root;
// List<MyNode> rootNodes = <MyNode>[];
// List<MyNode> sortedNodes = <MyNode>[];

// main(List<String> args) {
//   var src = File.fromUri(srcUri).readAsStringSync();
//   CompilationUnit compilationUnit = parseCompilationUnit(src);
//   if (compilationUnit.declarations.length < 1) {
//     throw Exception('NO CLASS DECLARATION FOUND ERROR!');
//   }
//   var clsList = compilationUnit.declarations
//       .toList()
//       .where((item) => item is ClassDeclaration)
//       .map((cls) => EntityClassParser.fromClassDeclaration(cls));
//   // for (var cls in clsList) {
//   //   if (cls.getSuper() != null) {
//   //     print('${cls.clazz.name}  -->  ${cls.getSuper().name}');
//   //   }
//   // }
//   convert(clsList);
// }

// Iterable<EntityClassParser> findChildren(Iterable<EntityClassParser> clsList, String superName) {
//   return clsList.where((cls){
//     return cls.getSuper() != null && cls.getSuper().name.name == superName;
//   }).toList();
// }


// void convert(Iterable<EntityClassParser> clsList) {

//   Iterator<EntityClassParser> it = clsList.iterator;

//   while(it.moveNext()) {
//     EntityClassParser cls = it.current;
//     MyNode node = MyNode(cls);
//     if (cls.getSuper() == null) {
//       print(cls.clazz.name.name);
//       sortedNodes.add(node);
//     }
//   }

//   Iterator<MyNode> it2 = sortedNodes.iterator;

//   for (var node in sortedNodes) {

//     Iterable<EntityClassParser> children;
//     List<MyNode> pending = [node];
//     while(pending.length > 0) {
//       children = findChildren(clsList, pending.removeAt(0).curr.clazz.name.name);
//       if (children == null)
//         continue;

//       for (var child in children) {
//         MyNode cNode = MyNode(child, node);
//         node.child = cNode;
//         pending.add(cNode);
//       }
//     }
//   }
// }

// printTree(MyNode root) {

  

// }