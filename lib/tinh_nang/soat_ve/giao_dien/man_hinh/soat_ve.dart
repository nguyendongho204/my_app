import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';

// ─── Model lịch sử soát vé ─────────────────────────────────────────

class _LichSuSoat {
  final Ve ve;
  final DateTime thoiGian;
  final String ghiChu;

  _LichSuSoat({required this.ve, required this.thoiGian, this.ghiChu = ''});
}

// ──────────────────────────────────────────────────────────────────

class SoatVe extends StatefulWidget {
  final NhanVien nhanVien;

  const SoatVe({super.key, required this.nhanVien});

  @override
  State<SoatVe> createState() => _SoatVeState();
}

class _SoatVeState extends State<SoatVe> {
  bool _dangQuet = false;
  bool _dangXuLy = false;
  List<_LichSuSoat> _lichSu = [];
  Map<String, String>? _chuyenChon;

  static const _danhSachDiem = [
    'BX Cái Răng', 'BX Ninh Kiều', 'BX Bình Thủy', 'BX Ô Môn',
    'BX Thốt Nốt', 'BX Vĩnh Thạnh', 'BX Cờ Đỏ', 'BX Thới Lai', 'BX Phong Điền',
  ];

  static const _danhSachGio = [
    '06:00', '06:30', '06:45', '07:15', '07:30', '08:00', '08:30',
    '10:00', '10:30', '12:00', '12:30', '14:00', '14:30', '16:00', '16:30', '17:30',
  ];

  @override
  void initState() {
    super.initState();
    _muaLichSu();
  }

  Future<void> _muaLichSu() async {
    try {
      final data = await CoSoDuLieu().layLichSuSoat(widget.nhanVien.maNV);
      if (!mounted) return;
      setState(() {
        // Chuyển dữ liệu thô từ DB về model nội bộ để hiển thị lịch sử soát.
        _lichSu = data.map((item) {
          final ve = Ve(
            maVe: item['maVe'] as String? ?? '',
            diemDi: item['diemDi'] as String? ?? '',
            diemDen: item['diemDen'] as String? ?? '',
            gio: item['gio'] as String? ?? '',
            ngay: item['ngay'] as String? ?? '',
            danhSachGhe: item['danhSachGhe'] as String? ?? '',
            tongTien: 0,
            trangThai: 'hoan_thanh',
            loaiXe: item['loaiXe'] as String? ?? '',
            ngayDat: '',
            nguoiDungId: '',
          );
          final tStr = item['thoiGian'] as String? ?? '';
          final t = tStr.isNotEmpty
              ? (DateTime.tryParse(tStr) ?? DateTime.now())
              : DateTime.now();
          return _LichSuSoat(
              ve: ve, thoiGian: t, ghiChu: item['ghiChu'] as String? ?? '');
        }).toList();
      });
    } catch (_) {}
  }

  void _batDauQuet() {
    if (_chuyenChon == null) {
      _chonChuyen();
      return;
    }
    setState(() => _dangQuet = true);
  }

  void _dungQuet() => setState(() => _dangQuet = false);

  Future<void> _xuLyQR(String maVe) async {
    if (_dangXuLy) return;
    setState(() {
      _dangXuLy = true;
      _dangQuet = false;
    });
    final ve = await CoSoDuLieu().timVeTheoMaVe(maVe);
    if (!mounted) return;
    setState(() => _dangXuLy = false);

    if (ve == null) {
      _hienThiKetQua(hopLe: false, thongBao: 'Không tìm thấy vé "$maVe"');
      return;
    }
    if (ve.trangThai == 'huy') {
      _hienThiKetQua(hopLe: false, ve: ve, thongBao: 'Vé này đã bị hủy');
      return;
    }
    if (ve.trangThai == 'bo_lo') {
      _hienThiKetQua(hopLe: false, ve: ve, thongBao: 'Vé này đã bỏ lỡ chuyến');
      return;
    }
    if (ve.trangThai == 'hoan_thanh') {
      _hienThiKetQua(hopLe: false, ve: ve, thongBao: 'Vé này đã được sử dụng rồi');
      return;
    }
    // Kiểm tra vé có thuộc chuyến làm việc hiện tại của nhân viên hay không.
    if (_chuyenChon != null) {
      if (ve.diemDi != _chuyenChon!['diemDi'] ||
          ve.diemDen != _chuyenChon!['diemDen'] ||
          ve.ngay != _chuyenChon!['ngay'] ||
          ve.gio != _chuyenChon!['gio']) {
        _hienThiKetQua(
          hopLe: false,
          ve: ve,
          thongBao:
              'Vé không thuộc chuyến này!\nTuyến vé: ${ve.diemDi} → ${ve.diemDen}\n${ve.ngay}  ${ve.gio}',
        );
        return;
      }
    }
    // Vé hợp lệ và đúng chuyến: mở hộp xác nhận để hoàn tất soát vé.
    _hienThiXacNhan(ve);
  }

