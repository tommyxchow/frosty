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

  factory CategoryTwitch.fromJson(Map<String, dynamic> json) => _$CategoryTwitchFromJson(json);
}

class CategoriesTwitch {
  final List<CategoryTwitch> data;
  final String cursor;

  const CategoriesTwitch(
    this.data,
    this.cursor,
  );
}
