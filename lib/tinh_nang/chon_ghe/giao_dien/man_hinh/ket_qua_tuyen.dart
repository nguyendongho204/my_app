import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';

import 'chon_ghe.dart';

class KetQuaTuyen extends StatefulWidget {
  final String diemDi;
  final String diemDen;
  final DateTime ngay;

  const KetQuaTuyen({
    super.key,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
  });

  @override
  State<KetQuaTuyen> createState() => _KetQuaTuyenState();
}

class _KetQuaTuyenState extends State<KetQuaTuyen> {
  int _loaiChon = 0;

  static const Map<String, int> _bangKhoangCach = {
    'BX Bình Thủy|BX Cái Răng': 10,
    'BX Bình Thủy|BX Cờ Đỏ': 35,
    'BX Bình Thủy|BX Ninh Kiều': 5,
    'BX Bình Thủy|BX Ô Môn': 12,
    'BX Bình Thủy|BX Phong Điền': 22,
    'BX Bình Thủy|BX Thới Lai': 25,
    'BX Bình Thủy|BX Thốt Nốt': 20,
    'BX Bình Thủy|BX Vĩnh Thạnh': 30,
    'BX Cái Răng|BX Cờ Đỏ': 35,
    'BX Cái Răng|BX Ninh Kiều': 8,
    'BX Cái Răng|BX Ô Môn': 20,
    'BX Cái Răng|BX Phong Điền': 20,
    'BX Cái Răng|BX Thới Lai': 25,
    'BX Cái Răng|BX Thốt Nốt': 30,
    'BX Cái Răng|BX Vĩnh Thạnh': 40,
    'BX Cờ Đỏ|BX Ninh Kiều': 28,
    'BX Cờ Đỏ|BX Ô Môn': 28,
    'BX Cờ Đỏ|BX Phong Điền': 30,
    'BX Cờ Đỏ|BX Thới Lai': 12,
    'BX Cờ Đỏ|BX Thốt Nốt': 35,
    'BX Cờ Đỏ|BX Vĩnh Thạnh': 40,
    'BX Ninh Kiều|BX Ô Môn': 15,
    'BX Ninh Kiều|BX Phong Điền': 18,
    'BX Ninh Kiều|BX Thới Lai': 20,
    'BX Ninh Kiều|BX Thốt Nốt': 22,
    'BX Ninh Kiều|BX Vĩnh Thạnh': 32,
    'BX Ô Môn|BX Phong Điền': 30,
    'BX Ô Môn|BX Thới Lai': 20,
    'BX Ô Môn|BX Thốt Nốt': 12,
    'BX Ô Môn|BX Vĩnh Thạnh': 22,
    'BX Phong Điền|BX Thới Lai': 20,
    'BX Phong Điền|BX Thốt Nốt': 38,
    'BX Phong Điền|BX Vĩnh Thạnh': 45,
    'BX Thới Lai|BX Thốt Nốt': 28,
    'BX Thới Lai|BX Vĩnh Thạnh': 35,
    'BX Thốt Nốt|BX Vĩnh Thạnh': 15,
  };

  int get _km {
    // Chuẩn hóa cặp điểm đi/đến để tra cứu bất kể chiều nhập của người dùng.
    final sorted = [widget.diemDi, widget.diemDen]..sort();
    return _bangKhoangCach['${sorted[0]}|${sorted[1]}'] ?? 15;
  }

  String _layMaTuyen(String a, String b) {
    const ma = {
      'BX Cái Răng': 'CR', 'BX Ninh Kiều': 'NK', 'BX Bình Thủy': 'BT',
      'BX Ô Môn': 'OM', 'BX Thốt Nốt': 'TN', 'BX Vĩnh Thạnh': 'VT',
      'BX Cờ Đỏ': 'CD', 'BX Thới Lai': 'TL', 'BX Phong Điền': 'PD',
    };
    final sorted = [a, b]..sort();
    return '${ma[sorted[0]] ?? 'XX'}-${ma[sorted[1]] ?? 'XX'}';
  }

  List<Map<String, dynamic>> get _danhSachChuyen {
    // Sinh dữ liệu chuyến động theo khoảng cách để mô phỏng thời lượng và giá vé.
    final km = _km;
    final gia = ((km * 1.1).round() * 1000).toString();
    final phut = (km * 2.5).round();
    const loai = '16 chỗ';
    final maTuyen = _layMaTuyen(widget.diemDi, widget.diemDen);
    final List<String> gioKhoiHanh = km <= 12
        ? ['06:30', '08:30', '10:30', '12:30', '14:30', '16:30', '18:30', '20:30', '22:30']
        : km <= 25
            ? ['06:30', '08:30', '10:30', '12:30', '14:30', '16:30', '18:30', '20:30', '22:30']
            : ['06:30', '08:30', '10:30', '12:30', '14:30', '16:30', '18:30', '20:30', '22:30'];
    const gheSoLuong = [16, 16, 16, 16, 16, 16, 16, 16, 16];

    final now = DateTime.now();
    final laHomNay = widget.ngay.year == now.year &&
        widget.ngay.month == now.month &&
        widget.ngay.day == now.day;

    return List.generate(gioKhoiHanh.length, (i) {
      final parts = gioKhoiHanh[i].split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final tongPhut = h * 60 + m + phut;
      final gioDen =
          '${(tongPhut ~/ 60).toString().padLeft(2, '0')}:${(tongPhut % 60).toString().padLeft(2, '0')}';

      // Chuyen da qua neu ngay hom nay va gio khoi hanh <= gio hien tai
      final daDatGio = laHomNay &&
          (h < now.hour || (h == now.hour && m <= now.minute));

      return {
        'gio': gioKhoiHanh[i],
        'den': gioDen,
        'tuyen': maTuyen,
        'gia': gia,
        'gheTrong': gheSoLuong[i % gheSoLuong.length],
        'loai': loai,
        'daDatGio': daDatGio,
      };
    });
  }

