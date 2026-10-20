
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final int d = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(
            16 + d.toDouble(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              8 + d.toDouble(),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              16 + d.toDouble(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 42 / 2,
                  child: Icon(
                    Icons.person,
                  ),
                ),

                SizedBox(
                  height: 8 + d.toDouble(),
                ),

                Text(
                  'Ade Saffa Akbar',
                ),

                Text(
                  '20240801071',
                ),

                Text(
                  'Program Studi Informatika',
                ),

                Text(
                  'Aku Mahasiswa Esa Unggul yang hebat kuat.',
                ),

                SizedBox(
                  height: 20,
                ),

                AppButton(
                  label: 'Kunjungi GitHub Saya',
                  icon: Icons.code,
                  url: 'https://github.com/Tortuga00s',
                  height: 40 + d.toDouble(),
                  borderRadius: 4 + d.toDouble(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
