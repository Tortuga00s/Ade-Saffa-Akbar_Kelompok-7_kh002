
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff2563EB),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  );
}
