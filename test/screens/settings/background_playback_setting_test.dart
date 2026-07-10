import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

void main() {
  test('backgroundPlayback defaults to false', () {
    final store = SettingsStore.fromJson({});
    expect(store.backgroundPlayback, isFalse);
  });

  test('backgroundPlayback round-trips through json', () {
    final store = SettingsStore.fromJson({})..backgroundPlayback = true;
    final restored = SettingsStore.fromJson(store.toJson());
    expect(restored.backgroundPlayback, isTrue);
  });
}
