enum Category {
  geo, // Geophysical (inc. landslide)
  met, // Meteorological (inc. flood)
  safety, // General emergency and public safety
  rescue, // Rescue and recovery
  fire, // Fire suppression and rescue
  health, //Medical and public health
  env, //Pollution and other environmental
  transport, //Public and private   transportation
  infra, //Utility, telecommunication, other  non-transport infrastructure
  cbrne, //Chemical, Biological, Radiological, Nuclear or High-Yield Explosive threat or attack
  other; // Other events

  String toJson() => name;
  // static Category fromJson(String json) => values.byName(json);

  static List<Category> categoryListFromJson(var data) {
    List<Category> result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        result.add(Category.fromString(data[i]));
      }
    }
    return result;
  }

  /// extract the severity from the string and return the corresponding enum
  static Category fromString(String category) {
    for (Category cat in Category.values) {
      if (cat.name == category.toLowerCase()) {
        return cat;
      }
    }
    return Category.other; //@todo what should be the default value?
  }
}
