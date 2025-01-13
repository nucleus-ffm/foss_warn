enum DataFetchStatus {
  noinfo,
  success,
  error;

  String toJson() => name;
  static DataFetchStatus fromJson(String json) =>
      json == "no_info" ? DataFetchStatus.noinfo : values.byName(json);
}
