import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CategoryTwitch {
  final String boxArtUrl;
  final String id;
  final String name;

  const CategoryTwitch(
    this.boxArtUrl,
    this.id,
    this.name,
  );

  factory CategoryTwitch.fromJson(Map<String, dynamic> json) =>
      _$CategoryTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CategoriesTwitch {
  final List<CategoryTwitch> data;
  final Map<String, String>? pagination;

  const CategoriesTwitch(
    this.data,
    this.pagination,
  );

  factory CategoriesTwitch.fromJson(Map<String, dynamic> json) =>
      _$CategoriesTwitchFromJson(json);
}
