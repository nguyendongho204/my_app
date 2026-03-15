import 'package:flutter/material.dart';
import 'mau_sac.dart';

class ChuDe {
  static ThemeData layTema() {
    // Theme Material dùng cho các thành phần còn phụ thuộc ThemeData trong app.
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MauSac.nenToi,
      colorScheme: const ColorScheme.dark(
        primary: MauSac.xanhChinh,
        secondary: MauSac.timChinh,
        surface: MauSac.cardNen,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MauSac.textTrang,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: MauSac.textTrang),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D1228),
        selectedItemColor: MauSac.xanhSang,
        unselectedItemColor: MauSac.textXam,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MauSac.xanhChinh,
          foregroundColor: MauSac.textTrang,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MauSac.cardNen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MauSac.cardVien),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MauSac.cardVien),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MauSac.xanhSang, width: 2),
        ),
        hintStyle: const TextStyle(color: MauSac.textXamNhat),
        labelStyle: const TextStyle(color: MauSac.textXam),
      ),
    );
  }
}
