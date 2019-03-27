/// 获取类型v的类型，对应于json的六种类型
getType(dynamic v) {
  if (v is String) {
    return 'String';
  } else if (v is num) {
    return 'num';
  } else if (v is bool) {
    return 'bool';
  } else if (v is List) {
    return 'List';
  } else if (v == null) {
    return 'String';
  } else {
    return 'Object';
  }
}

/// 将首字母大写
String capitalize(String k) {
  if (k != null && k.isNotEmpty) {
    return k[0].toUpperCase() + k.substring(1);
  }
  return k;
}

String uncapitalize(String k) {
  if (k != null && k.isNotEmpty) {
    return k[0].toLowerCase() + k.substring(1);
  }
  return k;
}

/// 驼峰转dash
String camel2dash(String k) {
  var codeUnits = k.codeUnits;
  Set<int> upper = new Set();
  String ret = '';
  int start = 0;

  for (int i = 0; i < codeUnits.length; i++) {
    var c = codeUnits[i];
    if (isUpperAZ(c)) {
      upper.add(i);
      if (i > 0) {
        ret += k.substring(start, i);
        ret += '_';
        start = i;
      }
    }
  }
  ret += k.substring(start);
  return ret.toLowerCase();
}

/// Determine whether ASCII corresponding to an integer value is a capital letter?
bool isUpperAZ(int c) {
  return c >= 65 && c <= 90;
}

bool isLowerAZ(int c) {
  return c >= 97 && c <= 122;
}

/// Print [info] when [b] is true.
printWhen(info, b) {
  if (b) {
    print(info);
  }
}

/// True if value == null or value has no data.
hasValue(dynamic value) {
  return value?.isNotEmpty ?? false;
}

bool notCamel(String s) {
  return !isCamel(s);
}

bool isCamel(String s) {
  if (s.isEmpty) {
    return false;
  }
  if (s.contains('-')) {
    return false;
  }
  if (s.contains('_')) {
    return false;
  }
  if (isUpperAZ(s.codeUnitAt(0))) {
    return false;
  }
  if (doubleUpper(s)) {
    return false;
  }
  return true;
}

bool doubleUpper(String s) {
  var codeUnits = s.codeUnits;
  for (var i = 0; i < codeUnits.length - 1; i++) {
    if (isUpperAZ(codeUnits[i]) && isUpperAZ(codeUnits[i + 1])) {
      return true;
    }
  }
  return false;
}

/// 变量命名风格：
/// Pascal: HelloWorld
/// kebab: hello-world
/// snake: hello_world
/// camel: helloWorld
/// 变量命名规则，统统转为camel风格：
/// 1. 连续大写字符保留首位，其余转小写
/// 2. 非首位大写字符前加'_'，'-'转'_'，如userId => user_Id
/// 3. 单词以'_'分割分组，如user_Id => ['user', 'Id']
/// 4. 重组，首单词小写，之后单词首字符大写
String camelize(String s) {
  if (s == null || s.isEmpty) {
    return s;
  }
  if (s.length == 1) {
    return s.toLowerCase();
  }
  var codeUnits = s.codeUnits;
  List<int> list = [];
  list.add(codeUnits.elementAt(0));
  for (var i = 1; i < codeUnits.length; i++) {
    if (isUpperAZ(codeUnits[i]) && isLowerAZ(codeUnits[i - 1])) {
      list.add(95); //_
    }
    list.add(codeUnits[i]);
  }
  var newS = String.fromCharCodes(list);
  newS = newS.replaceAll('-', '_');
  var words = newS.split('_');
  var joinStr = words.map((w) => capitalize(w.toLowerCase())).join();
  return uncapitalize(joinStr);
}

main(List<String> args) {
  print(camelize('s_HelloWorld'));
  print(camelize('UserID'));
  print(camelize('HelloWorld'));
  print(camelize('HELLO_XMAN'));
  print(camelize('hello-kitty'));
}
