import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _biggerTextButtonsKey = 'biggerTextButtons';

final biggerTextButtonsNotifier = ValueNotifier<bool>(false);

bool get biggerTextButtonsEnabled => biggerTextButtonsNotifier.value;

Future<void> loadBiggerTextButtonsSetting() async {
  final prefs = await SharedPreferences.getInstance();
  biggerTextButtonsNotifier.value = prefs.getBool(_biggerTextButtonsKey) ?? false;
}

Future<void> saveBiggerTextButtonsSetting(bool value) async {
  biggerTextButtonsNotifier.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_biggerTextButtonsKey, value);
}
