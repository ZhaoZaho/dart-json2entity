import 'dart:io';


abstract class Traversal<T> {
  List<FileSystemEntity> traverse(T entry);
}

class ParsedClassInfo {
  var imported;
  var importedWithBase;
  var classes;
  var classesWithImported;
  ParsedClassInfo(Uri uri) {
    if (!uri.pathSegments.last.endsWith('.dart')) {
      throw new ArgumentError(
            'The URI of the unit to patch must have the ".dart" suffix: $uri');
    }
    
  }
}

abstract class ImportResolver {
  resolve(input);
}

abstract class ClassScanner {
  scan(files);
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
    var classes = classScanner.scan(input);
    var rootNodes = nodeScanner.scan(classes);
    var pool = poolMaker.makePool(classes, imports);
    treeBuilder.build(classes, pool);
    var maps = mapConverter.convert(rootNodes);
  }
}

main(List<String> args) {
  var uri = Uri.parse('/a/b/c/ddd.dart');
  print(uri.pathSegments.last);
}