  List<Map<String, dynamic>> get _chuyenLoc {
    // Lọc danh sách theo khung giờ người dùng đang chọn (tất cả/sáng/chiều).
    final ds = _danhSachChuyen;
    if (_loaiChon == 1) {
      return ds.where((c) => int.parse((c['gio'] as String).split(':')[0]) < 12).toList();
    } else if (_loaiChon == 2) {
      return ds.where((c) => int.parse((c['gio'] as String).split(':')[0]) >= 12).toList();
    }
    return ds;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: mauXanhSang,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          '${widget.diemDi} -> ${widget.diemDen}',
          style: const TextStyle(color: mauTextTrang, fontSize: 15),
        ),
        trailing: Text(
          '${widget.ngay.day.toString().padLeft(2, "0")}/${widget.ngay.month.toString().padLeft(2, "0")}',
          style: const TextStyle(color: mauTextXam, fontSize: 13),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: Column(
          children: [
            // Bo loc
            Container(
              padding: const EdgeInsets.all(12),
              child: CupertinoSlidingSegmentedControl<int>(
                backgroundColor: mauCardNen,
                thumbColor: mauXanhChinh,
                groupValue: _loaiChon,
                onValueChanged: (v) {
                  if (v != null) setState(() => _loaiChon = v);
                },
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Tất cả',
                        style: TextStyle(color: mauTextTrang, fontSize: 13)),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Buổi sáng',
                        style: TextStyle(color: mauTextTrang, fontSize: 13)),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Buổi chiều',
                        style: TextStyle(color: mauTextTrang, fontSize: 13)),
                  ),
                },
              ),
            ),
            // Danh sach chuyen
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                physics: const BouncingScrollPhysics(),
                itemCount: _chuyenLoc.length,
                itemBuilder: (_, i) => _CardChuyenIOS(
                  chuyen: _chuyenLoc[i],
                  diemDi: widget.diemDi,
                  diemDen: widget.diemDen,
                  ngay: widget.ngay,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardChuyenIOS extends StatelessWidget {
  final Map<String, dynamic> chuyen;
  final String diemDi;
  final String diemDen;
  final DateTime ngay;

  const _CardChuyenIOS({
    required this.chuyen,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
  });

  @override
  Widget build(BuildContext context) {
    final daDatGio = (chuyen['daDatGio'] as bool? ?? false);
    final itGhe = (chuyen['gheTrong'] as int) <= 5;
    final gia = int.parse(chuyen['gia'] as String);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: daDatGio
          ? null
          : () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ChonGhe(
                    chuyen: chuyen,
                    diemDi: diemDi,
                    diemDen: diemDen,
                    ngay: ngay,
                  ),
                ),
              ),
      child: Opacity(
        opacity: daDatGio ? 0.45 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: daDatGio
                  ? mauCardVien
                  : itGhe
                      ? mauCam.withAlpha(128)
                      : mauCardVien,
            ),
          ),
        child: Row(
          children: [
            // Gio
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chuyen['gio'] as String,
                  style: const TextStyle(
                    color: mauTextTrang,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chuyen['den'] as String,
                  style: const TextStyle(color: mauTextXam, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Duong ke
            Expanded(
              child: Row(
                children: [
                  Container(width: 7, height: 7,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: mauXanhSang)),
                  Expanded(child: Container(height: 1, color: mauCardVien)),
                  const Icon(CupertinoIcons.bus, color: mauXanhSang, size: 16),
                  Expanded(child: Container(height: 1, color: mauCardVien)),
                  Container(width: 7, height: 7,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: mauDoHong)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Gia + thong tin
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _dinhDang(gia),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tuyến ${chuyen["tuyen"]}',
                  style: const TextStyle(color: mauTextXam, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(CupertinoIcons.rectangle_fill,
                      size: 12,
                      color: daDatGio ? mauTextXamNhat : itGhe ? mauCam : mauXanhLa,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      daDatGio
                          ? 'Đã khởi hành'
                          : itGhe
                              ? 'Còn ${chuyen["gheTrong"]} chỗ!'
                              : '${chuyen["gheTrong"]} chỗ trống',
                      style: TextStyle(
                        color: daDatGio
                            ? mauTextXamNhat
                            : itGhe
                                ? mauCam
                                : mauXanhLa,
                        fontSize: 11,
                        fontWeight: (!daDatGio && itGhe) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _dinhDang(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}d';
  }
}