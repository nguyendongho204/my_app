import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../cau_hinh/hang_so.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import '../../chon_ghe/giao_dien/man_hinh/ket_qua_tuyen.dart';

class DieuKienTimGiongNoi {
  final String diemDi;
  final String diemDen;
  final DateTime ngay;

  const DieuKienTimGiongNoi({
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
  });
}

class _ThongBaoGiongNoi {
  static const loiQuyenWeb =
      'Trình duyệt chưa cấp quyền micro. Hãy bấm cho phép microphone rồi thử lại.';
  static const loiKhongHoTroNenTang =
      'Thiết bị chưa hỗ trợ hoặc chưa cấp quyền micro.';
  static const loiKiemTraMicro = 'Vui lòng kiểm tra quyền micro và thử lại.';

  static const tieuDeKhongTheBatGhiAm = 'Không thể bắt đầu ghi âm';
  static const tieuDeKhongTheDungGiongNoi = 'Không thể dùng giọng nói';
  static const tieuDeChuaDuThongTin = 'Chưa nhận đủ thông tin';

  static const huongDanCauLenh =
      'Hãy nói theo mẫu: "từ ô môn đến cái răng ngày mai" hoặc "... ngày 20/03".';

  static const nutOk = 'OK';
  static const nutDaHieu = 'Đã hiểu';

  static const nhanDangNghe = 'ĐANG NGHE';
  static const nhanGiongNoi = 'GIỌNG NÓI';
  static const moTaNhanLaiDeDung = 'nhấn lại để dùng giọng nói';
  static const moTaNhanDeTimBangGiongNoi =
      'Nhấn để tìm chuyến bằng giọng nói';
}

