// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryTwitch _$CategoryTwitchFromJson(Map<String, dynamic> json) =>
    CategoryTwitch(
      json['box_art_url'] as String,
      json['id'] as String,
      json['name'] as String,
    );

CategoriesTwitch _$CategoriesTwitchFromJson(Map<String, dynamic> json) =>
    CategoriesTwitch(
      (json['data'] as List<dynamic>)
          .map((e) => CategoryTwitch.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['pagination'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );
