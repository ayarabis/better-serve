import 'package:equatable/equatable.dart';

class Pair<T, K> extends Equatable {
  final T key;
  final K value;

  const Pair(this.key, this.value);

  Pair.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };

  @override
  List<Object?> get props => [key, value];
}