class TimTuyenGiongNoiService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _hoTroGiongNoi = false;
  bool _dangNgheGiongNoi = false;
  bool _daXuLyBanGhi = false;
  String _banGhiGiongNoi = '';

  bool get hoTroGiongNoi => _hoTroGiongNoi;
  bool get dangNgheGiongNoi => _dangNgheGiongNoi;
  String get banGhiGiongNoi => _banGhiGiongNoi;

  static const Map<String, List<String>> _tuKhoaBenXe = {
    'BX Cái Răng': ['bx cai rang', 'cai rang'],
    'BX Ninh Kiều': ['bx ninh kieu', 'ninh kieu'],
    'BX Bình Thủy': ['bx binh thuy', 'binh thuy'],
    'BX Ô Môn': ['bx o mon', 'o mon', 'omon'],
    'BX Thốt Nốt': ['bx thot not', 'thot not'],
    'BX Vĩnh Thạnh': ['bx vinh thanh', 'vinh thanh'],
    'BX Cờ Đỏ': ['bx co do', 'co do'],
    'BX Thới Lai': ['bx thoi lai', 'thoi lai'],
    'BX Phong Điền': ['bx phong dien', 'phong dien'],
  };

  bool hoTroNenTang() {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> khoiTao({
    required VoidCallback onCapNhat,
    required void Function(String) onBanGhiCuoi,
  }) async {
    if (!hoTroNenTang()) {
      _hoTroGiongNoi = false;
      onCapNhat();
      return;
    }

    try {
      final ok = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _dangNgheGiongNoi = false;
            onCapNhat();
            if (_banGhiGiongNoi.trim().isNotEmpty && !_daXuLyBanGhi) {
              _daXuLyBanGhi = true;
              onBanGhiCuoi(_banGhiGiongNoi);
            }
          }
        },
        onError: (_) {
          _dangNgheGiongNoi = false;
          onCapNhat();
        },
      );
      _hoTroGiongNoi = ok;
      onCapNhat();
    } catch (_) {
      _hoTroGiongNoi = false;
      _dangNgheGiongNoi = false;
      onCapNhat();
    }
  }

  Future<String?> batTatNghe({
    required VoidCallback onCapNhat,
    required void Function(String) onBanGhiCuoi,
  }) async {
    if (!_hoTroGiongNoi) {
      await khoiTao(onCapNhat: onCapNhat, onBanGhiCuoi: onBanGhiCuoi);
    }

    if (!_hoTroGiongNoi) {
      return kIsWeb
          ? _ThongBaoGiongNoi.loiQuyenWeb
          : _ThongBaoGiongNoi.loiKhongHoTroNenTang;
    }

    if (_dangNgheGiongNoi) {
      await _speech.stop();
      _dangNgheGiongNoi = false;
      onCapNhat();
      return null;
    }

    _daXuLyBanGhi = false;
    _banGhiGiongNoi = '';
    _dangNgheGiongNoi = true;
    onCapNhat();

    try {
      await _speech.listen(
        localeId: 'vi_VN',
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.search,
        ),
        onResult: (r) {
          _banGhiGiongNoi = r.recognizedWords;
          onCapNhat();
          if (r.finalResult && !_daXuLyBanGhi) {
            _daXuLyBanGhi = true;
            _speech.stop();
            onBanGhiCuoi(r.recognizedWords);
          }
        },
      );
      return null;
    } catch (_) {
      _dangNgheGiongNoi = false;
      onCapNhat();
      return _ThongBaoGiongNoi.loiKiemTraMicro;
    }
  }

  Future<void> dong() async {
    await _speech.stop();
    await _speech.cancel();
  }

  DieuKienTimGiongNoi? phanTichLenh(String cauNoi) {
    final khongDau = _boDauTiengViet(cauNoi);
    final ketQuaBenXe = _timBenXeTuCauNoi(khongDau);

    final diem = <String>[];
    for (final item in ketQuaBenXe) {
      final ben = item['ben'] as String;
      if (!diem.contains(ben)) diem.add(ben);
      if (diem.length == 2) break;
    }
    if (diem.length < 2) return null;
    if (diem[0] == diem[1]) return null;

    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final maxDate = homNay.add(const Duration(days: 30));
    final ngay = _tachNgayTuCauNoi(khongDau) ?? homNay;

    if (ngay.isBefore(homNay) || ngay.isAfter(maxDate)) return null;

    return DieuKienTimGiongNoi(
      diemDi: diem[0],
      diemDen: diem[1],
      ngay: ngay,
    );
  }

  DateTime? _tachNgayTuCauNoi(String cauNoiKhongDau) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (cauNoiKhongDau.contains('hom nay')) return today;
    if (cauNoiKhongDau.contains('ngay mai')) {
      return today.add(const Duration(days: 1));
    }
    if (cauNoiKhongDau.contains('ngay kia') ||
        cauNoiKhongDau.contains('mai mot')) {
      return today.add(const Duration(days: 2));
    }

    final rgx1 = RegExp(r'(\d{1,2})\s*[\/-]\s*(\d{1,2})(?:\s*[\/-]\s*(\d{2,4}))?');
    final m1 = rgx1.firstMatch(cauNoiKhongDau);
    if (m1 != null) {
      final d = int.tryParse(m1.group(1) ?? '');
      final m = int.tryParse(m1.group(2) ?? '');
      var y = int.tryParse(m1.group(3) ?? '') ?? now.year;
      if (y < 100) y += 2000;
      if (d != null && m != null) {
        final dt = DateTime(y, m, d);
        if (dt.year == y && dt.month == m && dt.day == d) return dt;
      }
    }

    final rgx2 = RegExp(r'ngay\s*(\d{1,2})\s*thang\s*(\d{1,2})(?:\s*nam\s*(\d{2,4}))?');
    final m2 = rgx2.firstMatch(cauNoiKhongDau);
    if (m2 != null) {
      final d = int.tryParse(m2.group(1) ?? '');
      final m = int.tryParse(m2.group(2) ?? '');
      var y = int.tryParse(m2.group(3) ?? '') ?? now.year;
      if (y < 100) y += 2000;
      if (d != null && m != null) {
        final dt = DateTime(y, m, d);
        if (dt.year == y && dt.month == m && dt.day == d) return dt;
      }
    }

    final rgx3 = RegExp(r'(\d{1,2})\s*thang\s*(\d{1,2})(?:\s*nam\s*(\d{2,4}))?');
    final m3 = rgx3.firstMatch(cauNoiKhongDau);
    if (m3 != null) {
      final d = int.tryParse(m3.group(1) ?? '');
      final m = int.tryParse(m3.group(2) ?? '');
      var y = int.tryParse(m3.group(3) ?? '') ?? now.year;
      if (y < 100) y += 2000;
      if (d != null && m != null) {
        final dt = DateTime(y, m, d);
        if (dt.year == y && dt.month == m && dt.day == d) return dt;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _timBenXeTuCauNoi(String cauNoiKhongDau) {
    final ketQua = <Map<String, dynamic>>[];
    for (final entry in _tuKhoaBenXe.entries) {
      int? viTriSomNhat;
      for (final tuKhoa in entry.value) {
        final idx = cauNoiKhongDau.indexOf(_boDauTiengViet(tuKhoa));
        if (idx >= 0 && (viTriSomNhat == null || idx < viTriSomNhat)) {
          viTriSomNhat = idx;
        }
      }
      if (viTriSomNhat != null) {
        ketQua.add({'ben': entry.key, 'idx': viTriSomNhat});
      }
    }
    ketQua.sort((a, b) => (a['idx'] as int).compareTo(b['idx'] as int));
    return ketQua;
  }

  String _boDauTiengViet(String input) {
    final s = input.toLowerCase();
    const map = {
      'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
      'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
      'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
      'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
      'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
      'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
      'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
      'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
      'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
      'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
      'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
      'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
      'đ': 'd',
    };
    final sb = StringBuffer();
    for (final ch in s.split('')) {
      sb.write(map[ch] ?? ch);
    }
    return sb.toString();
  }
}

class TimTuyenGiongNoiDieuPhoi {
  final TimTuyenGiongNoiService _service;

  TimTuyenGiongNoiDieuPhoi({TimTuyenGiongNoiService? service})
      : _service = service ?? TimTuyenGiongNoiService();

  bool get dangNgheGiongNoi => _service.dangNgheGiongNoi;
  String get banGhiGiongNoi => _service.banGhiGiongNoi;

  Future<void> khoiTao({
    required BuildContext context,
    required VoidCallback onCapNhat,
  }) async {
    await _service.khoiTao(
      onCapNhat: onCapNhat,
      onBanGhiCuoi: (vanBan) => _xuLyBanGhi(context, vanBan),
    );
  }

  Future<void> batTatNghe({
    required BuildContext context,
    required VoidCallback onCapNhat,
  }) async {
    final loi = await _service.batTatNghe(
      onCapNhat: onCapNhat,
      onBanGhiCuoi: (vanBan) => _xuLyBanGhi(context, vanBan),
    );

    if (loi == null || !context.mounted) return;
    final tieuDe = loi == _ThongBaoGiongNoi.loiKiemTraMicro
        ? _ThongBaoGiongNoi.tieuDeKhongTheBatGhiAm
        : _ThongBaoGiongNoi.tieuDeKhongTheDungGiongNoi;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(tieuDe),
        content: Text(loi),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text(_ThongBaoGiongNoi.nutOk),
          ),
        ],
      ),
    );
  }

  void _xuLyBanGhi(BuildContext context, String cauNoi) {
    if (!context.mounted) return;
    final dk = _service.phanTichLenh(cauNoi);
    if (dk == null) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text(_ThongBaoGiongNoi.tieuDeChuaDuThongTin),
          content: const Text(_ThongBaoGiongNoi.huongDanCauLenh),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: const Text(_ThongBaoGiongNoi.nutDaHieu),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => KetQuaTuyen(
          diemDi: dk.diemDi,
          diemDen: dk.diemDen,
          ngay: dk.ngay,
        ),
      ),
    );
  }

  Future<void> dong() => _service.dong();
}

