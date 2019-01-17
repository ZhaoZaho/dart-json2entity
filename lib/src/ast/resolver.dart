import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/source/source_resource.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:json2entity/src/ast/list_packages.dart';
import 'package:path/path.dart';

main() async {
  var path =
      '/Users/leochou/.pub-cache/hosted/pub.flutter-io.cn/analyzer-0.34.0/lib/analyzer.dart';
  ResolvedUnitResult result = await resolveFile(path);
  CompilationUnit resolvedUnit = result.unit;
  CompilationUnitElement element = resolvedUnit.declaredElement;
}

Future<ResolvedUnitResult> resolveFile(String path) async {
  AnalysisContextCollection collection = new AnalysisContextCollection(
    includedPaths: <String>[path],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  AnalysisContext context = collection.contextFor(path);
  return await context.currentSession.getResolvedUnit(path);
}


class PackageUriResolver extends UriResolver {

  static const String PACKAGE_SCHEME = 'package';

  @override
  Source resolveAbsolute(Uri uri, [Uri actualUri]) {
    uri ??= actualUri;
    if (uri.scheme != PACKAGE_SCHEME) {
      return null;
    }
    // Prepare path.
    String path = uri.path;
    // Prepare path components.
    int index = path.indexOf('/');
    if (index == -1 || index == 0) {
      return null;
    }
    // <pkgName>/<relPath>
    String pkgName = path.substring(0, index);
    String packageRoot = MyEnvironmentProvider().getPackagePath(pkgName);
    String relPath = path.substring(index + 1);
    String fullPath = join(packageRoot, relPath);
    var file = PhysicalResourceProvider.INSTANCE.getFile(fullPath);
    return new FileSource(file);
  }

}
