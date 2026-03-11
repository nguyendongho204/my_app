import 'package:flutter/material.dart';

class MauSac {
  // Mau nen chinh - toi nhu Shazam
  static const Color nenToi = Color(0xFF0A0E21);
  static const Color nenToi2 = Color(0xFF0D1B3E);

  // Mau xanh gradient chinh
  static const Color xanhChinh = Color(0xFF1565C0);
  static const Color xanhSang = Color(0xFF42A5F5);
  static const Color xanhNhat = Color(0xFF90CAF9);

  // Mau tim gradient
  static const Color timChinh = Color(0xFF6A1B9A);
  static const Color timNhat = Color(0xFFCE93D8);

  // Gradient chinh giong Shazam
  static const LinearGradient gradientChinh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF4A148C)],
  );

  static const LinearGradient gradientNen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E21), Color(0xFF0D1B3E), Color(0xFF1A0A2E)],
  );

  static const LinearGradient gradientVong = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1976D2), Color(0xFF7B1FA2)],
  );

  // Mau text
  static const Color textTrang = Color(0xFFFFFFFF);
  static const Color textXam = Color(0xFFB0BEC5);
  static const Color textXamNhat = Color(0xFF546E7A);

  // Mau accent
  static const Color cam = Color(0xFFFF6F00);
  static const Color xanh_la = Color(0xFF00C853);
  static const Color do_hong = Color(0xFFE91E63);

  // Mau card/surface
  static const Color cardNen = Color(0xFF1A2040);
  static const Color cardVien = Color(0xFF2A3560);
}
