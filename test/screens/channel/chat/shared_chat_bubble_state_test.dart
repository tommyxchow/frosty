import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/chat/stores/shared_chat_bubble_state.dart';

void main() {
  late SharedChatBubbleState state;
  setUp(() => state = SharedChatBubbleState());

  test('a channel is neither focused nor hidden by default', () {
    expect(state.isFocused('1'), isFalse);
    expect(state.isHidden('1'), isFalse);
  });

  test('toggleFocus spotlights an unfocused channel', () {
    state.toggleFocus('1');
    expect(state.isFocused('1'), isTrue);
  });

  test('toggleFocus un-spotlights an already-focused channel', () {
    state.toggleFocus('1');
    state.toggleFocus('1');
    expect(state.isFocused('1'), isFalse);
  });

  test('multiple channels can be spotlighted at once', () {
    state.toggleFocus('1');
    state.toggleFocus('2');
    expect(state.isFocused('1'), isTrue);
    expect(state.isFocused('2'), isTrue);
  });

  test('hide filters a channel and drops it from the spotlight', () {
    state.toggleFocus('1');
    state.hide('1');
    expect(state.isHidden('1'), isTrue);
    expect(state.isFocused('1'), isFalse);
  });

  test('toggleFocus is a no-op for a hidden channel', () {
    state.hide('1');
    state.toggleFocus('1');
    expect(state.isFocused('1'), isFalse);
  });

  test('show lifts a hide', () {
    state.hide('1');
    state.show('1');
    expect(state.isHidden('1'), isFalse);
  });

  test('reset clears both focused and hidden channels', () {
    state.toggleFocus('1');
    state.hide('2');
    state.reset();
    expect(state.isFocused('1'), isFalse);
    expect(state.isHidden('2'), isFalse);
  });
}