class NutGiongNoiTron extends StatelessWidget {
  final bool dangNghe;
  final String vanBanDaNghe;
  final VoidCallback onNhanMic;

  const NutGiongNoiTron({
    super.key,
    required this.dangNghe,
    required this.vanBanDaNghe,
    required this.onNhanMic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onNhanMic,
            child: VongTronPulse(
              kichThuoc: 130,
              mauGradient: dangNghe
                  ? const [Color(0xFF0D47A1), Color(0xFFE91E63)]
                  : const [Color(0xFF1565C0), Color(0xFF6A1B9A)],
              noiDungTrungTam: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    dangNghe ? CupertinoIcons.waveform : CupertinoIcons.mic_fill,
                    color: CupertinoColors.white,
                    size: 38,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dangNghe
                        ? _ThongBaoGiongNoi.nhanDangNghe
                        : _ThongBaoGiongNoi.nhanGiongNoi,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            dangNghe
                ? _ThongBaoGiongNoi.moTaNhanLaiDeDung
                : _ThongBaoGiongNoi.moTaNhanDeTimBangGiongNoi,
            style: TextStyle(
              color: dangNghe ? mauXanhSang : mauTextXam,
              fontSize: 13,
            ),
          ),
          if (vanBanDaNghe.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                vanBanDaNghe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: mauTextXamNhat, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
