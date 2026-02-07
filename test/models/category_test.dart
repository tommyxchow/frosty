import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/category.dart';

void main() {
  group('CategoryTwitch', () {
    test('fromJson deserializes snake_case fields', () {
      final category = CategoryTwitch.fromJson(const {
        'box_art_url': 'https://cdn/boxart.jpg',
        'id': '509658',
        'name': 'Just Chatting',
      });

      expect(category.boxArtUrl, 'https://cdn/boxart.jpg');
      expect(category.id, '509658');
      expect(category.name, 'Just Chatting');
    });
  });

  group('CategoriesTwitch', () {
    test('fromJson deserializes data list and pagination', () {
      final categories = CategoriesTwitch.fromJson(const {
        'data': [
          {
            'box_art_url': 'https://cdn/boxart.jpg',
            'id': '509658',
            'name': 'Just Chatting',
          },
        ],
        'pagination': {'cursor': 'cat_cursor'},
      });

      expect(categories.data.length, 1);
      expect(categories.data.first.name, 'Just Chatting');
      expect(categories.pagination?['cursor'], 'cat_cursor');
    });

    test('fromJson handles empty data list', () {
      final categories = CategoriesTwitch.fromJson(const {
        'data': <dynamic>[],
        'pagination': <String, String>{},
      });

      expect(categories.data, isEmpty);
    });

    test('fromJson handles null pagination', () {
      final categories = CategoriesTwitch.fromJson(const {
        'data': <dynamic>[],
        'pagination': null,
      });

      expect(categories.pagination, isNull);
    });
  });
}
