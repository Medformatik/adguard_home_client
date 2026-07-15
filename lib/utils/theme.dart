import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

const _themeModeKey = 'themeMode';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

void loadThemeMode() {
  final value = Hive.box('settings').get(_themeModeKey, defaultValue: 'system');
  themeModeNotifier.value = switch (value?.toString()) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

Future<void> saveThemeMode(ThemeMode mode) async {
  await Hive.box('settings').put(_themeModeKey, mode.name);
  themeModeNotifier.value = mode;
}
