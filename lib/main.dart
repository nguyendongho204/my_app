import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

Future<void> _taoTaiKhoanNhanVien() async {
  await CoSoDuLieu().taoNhanVien(
    ten: 'Nhân viên soát vé',
    maNV: 'nv01',
    matKhau: 'dongho123',
  );
}

Future<void> _taoTaiKhoanAdmin() async {
  await CoSoDuLieu().taoAdmin(
    ten: 'Quản trị viên',
    maTK: 'admin',
    matKhau: 'admin123',
  );
}

Future<void> _taoSeedData() async {
  final db = CoSoDuLieu();

  // --- Tuyến xe ---
  final tuyen = await db.layTatCaTuyen();
  if (tuyen.isEmpty) {
    final ds = [
      TuyenXe(diemDi: 'BX Ninh Kiều', diemDen: 'BX Cái Răng', khoangCach: 8, thoiGian: 25, giaVeCoSo: 20000, danhSachDiemDon: [], danhSachDiemTra: [], hoatDong: true),
      TuyenXe(diemDi: 'BX Ninh Kiều', diemDen: 'BX Ô Môn', khoangCach: 15, thoiGian: 40, giaVeCoSo: 30000, danhSachDiemDon: [], danhSachDiemTra: [], hoatDong: true),
      TuyenXe(diemDi: 'BX Ninh Kiều', diemDen: 'BX Thốt Nốt', khoangCach: 22, thoiGian: 55, giaVeCoSo: 40000, danhSachDiemDon: [], danhSachDiemTra: [], hoatDong: true),
      TuyenXe(diemDi: 'BX Cái Răng', diemDen: 'BX Phong Điền', khoangCach: 20, thoiGian: 50, giaVeCoSo: 35000, danhSachDiemDon: [], danhSachDiemTra: [], hoatDong: true),
      TuyenXe(diemDi: 'BX Bình Thủy', diemDen: 'BX Ô Môn', khoangCach: 12, thoiGian: 30, giaVeCoSo: 25000, danhSachDiemDon: [], danhSachDiemTra: [], hoatDong: true),
    ];
    for (final t in ds) {
      await db.taoTuyen(t);
    }
  }

  // --- Xe ---
  final xe = await db.layTatCaXe();
  if (xe.isEmpty) {
    final ds = [
      Xe(bienSo: '43A-123.45', loaiXe: 'Ghế thường', soGhe: 16, trangThai: 'san_sang'),
      Xe(bienSo: '43B-678.90', loaiXe: 'Ghế thường', soGhe: 16, trangThai: 'san_sang'),
      Xe(bienSo: '43C-112.23', loaiXe: 'Ghế thường', soGhe: 16, trangThai: 'san_sang'),
    ];
    for (final x in ds) {
      await db.taoXe(x);
    }
  }

  // --- Tài xế ---
  final taiXe = await db.layTatCaTaiXe();
  if (taiXe.isEmpty) {
    final ds = [
      TaiXe(ten: 'Nguyễn Văn Hùng', sdt: '0901234567', soGPLX: 'B2-123456', ngaySinh: '15/3/1985', trangThai: 'san_sang'),
      TaiXe(ten: 'Trần Thị Mai', sdt: '0912345678', soGPLX: 'B2-234567', ngaySinh: '22/7/1990', trangThai: 'san_sang'),
      TaiXe(ten: 'Lê Văn Bình', sdt: '0923456789', soGPLX: 'B2-345678', ngaySinh: '10/1/1988', trangThai: 'san_sang'),
    ];
    for (final tx in ds) {
      await db.taoTaiXe(tx);
    }
  }

  // --- Lịch chạy (hôm nay) ---
  final n = DateTime.now();
  final homNay = '${n.day}/${n.month}/${n.year}';
  final lichHomNay = await db.layLichChay(ngay: homNay);
  if (lichHomNay.isEmpty) {
    final tuyenList = await db.layTatCaTuyen();
    if (tuyenList.isNotEmpty) {
      final gioList = ['07:00', '09:30', '13:00', '15:30'];
      final loaiList = ['Ghế thường', 'Ghế thường', 'Ghế thường', 'Ghế thường'];
      final soGheList = [16, 16, 16, 16];
      for (int i = 0; i < tuyenList.length && i < 3; i++) {
        final t = tuyenList[i];
        for (int j = 0; j < gioList.length; j++) {
          await db.taoLichChay(LichChay(
            tuyenId: t.id!,
            diemDi: t.diemDi,
            diemDen: t.diemDen,
            ngay: homNay,
            gio: gioList[j],
            loaiXe: loaiList[j],
            soGheToiDa: soGheList[j],
            soGheConLai: soGheList[j],
            trangThai: 'cho',
          ));
        }
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _taoTaiKhoanTest();
  await _taoTaiKhoanNhanVien();
  await _taoTaiKhoanAdmin();
  await _taoSeedData();
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
    return CupertinoApp(
      title: 'BookBus Can Tho',
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF42A5F5),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        barBackgroundColor: Color(0xFF0D1228),
      ),
      home: const TrangChu(),
    );
  }
}
