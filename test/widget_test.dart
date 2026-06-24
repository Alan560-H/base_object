import 'package:base_object/app/app.dart';
import 'package:base_object/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await bootstrap();
  });

  test('bootstrap 后 App 可构造', () {
    expect(const App(), isA<StatefulWidget>());
  });
}
