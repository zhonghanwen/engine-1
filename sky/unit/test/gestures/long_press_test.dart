import 'package:quiver/testing/async.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

final PointerInputEvent down = new PointerInputEvent(
  pointer: 5,
  type: 'pointerdown',
  x: 10.0,
  y: 10.0
);

final PointerInputEvent up = new PointerInputEvent(
  pointer: 5,
  type: 'pointerup',
  x: 11.0,
  y: 9.0
);

void main() {
  test('Should recognize long press', () {
    PointerRouter router = new PointerRouter();
    LongPressGestureRecognizer longPress = new LongPressGestureRecognizer(router: router);

    bool longPressRecognized = false;
    longPress.onLongPress = () {
      longPressRecognized = true;
    };

    new FakeAsync().run((FakeAsync async) {
      longPress.addPointer(down);
      GestureArena.instance.close(5);
      expect(longPressRecognized, isFalse);
      router.route(down);
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(milliseconds: 300));
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(milliseconds: 700));
      expect(longPressRecognized, isTrue);
    });

    longPress.dispose();
  });

  test('Up cancels long press', () {
    PointerRouter router = new PointerRouter();
    LongPressGestureRecognizer longPress = new LongPressGestureRecognizer(router: router);

    bool longPressRecognized = false;
    longPress.onLongPress = () {
      longPressRecognized = true;
    };

    new FakeAsync().run((FakeAsync async) {
      longPress.addPointer(down);
      GestureArena.instance.close(5);
      expect(longPressRecognized, isFalse);
      router.route(down);
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(milliseconds: 300));
      expect(longPressRecognized, isFalse);
      router.route(up);
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(seconds: 1));
      expect(longPressRecognized, isFalse);
    });

    longPress.dispose();
  });

  test('Should recognize both show press and long press', () {
    PointerRouter router = new PointerRouter();
    ShowPressGestureRecognizer showPress = new ShowPressGestureRecognizer(router: router);
    LongPressGestureRecognizer longPress = new LongPressGestureRecognizer(router: router);

    bool showPressRecognized = false;
    showPress.onShowPress = () {
      showPressRecognized = true;
    };

    bool longPressRecognized = false;
    longPress.onLongPress = () {
      longPressRecognized = true;
    };

    new FakeAsync().run((FakeAsync async) {
      showPress.addPointer(down);
      longPress.addPointer(down);
      GestureArena.instance.close(5);
      expect(showPressRecognized, isFalse);
      expect(longPressRecognized, isFalse);
      router.route(down);
      expect(showPressRecognized, isFalse);
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(milliseconds: 300));
      expect(showPressRecognized, isTrue);
      expect(longPressRecognized, isFalse);
      async.elapse(new Duration(milliseconds: 700));
      expect(showPressRecognized, isTrue);
      expect(longPressRecognized, isTrue);
    });

    showPress.dispose();
    longPress.dispose();
  });
}
