import 'dart:convert';
import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:json2entity/src/ast/class_parser.dart';

/// A [ClassNode] represents a node in inheritance tree
/// 将类的继承关系描绘成一棵多树，[ClassNode]则是树上的一个节点
class ClassNode {
  EntityClassParser curr;
  ClassNode pre;
  List<ClassNode> children = [];

  ClassNode(this.curr, [this.pre, ClassNode child]) {
    if (child != null) {
      children.add(child);
    }
  }
}


abstract class Graph {

  Graph(this._src, [this._uri]);

  Uri _uri;

  /// Dart file uri
  Uri get uri => _uri;

  String _src;

  /// Dart source code
  String get src => _src;

  List<EntityClassParser> _clsList;
  
  /// All classes declared
  List<EntityClassParser> get clsList => _clsList;

  List<ClassNode> _rootNodes = <ClassNode>[];

  /// A list of nodes those have no explicit superclass
  List<ClassNode> get rootNodes => _rootNodes;
  
  List<Map<String, dynamic>> _maps;

  /// result maps
  List<Map<String, dynamic>>  get maps => _maps;

  /// result JSONs
   List<String> get jsons => _maps.map((m)=>jsonEncode(m)).toList();
}

/// 读取dart源码，将类的继承关系（extends）转化成map，通过工具，可视化展示
class ClassGraph extends Graph {

  ClassGraph.fromUri(Uri _uri): super(null, _uri) {
    _init();
  }

  ClassGraph.fromSrc(String src) : super(src) {
    _init();
  }

  /// read all class declarations to a List and return.
  getClassList() {
    if (_clsList != null) {
      return;
    }

    var src = _src ?? File.fromUri(_uri).readAsStringSync();
    CompilationUnit compilationUnit = parseCompilationUnit(src);

    // if (compilationUnit.declarations.length < 1) {
    //   throw Exception('NO CLASS DECLARATION FOUND ERROR!');
    // }

    // 读取源码中的类声明到列表
    _clsList = compilationUnit.declarations
        .where((item) => item is ClassDeclaration)
        .map((cls) => EntityClassParser.fromClassDeclaration(cls))
        .toList();
  }

  // find root nodes
  void _findRootNode() {
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

  void _generateNodeTree() {
    // 每个root node，分别寻找自己的子node，直到没有node
    for (var node in _rootNodes) {
      // For every root node
      TreeBuilderImpl().buildTree(node, _clsList);
    }
  }

  List<Map<String, dynamic>> _convertTreeToMap() {
    List<Map<String, dynamic>> maps = <Map<String, dynamic>>[];
    for (var root in _rootNodes) {
      var map = TreeToMapConverter().convert(root);
      maps.add(map);
    }
    return maps;
  }

  showJson() {
    _maps.where((item) => item != null && item.isNotEmpty).forEach((m) {
      print('\n-----:\n');
      print(jsonEncode(m));
    });
  }

  void _init() {
    // find all class declared in file
    getClassList();

    // find all root node. If a node who has no explicit super class
    _findRootNode();

    // 每个root node向下寻找直接子类，生成node树
    _generateNodeTree();

    // 由于dart是单继承，所以父类对子类是1：n，每棵树可以转化成对应的json结构
    // key是父类的名字，value是子类们的名字组成的map
    // 没有子类的类，也就是树上的叶子节点，在json 上对应的value是""{}"
    _maps = _convertTreeToMap();

  }
}

abstract class MapConverter {
  Map<String, dynamic> convert(ClassNode rootNode);
}

class TreeToMapConverter implements MapConverter {

  get emptyMap => <String, dynamic>{};

  @override
  Map<String, dynamic> convert(ClassNode root) {

    if (root == null) {
      return null;
    }
    String name = root.curr.getName();

    Map<String, dynamic> rootMap = emptyMap;
    rootMap[name] = emptyMap;
    List<ClassNode> pending = [root];
    while (pending.length > 0) {
      // travel curr node,
      ClassNode currNode = pending.removeAt(0);
      String key = currNode.curr.getName();
      Map<String, dynamic> innerMap = _getCurrMap(currNode, rootMap);
      if (currNode.children.length == 0) continue;

      for (var child in currNode.children) {
        String key = child.curr.getName();
        innerMap[key] = emptyMap;
        pending.add(child);
      }
    }

    return rootMap;
  }


  /// rootMap 对应一个tree，
  /// 这个方法的功能是根据子节点，找到节点在rootMap中的位置。
  _getCurrMap(ClassNode node, Map<String, dynamic> rootMap) {
    ClassNode tmp = node;
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
}


abstract class TreeBuilder{
  void buildTree(ClassNode root, List<EntityClassParser> clsList);
}

class TreeBuilderImpl extends TreeBuilder{
  @override
  void buildTree(ClassNode node, List<EntityClassParser> clsList) {
    
    Iterable<EntityClassParser> children;
    List<ClassNode> pending = [node];
    while (pending.length > 0) {
      ClassNode the = pending.removeAt(0);
      children = _findChildren(the.curr.clazz.name.name, clsList);

      // nil node, continue
      if (children == null || children.length == 0) continue;

      for (var child in children) {
        // she cNode's parent
        ClassNode cNode = ClassNode(child, the);

        // parent's child
        the.children.add(cNode);
        pending.add(cNode);
      }
    }
  }

  /// 从[ClassDeclaration]列表中，找到直接父类是superName的，并返回
  Iterable<EntityClassParser> _findChildren(String superName, List<EntityClassParser> _clsList) {
    if (_clsList == null || _clsList.isEmpty || superName == null) {
      return null;
    }

    return _clsList.where((cls) {
      return cls.getSuper() != null && cls.getSuperName() == superName;
    }).toList();
  }
}


// Uri srcUri = Uri.parse('/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.1/lib/src/dart/ast/ast.dart');
// Uri srcUri = Uri.parse('/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/args-1.5.1/lib/command_runner.dart');
// Uri srcUri = Uri.parse('/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/kernel-0.3.7/lib/ast.dart');
// Uri srcUri = Uri.parse('/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.1/lib/dart/ast/ast.dart');
Uri srcUri = Uri.parse('/Users/leochou/Github/dart-json2entity/sample/a.dart');
main(List<String> args) {
  ClassGraph cg = new ClassGraph.fromUri(srcUri);
  cg.showJson();
  cg.jsons.forEach((j)=>print(j));
}
