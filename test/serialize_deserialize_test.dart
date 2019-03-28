import 'dart:convert';

import 'package:test_api/test_api.dart';

import '../example/example.dart';
import '../example/output/json_f6.dart';
import 'output_test.dart';

/// json6 含有 user_id 风格的 key，
/// 首先，序列化为j6，
/// 然后，反序列化为json6_2
/// 再次，序列化为j6_2
/// assert j6 == j6_2
main() {
  var j6 = JsonF6.fromJson(jsonDecode(json6));
  var json6_2 = jsonEncode(j6.toJson());
  var j6_2 = JsonF6.fromJson(jsonDecode(json6_2));

  group('JsonKey test', () {
    assertTrue(j6.data[0].imageList.length == j6_2.data[0].imageList.length);
    assertTrue(j6.data[0].articleUrl == j6_2.data[0].articleUrl);
    assertTrue(j6.data[0].coverImageUrl == j6_2.data[0].coverImageUrl);
    assertTrue(j6.data[0].gallaryFlag == j6_2.data[0].gallaryFlag);
    assertTrue(j6.data[0].galleryImageCount == j6_2.data[0].galleryImageCount);
  });
}
