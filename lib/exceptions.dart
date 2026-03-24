/// 自定义异常类

class MissingContentException implements Exception {
  @override
  String toString() => '缺少笔记内容';
}

class MissingKeywordException implements Exception {
  @override
  String toString() => '缺少搜索关键词';
}

class ConflictingTimeOptionsException implements Exception {
  @override
  String toString() => '时间选项冲突，只能使用一个时间筛选选项';
}
