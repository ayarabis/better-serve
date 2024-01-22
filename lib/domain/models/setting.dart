class Setting {
  final String _key;
  dynamic value;
  int? id;

  Setting(this._key, this.value, [this.id]);

  String get key => _key;

  static Setting fromMap(Map<String, dynamic> map) =>
      Setting(map['key'], map["value"], map['id']);

  @override
  String toString() {
    return "SettingOption(key: $_key, value: $value)";
  }
}
