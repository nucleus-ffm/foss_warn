enum DataFetchStatus {
  no_info,
  success,
  error;
  String toJson() => name;
  static DataFetchStatus fromJson(String json) => values.byName(json);
}
