import 'dart:convert';
import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:json2entity/src/ast/abs.dart';

class MyEnvironmentProvider extends EnvironmentProvider {
  getDartHome() {
    ProcessResult result = Process.runSync('which', ['dart']);
    if (result.exitCode != 0) {
      print(result.stderr);
      throw Exception(
          '执行命令：which dart 发生错误，code: ${result.exitCode}');
    }
    return Uri.parse(result.stdout.toString().replaceFirst('/bin/dart', '/lib'));
  }

  @deprecated
  @override
  getPackages() {
    var root = getProjectRoot();
    ProcessResult result =
        Process.runSync('pub', ['list-package-dirs'], workingDirectory: root);
    if (result.exitCode != 0) {
      print(result.stderr);
      throw Exception(
          '执行命令：pub list-package-dirs 发生错误，code: ${result.exitCode}');
    }
    return result.stdout;
  }

  @override
  getProjectRoot() {
    return Platform.environment['PWD'];
  }

  @override
  getPackagePath(String name) {
    var map = getPackageList();
    if (map == null) {
      return null;
    }
    return map[name];
  }

  @override
  getPackageList() {
    var root = getProjectRoot();
    ProcessResult result =
        Process.runSync('pub', ['list-package-dirs'], workingDirectory: root);
    if (result.exitCode != 0) {
      print(result.stderr);
      throw Exception(
          '执行命令：pub list-package-dirs 发生错误，code: ${result.exitCode}');
    }
    Map<String, dynamic> jmap = jsonDecode(result.stdout);
    if (jmap.containsKey('packages')) ;
    return jmap['packages'];
  }
}

class FileTraversal<String> extends Traversal {
  @override
  List<FileSystemEntity> traverse(entry) {
    var dir = new Directory.fromUri(Uri.parse(entry));
    List<FileSystemEntity> files =
        dir.listSync(recursive: true, followLinks: true);
    return files;
  }
}

class DartFileTraversal extends FileTraversal {
  @override
  traverse(entry) {
    return super.traverse(entry).where((f) => isDartFile(f.path)).toList();
  }

  bool isDartFile(String path) {
    return path.endsWith('.dart');
  }
}

class SingleFileProvider extends Traversal {
  @override
  traverse(entry) {
    return entry;
  }
}

/// parse import directives from file
class PackageImportResolver extends ImportResolver {
  @override
  resolve(input) {
    var src = File.fromUri(input);
    var compilationUnit = parseCompilationUnit(src.readAsStringSync());
    var imports = compilationUnit.directives.where((d)=>d is ImportDirective).toList();
    return imports;
  }
}

main(List<String> args) {
  Uri uri = MyEnvironmentProvider().getDartHome();
  print(uri.path);
}