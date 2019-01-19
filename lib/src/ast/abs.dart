import 'dart:io';

import 'package:json2entity/src/ast/class_graph.dart';
import 'package:json2entity/src/ast/class_parser.dart';
import 'package:json2entity/src/ast/list_packages.dart';


abstract class Traversal<T> {
  List<FileSystemEntity> traverse(T entry);
}

abstract class ImportResolver {
  resolve(input);
}

abstract class ClassScanner<T> {
  Iterable<T> scan(Iterable<Uri> files);
}

abstract class NodeScanner {
  scan(classes);
}

abstract class PoolMaker {
  makePool(src, added);
}

abstract class TreeBuilder {
  build(root, pool);
}

abstract class MapConverter {
  convert(roots);
}

abstract class EnvironmentProvider {
  getProjectRoot();
  getPackages();
  getPackageList();
  getPackagePath(String name);
}

abstract class RootFinder {
  Iterable findRoot(Iterable clsList);
}

class RootFinderImpl extends RootFinder {

  List<ClassNode> _rootNodes = <ClassNode>[];
  @override
  findRoot(dynamic _clsList) {
    if (_clsList == null) {
      return null;
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
    return _rootNodes;
  }
}


abstract class Composer {
  PoolMaker poolMaker;
  Traversal traversal;
  ClassScanner classScanner;
  ImportResolver importResolver;
  NodeScanner nodeScanner;
  TreeBuilder treeBuilder;
  MapConverter mapConverter;
  EnvironmentProvider environmentProvider;

  Composer(
      {this.poolMaker,
      this.traversal,
      this.classScanner,
      this.importResolver,
      this.nodeScanner,
      this.treeBuilder,
      this.mapConverter,
      this.environmentProvider});

  void execute();
}

class OneComposer extends Composer {
  OneComposer(
    PoolMaker poolMaker,
    Traversal traversal,
    ClassScanner classScanner,
    ImportResolver importResolver,
    NodeScanner nodeScanner,
    TreeBuilder treeBuilder,
    MapConverter mapConverter,
    EnvironmentProvider environmentProvider,
  ) : super(
            poolMaker: poolMaker,
            traversal: traversal,
            classScanner: classScanner,
            importResolver: importResolver,
            nodeScanner: nodeScanner,
            treeBuilder: treeBuilder,
            mapConverter: mapConverter,
            environmentProvider: environmentProvider);

  @override
  void execute() {
    List<FileSystemEntity> input = traversal.traverse('input');
    var imports = importResolver.resolve(input.map((f)=>f));
    var classes = classScanner.scan(input.map((f)=>f.uri));
    var rootNodes = nodeScanner.scan(classes);
    var pool = poolMaker.makePool(classes, imports);
    treeBuilder.build(classes, pool);
    var maps = mapConverter.convert(rootNodes);
  }
}

class SingleFileScanner extends ClassScanner<EntityClassParser> {
  @override
  List<EntityClassParser> scan(Iterable<Uri> files, [String forName]) {
    Uri uri = files.single;
    if (forName == null) {
      return ParsedSourceImpl.fromUri(uri).clsList;
    } else {
      return ParsedSourceImpl.fromUri(uri).clsList.where((c)=>c.getName() == forName).toList();
    }
  }
}

class FileScanner extends ClassScanner<EntityClassParser> {
  @override
  Iterable<EntityClassParser> scan(Iterable<Uri> files, [String forName]) {
    if (forName == null) {
      return files?.expand((f)=>ParsedSourceImpl.fromUri(f).clsList);
    } else {
      return files?.expand((f)=>ParsedSourceImpl.fromUri(f).clsList.where((c)=>c.getName() == forName)).toList();
    }
  }
}

main(List<String> args) {
  var uri = Uri.parse('/a/b/c/ddd.dart');
  print(uri.pathSegments.last);

  var traverse = DartFileTraversal().traverse('/Users/etiantian/flutter/flutter-0.10.0/bin/cache/dart-sdk/lib/async');
  var list = FileScanner().scan(traverse.map((f)=>f.uri).toList(), 'BaseRequest');
  print(list.length);
}