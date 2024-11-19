enum Category {
  Geo, // Geophysical (inc. landslide)
  Met, // Meteorological (inc. flood)
  Safety, // General emergency and public safety
  Rescue, // Rescue and recovery
  Fire, // Fire suppression and rescue
  Health, //Medical and public health
  Env, //Pollution and other environmental
  Transport, //Public and private   transportation
  Infra, //Utility, telecommunication, other  non-transport infrastructure
  CBRNE, //Chemical, Biological, Radiological, Nuclear or High-Yield Explosive threat or attack
  Other; // Other events

  String toJson() => name;
  // static Category fromJson(String json) => values.byName(json);

  static List<Category> categoryListFromJson(var data) {
    List<Category> _result = [];
    if(data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Category.fromString(data[i]));
      }
    }
    return _result;
  }

  /// extract the severity from the string and return the corresponding enum
  static Category fromString(String category) {
    for (Category cat in Category.values) {
      if (cat.name == category) {
        return cat;
      }
    }
    return Category.Other; //@todo what should be the default value?
  }
}
