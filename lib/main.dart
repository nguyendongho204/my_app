import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';
import 'man_hinh/trang_chu.dart';
import 'du_lieu/co_so_du_lieu.dart';

Future<void> _taoTaiKhoanTest() async {
  final existing = await CoSoDuLieu().dangNhap(sdt: '0900000001', matKhau: '123456');
  if (existing == null) {
    await CoSoDuLieu().dangKy(ten: 'Test User', sdt: '0900000001', email: 'test@bookbus.vn', matKhau: '123456');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _taoTaiKhoanTest();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (_) => const BookBusApp(),
    ),
  );
}

class BookBusApp extends StatelessWidget {
  const BookBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'BookBus Can Tho',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF42A5F5),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        barBackgroundColor: Color(0xFF0D1228),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF42A5F5),
          textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 15),
          navTitleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const TrangChu(),
    );
  }
}
