import 'dart:convert';

import 'package:json2entity/src/ast/provider.dart';
import 'package:json2entity/src/ast/resolver.dart';
import "package:test/test.dart";


main() {
  group('Group one', () {
    test('getPackages', () {
      var json = MyEnvironmentProvider().getPackages();
      var jmap = jsonDecode(json);
      print(jmap['packages']['json2entity']);
      expect(jmap['packages']['json2entity'], '/Users/leochou/Github/dart-json2entity/lib');
    });

    test('test getPackagePath', (){
      var path = MyEnvironmentProvider().getPackagePath('json2entity');
      expect(path, '/Users/leochou/Github/dart-json2entity/lib');
    });
  });

  group('PackageUriResolver', (){
    test('resolverUri', (){
      var source = PackageUriResolver().resolveAbsolute(Uri.parse('package:json2entity/src/resolver.dart'));
      print(source);
      print(source.contents);
      expect(source.fullName, '/Users/leochou/Github/dart-json2entity/lib/src/resolver.dart');
    });
  });
}
