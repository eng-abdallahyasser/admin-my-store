// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:admin_my_store/app/models/variant.dart';


class Option {
  int min;
  int max;
  String optionName;
  List<Variant> variants;
  List<Variant> choosedVariant;
  Option({
    required this.min,
    required this.max,
    required this.optionName,
    required this.variants,
    required this.choosedVariant,
  });
  

  Option copyWith({
    int? min,
    int? max,
    String? optionName,
    List<Variant>? variants,
    List<Variant>? choosedVariant,
  }) {
    return Option(
      min: min ?? this.min,
      max: max ?? this.max,
      optionName: optionName ?? this.optionName,
      variants: variants ?? List<Variant>.from(this.variants),
    choosedVariant: choosedVariant ?? List<Variant>.from(this.choosedVariant),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'min': min,
      'max': max,
      'optionName': optionName,
      'variants': variants.map((x) => x.toJson()).toList(),
      'choosedVariant': choosedVariant.map((x) => x.toJson()).toList(),
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      min: map['min'] as int,
      max: map['max'] as int,
      optionName: map['optionName'] as String,
      variants: List<Variant>.from((map['variants'] as List<int>).map<Variant>((x) => Variant.fromJson(x as Map<String,dynamic>),),),
      choosedVariant: List<Variant>.from((map['choosedVariant'] as List<int>).map<Variant>((x) => Variant.fromJson(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory Option.fromJson(String source) => Option.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Option(min: $min, max: $max, optionName: $optionName, variants: $variants, choosedVariant: $choosedVariant)';
  }

  @override
  bool operator ==(covariant Option other) {
    if (identical(this, other)) return true;
  
    return 
      other.min == min &&
      other.max == max &&
      other.optionName == optionName &&
      listEquals(other.variants, variants) &&
      listEquals(other.choosedVariant, choosedVariant);
  }

  @override
  int get hashCode {
    return min.hashCode ^
      max.hashCode ^
      optionName.hashCode ^
      variants.hashCode ^
      choosedVariant.hashCode;
  }
}
