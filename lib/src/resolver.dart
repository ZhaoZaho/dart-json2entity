import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

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
