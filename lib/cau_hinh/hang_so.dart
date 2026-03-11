import 'package:flutter/cupertino.dart';

// Mau sac toan app
const Color mauNenToi = Color(0xFF0A0E21);
const Color mauNenToi2 = Color(0xFF0D1B3E);
const Color mauNenTim = Color(0xFF1A0A2E);
const Color mauXanhChinh = Color(0xFF1565C0);
const Color mauXanhSang = Color(0xFF42A5F5);
const Color mauTimChinh = Color(0xFF6A1B9A);
const Color mauCardNen = Color(0xFF1A2040);
const Color mauCardVien = Color(0xFF2A3560);
const Color mauTextTrang = Color(0xFFFFFFFF);
const Color mauTextXam = Color(0xFFB0BEC5);
const Color mauTextXamNhat = Color(0xFF546E7A);
const Color mauCam = Color(0xFFFF6F00);
const Color mauXanhLa = Color(0xFF00C853);
const Color mauDoHong = Color(0xFFE91E63);
const Color mauThanhDieuHuong = Color(0xFF0D1228);

// Gradient
const LinearGradient gradientChinh = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0D47A1), Color(0xFF4A148C)],
);

const LinearGradient gradientNen = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0A0E21), Color(0xFF0D1B3E), Color(0xFF1A0A2E)],
);

const LinearGradient gradientVong = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1976D2), Color(0xFF7B1FA2)],
);

/// Bộ điều khiển tab toàn cục để chuyển tab từ bất kỳ màn hình nào
class DieuHuongTab {
  static CupertinoTabController? controller;
}

/// Địa chỉ cụ thể của các bến xe tại Cần Thơ
const Map<String, String> diaChiBenXe = {
  'BX Bình Thủy': '49 Lê Hồng Phong, P. Bình Thủy, Q. Bình Thủy',
  'BX Cái Răng': '36 Nguyễn Văn Cừ, P. Ba Láng, Q. Cái Răng',
  'BX Cờ Đỏ': 'QL 922, TT Cờ Đỏ, H. Cờ Đỏ',
  'BX Ninh Kiều': '01 Hùng Vương, P. Tân An, Q. Ninh Kiều',
  'BX Ô Môn': 'QL 91, P. Châu Văn Liêm, Q. Ô Môn',
  'BX Phong Điền': 'QL 1A, TT Phong Điền, H. Phong Điền',
  'BX Thới Lai': 'QL 61C, TT Thới Lai, H. Thới Lai',
  'BX Thốt Nốt': 'QL 91, P. Thốt Nốt, Q. Thốt Nốt',
  'BX Vĩnh Thạnh': 'QL 80, TT Vĩnh Thạnh, H. Vĩnh Thạnh',
};