  Future<void> _chonChuyen() async {
    final now = DateTime.now();
    int idxDi = 0, idxDen = 1, idxGio = 0, idxNgay = 1;
    if (_chuyenChon != null) {
      final d1 = _danhSachDiem.indexOf(_chuyenChon!['diemDi']!);
      final d2 = _danhSachDiem.indexOf(_chuyenChon!['diemDen']!);
      final g = _danhSachGio.indexOf(_chuyenChon!['gio']!);
      if (d1 >= 0) idxDi = d1;
      if (d2 >= 0) idxDen = d2;
      if (g >= 0) idxGio = g;
    }
    final dNgay = [
      DateTime(now.year, now.month, now.day - 1),
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day + 1),
    ];
    final diCtrl = FixedExtentScrollController(initialItem: idxDi);
    final denCtrl = FixedExtentScrollController(initialItem: idxDen);
    final ngayCtrl = FixedExtentScrollController(initialItem: idxNgay);
    final gioCtrl = FixedExtentScrollController(initialItem: idxGio);

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: mauNenToi,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  decoration: const BoxDecoration(
                    color: mauCardNen,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.bus,
                          color: mauXanhSang, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Chọn chuyến làm việc',
                            style: TextStyle(
                                color: mauTextTrang,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text('Hủy',
                            style: TextStyle(color: mauTextXam)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 2),
                          child: Text('Điểm đi',
                              style: TextStyle(
                                  color: mauTextXam,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 95,
                          child: CupertinoPicker(
                            scrollController: diCtrl,
                            itemExtent: 36,
                            backgroundColor: mauNenToi,
                            onSelectedItemChanged: (i) =>
                                setModal(() => idxDi = i),
                            children: _danhSachDiem
                                .map((d) => Center(
                                    child: Text(d,
                                        style: const TextStyle(
                                            color: mauTextTrang,
                                            fontSize: 15))))
                                .toList(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 2),
                          child: Text('Điểm đến',
                              style: TextStyle(
                                  color: mauTextXam,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 95,
                          child: CupertinoPicker(
                            scrollController: denCtrl,
                            itemExtent: 36,
                            backgroundColor: mauNenToi,
                            onSelectedItemChanged: (i) =>
                                setModal(() => idxDen = i),
                            children: _danhSachDiem
                                .map((d) => Center(
                                    child: Text(d,
                                        style: const TextStyle(
                                            color: mauTextTrang,
                                            fontSize: 15))))
                                .toList(),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 2),
                                    child: Text('Ngày',
                                        style: TextStyle(
                                            color: mauTextXam,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(
                                    height: 95,
                                    child: CupertinoPicker(
                                      scrollController: ngayCtrl,
                                      itemExtent: 36,
                                      backgroundColor: mauNenToi,
                                      onSelectedItemChanged: (i) =>
                                          setModal(() => idxNgay = i),
                                      children: dNgay
                                          .map((d) => Center(
                                              child: Text(
                                                  '${d.day}/${d.month}/${d.year}',
                                                  style: const TextStyle(
                                                      color: mauTextTrang,
                                                      fontSize: 15))))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 2),
                                    child: Text('Giờ khởi hành',
                                        style: TextStyle(
                                            color: mauTextXam,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(
                                    height: 95,
                                    child: CupertinoPicker(
                                      scrollController: gioCtrl,
                                      itemExtent: 36,
                                      backgroundColor: mauNenToi,
                                      onSelectedItemChanged: (i) =>
                                          setModal(() => idxGio = i),
                                      children: _danhSachGio
                                          .map((g) => Center(
                                              child: Text(g,
                                                  style: const TextStyle(
                                                      color: mauTextTrang,
                                                      fontSize: 15))))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: NutGradient(
                    nhanDe: 'Xác nhận chuyến này',
                    bieuTuong: CupertinoIcons.checkmark_circle_fill,
                    chieuRong: double.infinity,
                    onNhan: () {
                      // Lưu thông tin chuyến được chọn để khóa ngữ cảnh soát trong ca làm.
                      final ngay = dNgay[idxNgay];
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        _chuyenChon = {
                          'diemDi': _danhSachDiem[idxDi],
                          'diemDen': _danhSachDiem[idxDen],
                          'ngay': '${ngay.day}/${ngay.month}/${ngay.year}',
                          'gio': _danhSachGio[idxGio],
                        };
                        _dangQuet = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    diCtrl.dispose();
    denCtrl.dispose();
    ngayCtrl.dispose();
    gioCtrl.dispose();
  }

  Future<void> _nhapThuCong() async {
    final ctrl = TextEditingController();
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: mauCardNen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: mauCardVien,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Row(
                children: [
                  Icon(CupertinoIcons.keyboard, color: mauXanhSang, size: 20),
                  SizedBox(width: 8),
                  Text('Nhập mã vé thủ công',
                      style: TextStyle(
                          color: mauTextTrang,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Dùng khi mã QR bị hỏng hoặc không đọc được',
                style: TextStyle(color: mauTextXam, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: ctrl,
                autofocus: true,
                placeholder: 'VD: VE-20250615-ABCD1234',
                placeholderStyle:
                    const TextStyle(color: mauTextXam, fontSize: 14),
                style: const TextStyle(
                    color: mauXanhSang,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: mauNenToi,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mauXanhChinh.withAlpha(150)),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: mauDoHong.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mauDoHong.withAlpha(100)),
                        ),
                        child: const Text('Hủy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: mauDoHong,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final ma = ctrl.text.trim();
                        if (ma.isEmpty) return;
                        Navigator.of(context, rootNavigator: true).pop();
                        _xuLyQR(ma);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: gradientChinh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Soát vé',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    ctrl.dispose();
  }

  void _hienThiKetQua({required bool hopLe, Ve? ve, required String thongBao}) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hopLe
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.xmark_circle_fill,
              color: hopLe ? const Color(0xFF00C853) : mauDoHong,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              hopLe ? 'Vé hợp lệ' : 'Vé không hợp lệ',
              style: TextStyle(color: hopLe ? const Color(0xFF00C853) : mauDoHong),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(thongBao),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() => _dangQuet = true);
            },
            child: const Text('Quét tiếp'),
          ),
        ],
      ),
    );
  }

  void _hienThiXacNhan(Ve ve) {
    final ghiChuCtrl = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: mauCardVien,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.checkmark_seal_fill,
                          color: Color(0xFF00C853), size: 24),
                      SizedBox(width: 8),
                      Text('Vé hợp lệ',
                          style: TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mauNenToi,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF00C853).withAlpha(80)),
                    ),
                    child: Column(
                      children: [
                        _DongThongTin(
                            nhan: 'Mã vé', gia: ve.maVe, laMauXanh: true),
                        const SizedBox(height: 8),
                        Container(height: 0.5, color: mauCardVien),
                        const SizedBox(height: 8),
                        _DongThongTin(
                            nhan: 'Tuyến',
                            gia: '${ve.diemDi} → ${ve.diemDen}'),
                        const SizedBox(height: 6),
                        _DongThongTin(
                            nhan: 'Ngày - Giờ',
                            gia: '${ve.ngay}  ${ve.gio}'),
                        const SizedBox(height: 6),
                        _DongThongTin(
                            nhan: 'Ghế số',
                            gia: (ve.danhSachGheParsed..sort()).join(', ')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Ô ghi chú
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(CupertinoIcons.pencil,
                              color: Color(0xFFFF9800), size: 15),
                          SizedBox(width: 6),
                          Text('Ghi chú (tuỳ chọn)',
                              style:
                                  TextStyle(color: mauTextXam, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: ghiChuCtrl,
                        placeholder: 'VD: Hành lý quá khổ, vé giấy rách...',
                        placeholderStyle:
                            const TextStyle(color: mauTextXam, fontSize: 13),
                        style: const TextStyle(
                            color: mauTextTrang, fontSize: 14),
                        padding: const EdgeInsets.all(12),
                        maxLines: 2,
                        decoration: BoxDecoration(
                          color: mauNenToi,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFF9800).withAlpha(120)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ghiChuCtrl.dispose();
                            Navigator.of(context, rootNavigator: true).pop();
                            setState(() => _dangQuet = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: mauDoHong.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: mauDoHong.withAlpha(100)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.xmark,
                                    color: mauDoHong, size: 18),
                                SizedBox(width: 6),
                                Text('Bỏ qua',
                                    style: TextStyle(
                                        color: mauDoHong,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final ghiChu = ghiChuCtrl.text.trim();
                            ghiChuCtrl.dispose();
                            Navigator.of(context, rootNavigator: true).pop();
                            await CoSoDuLieu().lenXe(ve.id!);
                            await CoSoDuLieu()
                                .luuLichSuSoat(widget.nhanVien.maNV, ve, ghiChu);
                            if (!mounted) return;
                            setState(() {
                              _lichSu.insert(
                                0,
                                _LichSuSoat(
                                  ve: ve,
                                  thoiGian: DateTime.now(),
                                  ghiChu: ghiChu,
                                ),
                              );
                              _dangQuet = true;
                            });
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text('✓ Đã xác nhận'),
                                content: Text(
                                    'Vé ${ve.maVe} đã được xác nhận lên xe.'),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00C853),
                                  Color(0xFF1B5E20),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.checkmark_circle_fill,
                                    color: CupertinoColors.white, size: 18),
                                SizedBox(width: 6),
                                Text('Xác nhận lên xe',
                                    style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _xemLichSu() {
    String tuyenNhieu = '—';
    if (_lichSu.isNotEmpty) {
      final Map<String, int> dem = {};
      for (final ls in _lichSu) {
        final tuyen = '${ls.ve.diemDi} → ${ls.ve.diemDen}';
        dem[tuyen] = (dem[tuyen] ?? 0) + 1;
      }
      tuyenNhieu =
          dem.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: mauNenToi,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: mauCardNen,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.clock_fill,
                      color: mauXanhSang, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Lịch sử soát vé',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text('Đóng',
                        style: TextStyle(color: mauXanhSang)),
                  ),
                ],
              ),
            ),
            // Thống kê ca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _CardThongKeCa(
                      soLieu: '${_lichSu.length}',
                      nhan: 'Vé đã soát',
                      mau: mauXanhSang,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _CardThongKeCa(
                      soLieu: '',
                      nhan: tuyenNhieu,
                      mau: const Color(0xFFFF9800),
                      tieuDe: 'Tuyến nhiều nhất',
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách lịch sử
            Expanded(
              child: _lichSu.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.doc_plaintext,
                              color: mauTextXam, size: 48),
                          SizedBox(height: 12),
                          Text('Chưa soát vé nào trong ca này',
                              style: TextStyle(color: mauTextXam)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _lichSu.length,
                      itemBuilder: (_, i) {
                        final ls = _lichSu[i];
                        final t = ls.thoiGian;
                        final tg =
                            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF00C853).withAlpha(60)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      color: Color(0xFF00C853),
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(ls.ve.maVe,
                                        style: const TextStyle(
                                            color: mauXanhSang,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                  Text(tg,
                                      style: const TextStyle(
                                          color: mauTextXam, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ls.ve.diemDi} → ${ls.ve.diemDen}  •  ${ls.ve.ngay}  ${ls.ve.gio}',
                                style: const TextStyle(
                                    color: mauTextTrang, fontSize: 13),
                              ),
                              Text(
                                'Ghế: ${(ls.ve.danhSachGheParsed..sort()).join(', ')}',
                                style: const TextStyle(
                                    color: mauTextXam, fontSize: 12),
                              ),
                              if (ls.ghiChu.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.pencil,
                                        color: Color(0xFFFF9800), size: 13),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(ls.ghiChu,
                                          style: const TextStyle(
                                              color: Color(0xFFFF9800),
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Soát vé', style: TextStyle(color: mauTextTrang)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon lịch sử có badge
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _xemLichSu,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(CupertinoIcons.clock, color: mauXanhSang),
                  if (_lichSu.isNotEmpty)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: mauDoHong, shape: BoxShape.circle),
                        child: Text(
                          '${_lichSu.length}',
                          style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Nút thoát
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Thoát khỏi chế độ nhân viên?'),
                    actions: [
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Đăng xuất'),
                      ),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text('Hủy'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Thoát',
                  style: TextStyle(color: mauDoHong, fontSize: 15)),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: Column(
            children: [
              // Thông tin nhân viên
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.person_fill,
                            color: CupertinoColors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.nhanVien.ten,
                                style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text('Mã NV: ${widget.nhanVien.maNV}',
                                style: const TextStyle(
                                    color: Color(0xB3FFFFFF), fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00C853)),
                            ),
                            child: const Text('Đang làm việc',
                                style: TextStyle(
                                    color: Color(0xFF00C853),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Đã soát: ${_lichSu.length} vé',
                            style: const TextStyle(
                                color: Color(0xB3FFFFFF), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Chuyến đang làm việc
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: GestureDetector(
                  onTap: _chonChuyen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _chuyenChon == null
                          ? mauDoHong.withAlpha(25)
                          : const Color(0xFF00C853).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _chuyenChon == null
                              ? mauDoHong.withAlpha(100)
                              : const Color(0xFF00C853).withAlpha(80)),
                    ),
                    child: _chuyenChon == null
                        ? const Row(
                            children: [
                              Icon(
                                  CupertinoIcons
                                      .exclamationmark_triangle_fill,
                                  color: mauDoHong,
                                  size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    'Nhấn để chọn chuyến làm việc',
                                    style: TextStyle(
                                        color: mauDoHong, fontSize: 13)),
                              ),
                              Text('Chọn →',
                                  style: TextStyle(
                                      color: mauDoHong,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(CupertinoIcons.bus,
                                  color: Color(0xFF00C853), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_chuyenChon!['diemDi']} → ${_chuyenChon!['diemDen']}  •  ${_chuyenChon!['ngay']}  ${_chuyenChon!['gio']}',
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 12),
                                ),
                              ),
                              const Text('Đổi',
                                  style: TextStyle(
                                      color: mauXanhSang, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
              ),
              // Nút hành động nhanh
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _nhapThuCong,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: mauXanhChinh.withAlpha(100)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.keyboard,
                                  color: mauXanhSang, size: 16),
                              SizedBox(width: 6),
                              Text('Nhập mã',
                                  style: TextStyle(
                                      color: mauXanhSang,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _xemLichSu,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFF9800).withAlpha(100)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.clock,
                                  color: Color(0xFFFF9800), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Lịch sử (${_lichSu.length})',
                                style: const TextStyle(
                                    color: Color(0xFFFF9800),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Khu vực quét / chờ
              Expanded(
                child: _dangQuet
                    ? _KhungQuetQR(
                        onDetect: _xuLyQR,
                        onDung: _dungQuet,
                      )
                    : _ManHinhSanSang(
                        dangXuLy: _dangXuLy,
                        onQuet: _batDauQuet,
                        onNhapThuCong: _nhapThuCong,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Màn hình chờ (chưa quét) ───────────────────────────────────

class _ManHinhSanSang extends StatelessWidget {
  final bool dangXuLy;
  final VoidCallback onQuet;
  final VoidCallback onNhapThuCong;

  const _ManHinhSanSang({
    required this.dangXuLy,
    required this.onQuet,
    required this.onNhapThuCong,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: mauCardNen,
                shape: BoxShape.circle,
                border:
                    Border.all(color: mauXanhChinh.withAlpha(150), width: 2),
              ),
              child: const Icon(CupertinoIcons.qrcode_viewfinder,
                  color: mauXanhSang, size: 70),
            ),
            const SizedBox(height: 24),
            const Text('Sẵn sàng soát vé',
                style: TextStyle(
                    color: mauTextTrang,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút bên dưới để mở camera\nvà quét mã QR trên vé hành khách',
              style: TextStyle(color: mauTextXam, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (dangXuLy)
              const CupertinoActivityIndicator(radius: 18, color: mauXanhSang)
            else
              NutGradient(
                nhanDe: 'Quét vé',
                bieuTuong: CupertinoIcons.viewfinder_circle_fill,
                chieuRong: 200,
                onNhan: onQuet,
              ),
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: dangXuLy ? null : onNhapThuCong,
              child: const Text(
                'Nhập mã thủ công →',
                style: TextStyle(
                    color: mauTextXam,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: mauTextXam),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Khung camera quét QR ─────────────────────────────────────────

class _KhungQuetQR extends StatefulWidget {
  final Future<void> Function(String maVe) onDetect;
  final VoidCallback onDung;

  const _KhungQuetQR({required this.onDetect, required this.onDung});

  @override
  State<_KhungQuetQR> createState() => _KhungQuetQRState();
}

class _KhungQuetQRState extends State<_KhungQuetQR> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _daDuocXuLy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera feed (toàn màn hình)
        MobileScanner(
          controller: _ctrl,
          onDetect: (capture) {
            if (_daDuocXuLy) return;
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if (raw == null || raw.isEmpty) return;
            setState(() => _daDuocXuLy = true);
            widget.onDetect(raw);
          },
        ),
        // Lớp phủ tối bên ngoài ô vuông + viền ô vuông
        CustomPaint(
          painter: _ScanOverlayPainter(),
          child: const SizedBox.expand(),
        ),
        // Chữ hướng dẫn bên dưới ô vuông
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 260 + 20),
              const Text(
                'Đưa mã QR vào khung để quét',
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        // Nút dừng quét
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Center(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _ctrl.stop();
                widget.onDung();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xCCE91E63),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.stop_circle,
                        color: CupertinoColors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Dừng quét',
                        style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Overlay painter: nền tối + lỗ hổng ô vuông ──────────────────

class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter();

  static const double _frameSize = 260.0;
  static const double _radius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: _frameSize,
      height: _frameSize,
    );
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    // Vùng tối bên ngoài ô vuông (evenOdd tạo "lỗ hổng" trong suốt)
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0xCC000000),
    );

    // Viền ô vuông
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = mauXanhSang
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Widget hàng thông tin ─────────────────────────────────────────

class _DongThongTin extends StatelessWidget {
  final String nhan;
  final String gia;
  final bool laMauXanh;

  const _DongThongTin(
      {required this.nhan, required this.gia, this.laMauXanh = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nhan,
            style: const TextStyle(color: mauTextXam, fontSize: 13)),
        Flexible(
          child: Text(
            gia,
            style: TextStyle(
                color: laMauXanh ? mauXanhSang : mauTextTrang,
                fontSize: 13,
                fontWeight:
                    laMauXanh ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─── Card thống kê ca ──────────────────────────────────────────────

class _CardThongKeCa extends StatelessWidget {
  final String soLieu;
  final String nhan;
  final Color mau;
  final String? tieuDe;

  const _CardThongKeCa({
    required this.soLieu,
    required this.nhan,
    required this.mau,
    this.tieuDe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mau.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tieuDe != null) ...[
            Text(tieuDe!,
                style: TextStyle(color: mau, fontSize: 11)),
            const SizedBox(height: 2),
          ],
          if (soLieu.isNotEmpty)
            Text(soLieu,
                style: TextStyle(
                    color: mau,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
          Text(
            nhan,
            style: const TextStyle(color: mauTextXam, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
