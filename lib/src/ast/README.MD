## 解析包内类图

#### 1. original input
- 目录
- 文件
InputProvider
    provide();

#### 2. dart file scan
FileScanner

#### 3. import resolve
ImportResolver

#### 4. class scan
ClassScanner

#### 5. root node
NodeFinder

#### 6. build tree
TreeBuilder

#### 7. convert to map
MapConverter

#### 8. convert to json
dart.io

#### 9. info filter