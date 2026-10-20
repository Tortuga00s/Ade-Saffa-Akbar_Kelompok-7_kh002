import 'package:flutter/material.dart';
import 'profile_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String nim = '20240801071';
    final int digitTerakhir =
        int.parse(nim.substring(nim.length - 1));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: digitTerakhir.isOdd
            ? Colors.tealAccent[100]
            : Colors.amber[100],
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String nim = '20240801071';

    final int duaDigitTerakhir =
        int.parse(nim.substring(nim.length - 2));

    return Scaffold(
      body: Center(
        child: ProfileCard(
          nama: 'Ade Saffa Akbar',
          nim: nim,
          hobi: 'Programming',
          skorAktivitas: duaDigitTerakhir + 50,
        ),
      ),
    );
  }
}