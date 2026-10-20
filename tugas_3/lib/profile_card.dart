import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String hobi;
  final int skorAktivitas;

  ProfileCard({
    required this.nama,
    required this.nim,
    required this.hobi,
    required this.skorAktivitas,
  });

  @override
  Widget build(BuildContext context) {
    final int digitTerakhir =
        int.parse(nim.substring(nim.length - 1));

    final int digitKeduaDariBelakang =
        int.parse(nim.substring(nim.length - 2, nim.length - 1));

    final double lebarKartu =
        320.0 + (digitKeduaDariBelakang * 5);

    final double radiusKartu =
        12.0 + (digitTerakhir * 1.5);

    final double ukuranLogo =
        60.0 + (digitTerakhir * 2);

    final double jarakHeader =
        15.0 + digitTerakhir;

    return Container(
      width: lebarKartu,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radiusKartu),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: FlutterLogo(
                  size: ukuranLogo,
                ),
              ),

              SizedBox(
                width: jarakHeader,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kartu Praktikan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    nama,
                  ),
                ],
              ),
            ],
          ),

          Divider(
            thickness: 1.5,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NIM: $nim",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "Hobi: $hobi",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "Skor Aktivitas: $skorAktivitas",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}