import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deep_art/deep_art.dart';

void main() {
  const MethodChannel channel = MethodChannel('deep_art');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DeepArt.platformVersion, '42');
  });
}
