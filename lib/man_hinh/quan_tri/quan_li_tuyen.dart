import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';
import '../../widget_dung_chung/chon_ngay_kieu_bao_cao.dart';

class QuanLiTuyen extends StatefulWidget {
  const QuanLiTuyen({super.key});
  @override
  State<QuanLiTuyen> createState() => _QuanLiTuyenState();
}

class _QuanLiTuyenState extends State<QuanLiTuyen> {
  int _segment = 0;
  bool _dangTai = true;
  List<TuyenXe> _tuyenList = [];
  List<LichChay> _lichList = [];
  List<Xe> _xeList = [];
  List<TaiXe> _taixeList = [];
  DateTime _ngayLich = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tai();
  }

  String get _ngayStr =>
      '${_ngayLich.day}/${_ngayLich.month}/${_ngayLich.year}';

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final r = await Future.wait([
        CoSoDuLieu().layTatCaTuyen(),
        CoSoDuLieu().layLichChay(ngay: _ngayStr),
        CoSoDuLieu().layTatCaXe(),
        CoSoDuLieu().layTatCaTaiXe(),
      ]);
      if (!mounted) return;
      setState(() {
        _tuyenList = r[0] as List<TuyenXe>;
        _lichList = r[1] as List<LichChay>;
        _xeList = r[2] as List<Xe>;
        _taixeList = r[3] as List<TaiXe>;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  String _gioPhut(int phut) {
    final h = phut ~/ 60;
    final m = phut % 60;
    if (h == 0) return '${m}p';
    if (m == 0) return '${h}g';
    return '${h}g${m}p';
  }

  String _tien(int t) {
    final s = t.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}đ';
  }

  void _themTuyen() {
    final ddCtrl = TextEditingController();
    final ddenCtrl = TextEditingController();
    final kmCtrl = TextEditingController();
    final tgCtrl = TextEditingController();
    final giaCtrl = TextEditingController();
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setM) => _Modal(
          tieuDe: 'Thêm tuyến xe',
          icon: CupertinoIcons.map_pin_ellipse,
          fields: [
            _Nhap(ctrl: ddCtrl, ph: 'Điểm đi (VD: Cần Thơ)'),
            _Nhap(ctrl: ddenCtrl, ph: 'Điểm đến (VD: Hồ Chí Minh)'),
            _Nhap(
                ctrl: kmCtrl,
                ph: 'Khoảng cách (km)',
                kb: TextInputType.number),
            _Nhap(
                ctrl: tgCtrl,
                ph: 'Thời gian di chuyển (phút)',
                kb: TextInputType.number),
            _Nhap(
                ctrl: giaCtrl,
                ph: 'Giá vé cơ sở (VNĐ)',
                kb: TextInputType.number),
          ],
          loi: loi,
          onLuu: () async {
            final dd = ddCtrl.text.trim();
            final dden = ddenCtrl.text.trim();
            final km = int.tryParse(kmCtrl.text.trim()) ?? 0;
            final tg = int.tryParse(tgCtrl.text.trim()) ?? 0;
            final gia = int.tryParse(giaCtrl.text.trim()) ?? 0;
            if (dd.isEmpty || dden.isEmpty || km == 0 || gia == 0) {
              setM(() => loi = 'Vui lòng nhập đầy đủ thông tin');
              return;
            }
            Navigator.of(context, rootNavigator: true).pop();
            await CoSoDuLieu().taoTuyen(TuyenXe(
              diemDi: dd,
              diemDen: dden,
              khoangCach: km,
              thoiGian: tg,
              giaVeCoSo: gia,
              danhSachDiemDon: [],
              danhSachDiemTra: [],
              hoatDong: true,
            ));
            _tai();
          },
        ),
      ),
    );
  }

  void _xoaTuyen(TuyenXe t) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Xóa tuyến'),
        content: Text('Xác nhận xóa tuyến ${t.diemDi} → ${t.diemDen}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await CoSoDuLieu().xoaTuyen(t.id!);
              _tai();
            },
            child: const Text('Xóa'),
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
  }

  void _suaTuyen(TuyenXe t) {
    final ddCtrl = TextEditingController(text: t.diemDi);
    final ddenCtrl = TextEditingController(text: t.diemDen);
    final kmCtrl = TextEditingController(text: t.khoangCach.toString());
    final tgCtrl = TextEditingController(text: t.thoiGian.toString());
    final giaCtrl = TextEditingController(text: t.giaVeCoSo.toString());
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setM) => _Modal(
          tieuDe: 'Sửa tuyến xe',
          icon: CupertinoIcons.pencil,
          fields: [
            _Nhap(ctrl: ddCtrl, ph: 'Điểm đi'),
            _Nhap(ctrl: ddenCtrl, ph: 'Điểm đến'),
            _Nhap(ctrl: kmCtrl, ph: 'Khoảng cách (km)', kb: TextInputType.number),
            _Nhap(ctrl: tgCtrl, ph: 'Thời gian (phút)', kb: TextInputType.number),
            _Nhap(ctrl: giaCtrl, ph: 'Giá vé cơ sở (VNĐ)', kb: TextInputType.number),
          ],
          loi: loi,
          onLuu: () async {
            final dd = ddCtrl.text.trim();
            final dden = ddenCtrl.text.trim();
            final km = int.tryParse(kmCtrl.text.trim()) ?? 0;
            final tg = int.tryParse(tgCtrl.text.trim()) ?? 0;
            final gia = int.tryParse(giaCtrl.text.trim()) ?? 0;
            if (dd.isEmpty || dden.isEmpty || km == 0 || gia == 0) {
              setM(() => loi = 'Vui lòng nhập đầy đủ thông tin');
              return;
            }
            Navigator.of(context, rootNavigator: true).pop();
            await CoSoDuLieu().capNhatTuyen(
              t.id!,
              TuyenXe(
                diemDi: dd, diemDen: dden,
                khoangCach: km, thoiGian: tg,
                giaVeCoSo: gia,
                danhSachDiemDon: t.danhSachDiemDon,
                danhSachDiemTra: t.danhSachDiemTra,
                hoatDong: t.hoatDong,
              ),
            );
            _tai();
          },
        ),
      ),
    );
  }

  void _suaLich(LichChay l) {
    final gioCtrl = TextEditingController(text: l.gio);
    final soGheCtrl = TextEditingController(text: l.soGheToiDa.toString());
    String loaiXe = l.loaiXe;
    int xeIdx = _xeList.indexWhere((x) => x.id == l.xeId);
    int taixeIdx = _taixeList.indexWhere((tx) => tx.id == l.taiXeId);
    String? loi;

    // Pickers start at 0 = "Không phân công", so shift index by 1
    int xePIdx = xeIdx < 0 ? 0 : xeIdx + 1;
    int taixePIdx = taixeIdx < 0 ? 0 : taixeIdx + 1;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          decoration: const BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: mauCardVien,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('Sửa lịch chạy',
                      style: TextStyle(
                          color: mauTextTrang, fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _Nhap(ctrl: gioCtrl, ph: 'Giờ xuất phát (HH:mm)'),
                  const SizedBox(height: 10),
                  _Nhap(ctrl: soGheCtrl, ph: 'Số ghế tối đa',
                      kb: TextInputType.number),
                  const SizedBox(height: 10),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: loaiXe,
                    backgroundColor: mauNenToi,
                    children: const {
                      'Ghế thường': Text('Ghế thường',
                          style: TextStyle(fontSize: 11)),
                      'Giường nằm': Text('Giường nằm',
                          style: TextStyle(fontSize: 11)),
                      'Limousine': Text('Limousine',
                          style: TextStyle(fontSize: 11)),
                    },
                    onValueChanged: (v) {
                      if (v != null) setM(() => loaiXe = v);
                    },
                  ),
                  if (_xeList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Phân công xe',
                        style: TextStyle(color: mauTextXam, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 36,
                        scrollController: FixedExtentScrollController(
                            initialItem: xePIdx),
                        onSelectedItemChanged: (i) => xePIdx = i,
                        children: [
                          const Center(
                              child: Text('— Không phân công —',
                                  style: TextStyle(
                                      color: mauTextXam, fontSize: 13))),
                          ..._xeList.map((x) => Center(
                                child: Text(
                                    '${x.bienSo} (${x.loaiXe})',
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontSize: 13)),
                              )),
                        ],
                      ),
                    ),
                  ],
                  if (_taixeList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Phân công tài xế',
                        style: TextStyle(color: mauTextXam, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 36,
                        scrollController: FixedExtentScrollController(
                            initialItem: taixePIdx),
                        onSelectedItemChanged: (i) => taixePIdx = i,
                        children: [
                          const Center(
                              child: Text('— Không phân công —',
                                  style: TextStyle(
                                      color: mauTextXam, fontSize: 13))),
                          ..._taixeList.map((tx) => Center(
                                child: Text(tx.ten,
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontSize: 13)),
                              )),
                        ],
                      ),
                    ),
                  ],
                  if (loi != null) ...[
                    const SizedBox(height: 8),
                    Text(loi!,
                        style: const TextStyle(
                            color: mauDoHong, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () async {
                        final soGhe =
                            int.tryParse(soGheCtrl.text.trim()) ?? 0;
                        if (soGhe == 0 || gioCtrl.text.trim().isEmpty) {
                          setM(() => loi = 'Nhập đầy đủ thông tin');
                          return;
                        }
                        final xeChon = (xePIdx > 0 && xePIdx - 1 < _xeList.length)
                            ? _xeList[xePIdx - 1] : null;
                        final txChon = (taixePIdx > 0 && taixePIdx - 1 < _taixeList.length)
                            ? _taixeList[taixePIdx - 1] : null;
                        Navigator.of(context, rootNavigator: true).pop();
                        await CoSoDuLieu().capNhatLichChay(l.id!, {
                          'gio': gioCtrl.text.trim(),
                          'loaiXe': loaiXe,
                          'soGheToiDa': soGhe,
                          'xeId': xeChon?.id ?? '',
                          'taiXeId': txChon?.id ?? '',
                          'bienSoXe': xeChon?.bienSo ?? '',
                          'tenTaiXe': txChon?.ten ?? '',
                        });
                        _tai();
                      },
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _doiTrangThaiLich(LichChay l) {
    const states = ['cho', 'dang_chay', 'hoan_thanh', 'huy'];
    const labels = ['Chờ xuất phát', 'Đang chạy', 'Hoàn thành', 'Hủy chuyến'];

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('Cập nhật trạng thái\n${l.diemDi} → ${l.diemDen}  ${l.gio}',
            style: const TextStyle(fontSize: 14)),
        actions: List.generate(states.length, (i) {
          final isCurrent = l.trangThai == states[i];
          return CupertinoActionSheetAction(
            isDefaultAction: isCurrent,
            isDestructiveAction: states[i] == 'huy',
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              if (!isCurrent) {
                await CoSoDuLieu()
                    .capNhatLichChay(l.id!, {'trangThai': states[i]});
                _tai();
              }
            },
            child: Text(isCurrent
                ? '${labels[i]}  ✓ (hiện tại)'
                : labels[i]),
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  void _themLich() {
    if (_tuyenList.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Chưa có tuyến'),
          content: const Text('Vui lòng tạo tuyến xe trước.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    int tuyenIdx = 0;
    final gioCtrl = TextEditingController(text: '07:00');
    final soGheCtrl = TextEditingController();
    String loaiXe = 'Ghế thường';
    int xePIdx = 0;
    int taixePIdx = 0;
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          decoration: const BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: mauCardVien,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('Thêm lịch chạy',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Chọn tuyến',
                    style: TextStyle(color: mauTextXam, fontSize: 12)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 110,
                  child: CupertinoPicker(
                    itemExtent: 38,
                    onSelectedItemChanged: (i) => tuyenIdx = i,
                    children: _tuyenList
                        .map((t) => Center(
                              child: Text(
                                  '${t.diemDi} → ${t.diemDen}',
                                  style: const TextStyle(
                                      color: mauTextTrang,
                                      fontSize: 14)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                _Nhap(ctrl: gioCtrl, ph: 'Giờ xuất phát (HH:mm)'),
                const SizedBox(height: 10),
                _Nhap(
                    ctrl: soGheCtrl,
                    ph: 'Số ghế tối đa',
                    kb: TextInputType.number),
                const SizedBox(height: 10),
                CupertinoSlidingSegmentedControl<String>(
                  groupValue: loaiXe,
                  backgroundColor: mauNenToi,
                  children: const {
                    'Ghế thường': Text('Ghế thường',
                        style: TextStyle(fontSize: 11)),
                    'Giường nằm': Text('Giường nằm',
                        style: TextStyle(fontSize: 11)),
                    'Limousine':
                        Text('Limousine', style: TextStyle(fontSize: 11)),
                  },
                  onValueChanged: (v) {
                    if (v != null) setM(() => loaiXe = v);
                  },
                ),
                if (_xeList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Phân công xe (tuỳ chọn)',
                      style: TextStyle(color: mauTextXam, fontSize: 12)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 100,
                    child: CupertinoPicker(
                      itemExtent: 36,
                      onSelectedItemChanged: (i) => xePIdx = i,
                      children: [
                        const Center(
                            child: Text('— Không phân công —',
                                style: TextStyle(
                                    color: mauTextXam, fontSize: 13))),
                        ..._xeList.map((x) => Center(
                              child: Text(
                                  '${x.bienSo} (${x.loaiXe})',
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 13)),
                            )),
                      ],
                    ),
                  ),
                ],
                if (_taixeList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Phân công tài xế (tuỳ chọn)',
                      style: TextStyle(color: mauTextXam, fontSize: 12)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 100,
                    child: CupertinoPicker(
                      itemExtent: 36,
                      onSelectedItemChanged: (i) => taixePIdx = i,
                      children: [
                        const Center(
                            child: Text('— Không phân công —',
                                style: TextStyle(
                                    color: mauTextXam, fontSize: 13))),
                        ..._taixeList.map((tx) => Center(
                              child: Text(tx.ten,
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 13)),
                            )),
                      ],
                    ),
                  ),
                ],
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!,
                      style: const TextStyle(
                          color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () async {
                      final tuyen = _tuyenList[tuyenIdx];
                      final soGhe =
                          int.tryParse(soGheCtrl.text.trim()) ?? 0;
                      if (soGhe == 0 ||
                          gioCtrl.text.trim().isEmpty) {
                        setM(() => loi = 'Nhập đầy đủ thông tin');
                        return;
                      }
                      final xeChon = (xePIdx > 0 && xePIdx - 1 < _xeList.length)
                          ? _xeList[xePIdx - 1] : null;
                      final txChon = (taixePIdx > 0 && taixePIdx - 1 < _taixeList.length)
                          ? _taixeList[taixePIdx - 1] : null;
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().taoLichChay(LichChay(
                        tuyenId: tuyen.id!,
                        diemDi: tuyen.diemDi,
                        diemDen: tuyen.diemDen,
                        ngay: _ngayStr,
                        gio: gioCtrl.text.trim(),
                        loaiXe: loaiXe,
                        soGheToiDa: soGhe,
                        soGheConLai: soGhe,
                        trangThai: 'cho',
                        xeId: xeChon?.id ?? '',
                        taiXeId: txChon?.id ?? '',
                        bienSoXe: xeChon?.bienSo ?? '',
                        tenTaiXe: txChon?.ten ?? '',
                      ));
                      _tai();
                    },
                    child: const Text('Lưu lịch chạy'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _mauLich(String t) {
    switch (t) {
      case 'cho':
        return mauCam;
      case 'dang_chay':
        return mauXanhSang;
      case 'hoan_thanh':
        return const Color(0xFF00C853);
      default:
        return mauDoHong;
    }
  }

  String _tenLich(String t) {
    switch (t) {
      case 'cho':
        return 'Chờ';
      case 'dang_chay':
        return 'Đang chạy';
      case 'hoan_thanh':
        return 'Hoàn thành';
      default:
        return 'Hủy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Tuyến & Lịch chạy',
            style: TextStyle(color: mauTextTrang)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _tai,
              child: const Icon(CupertinoIcons.arrow_clockwise,
                  color: mauXanhSang, size: 18),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _segment == 0 ? _themTuyen : _themLich,
              child: const Icon(CupertinoIcons.add,
                  color: mauXanhSang, size: 22),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: mauNenToi2,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _segment,
                backgroundColor: mauNenToi,
                children: const {
                  0: Text('Tuyến xe', style: TextStyle(fontSize: 13)),
                  1: Text('Lịch chạy', style: TextStyle(fontSize: 13)),
                },
                onValueChanged: (v) {
                  if (v != null) setState(() => _segment = v);
                },
              ),
            ),
            if (_segment == 1)
              Container(
                color: mauNenToi2,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final d = await chonNgayKieuBaoCao(
                          context: context,
                          ngayBanDau: _ngayLich,
                          ngayToiDa: DateTime.now().add(const Duration(days: 365)),
                          tieuDe: 'Chọn ngày lịch chạy',
                        );
                        if (d == null || !mounted) return;
                        setState(() => _ngayLich = d);
                        _tai();
                      },
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.calendar,
                              color: mauXanhSang, size: 16),
                          const SizedBox(width: 6),
                          Text(_ngayStr,
                              style: const TextStyle(
                                  color: mauXanhSang, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                color: mauNenToi,
                child: _dangTai
                    ? const Center(
                        child: CupertinoActivityIndicator(
                            radius: 14, color: mauXanhSang))
                    : _segment == 0
                        ? _buildTuyenList()
                        : _buildLichList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTuyenList() {
    if (_tuyenList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.map, color: mauTextXam, size: 48),
            SizedBox(height: 12),
            Text('Chưa có tuyến nào',
                style: TextStyle(color: mauTextXam)),
            SizedBox(height: 6),
            Text('Nhấn + để thêm tuyến mới',
                style: TextStyle(color: mauTextXamNhat, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tuyenList.length,
      itemBuilder: (_, i) {
        final t = _tuyenList[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: t.hoatDong
                    ? mauXanhSang.withAlpha(60)
                    : mauCardVien),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${t.diemDi} → ${t.diemDen}',
                      style: const TextStyle(
                          color: mauTextTrang,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  _Badget(
                    t.hoatDong ? 'Hoạt động' : 'Ngừng',
                    t.hoatDong
                        ? const Color(0xFF00C853)
                        : mauDoHong,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  _IChip(CupertinoIcons.location_fill,
                      '${t.khoangCach} km'),
                  _IChip(CupertinoIcons.clock,
                      _gioPhut(t.thoiGian)),
                  _IChip(CupertinoIcons.money_dollar,
                      _tien(t.giaVeCoSo)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _suaTuyen(t),
                    child: const Icon(CupertinoIcons.pencil,
                        color: mauXanhSang, size: 20),
                  ),
                  const SizedBox(width: 4),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await CoSoDuLieu().capNhatTuyen(
                        t.id!,
                        TuyenXe(
                          diemDi: t.diemDi,
                          diemDen: t.diemDen,
                          khoangCach: t.khoangCach,
                          thoiGian: t.thoiGian,
                          giaVeCoSo: t.giaVeCoSo,
                          danhSachDiemDon: t.danhSachDiemDon,
                          danhSachDiemTra: t.danhSachDiemTra,
                          hoatDong: !t.hoatDong,
                        ),
                      );
                      _tai();
                    },
                    child: Icon(
                      t.hoatDong
                          ? CupertinoIcons.pause_circle
                          : CupertinoIcons.play_circle,
                      color: t.hoatDong
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF00C853),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _xoaTuyen(t),
                    child: const Icon(CupertinoIcons.trash,
                        color: mauDoHong, size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLichList() {
    if (_lichList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.calendar_badge_plus,
                color: mauTextXam, size: 48),
            SizedBox(height: 12),
            Text('Không có lịch chạy ngày này',
                style: TextStyle(color: mauTextXam)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lichList.length,
      itemBuilder: (_, i) {
        final l = _lichList[i];
        final mau = _mauLich(l.trangThai);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mau.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: mau.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(l.gio,
                          style: TextStyle(
                              color: mau,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l.diemDi} → ${l.diemDen}',
                            style: const TextStyle(
                                color: mauTextTrang,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text(
                            '${l.loaiXe}  •  ${l.soGheConLai}/${l.soGheToiDa} ghế trống',
                            style: const TextStyle(
                                color: mauTextXam, fontSize: 12)),
                        if (l.bienSoXe.isNotEmpty)
                          Text('Xe: ${l.bienSoXe}',
                              style: const TextStyle(
                                  color: mauTextXamNhat, fontSize: 11)),
                        if (l.tenTaiXe.isNotEmpty)
                          Text('Tài xế: ${l.tenTaiXe}',
                              style: const TextStyle(
                                  color: mauTextXamNhat, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _doiTrangThaiLich(l),
                        child: _Badget(_tenLich(l.trangThai), mau),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _suaLich(l),
                            child: const Icon(CupertinoIcons.pencil,
                                color: mauXanhSang, size: 16),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await CoSoDuLieu().xoaLichChay(l.id!);
                              _tai();
                            },
                            child: const Icon(CupertinoIcons.trash,
                                color: mauDoHong, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────

class _Nhap extends StatelessWidget {
  final TextEditingController ctrl;
  final String ph;
  final TextInputType? kb;
  const _Nhap({required this.ctrl, required this.ph, this.kb});

  @override
  Widget build(BuildContext context) => CupertinoTextField(
        controller: ctrl,
        placeholder: ph,
        keyboardType: kb,
        placeholderStyle:
            const TextStyle(color: mauTextXam, fontSize: 14),
        style: const TextStyle(color: mauTextTrang, fontSize: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mauNenToi,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: mauCardVien),
        ),
      );
}

class _Modal extends StatelessWidget {
  final String tieuDe;
  final IconData icon;
  final List<Widget> fields;
  final String? loi;
  final Future<void> Function() onLuu;
  const _Modal(
      {required this.tieuDe,
      required this.icon,
      required this.fields,
      this.loi,
      required this.onLuu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
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
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: mauCardVien,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Icon(icon, color: mauXanhSang, size: 20),
                const SizedBox(width: 8),
                Text(tieuDe,
                    style: const TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...fields.map(
                (f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)),
            if (loi != null) ...[
              Text(loi!,
                  style: const TextStyle(
                      color: mauDoHong, fontSize: 12)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: onLuu,
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badget extends StatelessWidget {
  final String nhan;
  final Color mau;
  const _Badget(this.nhan, this.mau);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: mau.withAlpha(40),
            borderRadius: BorderRadius.circular(10)),
        child: Text(nhan,
            style: TextStyle(
                color: mau,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}

class _IChip extends StatelessWidget {
  final IconData icon;
  final String nhan;
  const _IChip(this.icon, this.nhan);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: mauTextXam, size: 13),
          const SizedBox(width: 4),
          Text(nhan,
              style: const TextStyle(color: mauTextXam, fontSize: 12)),
        ],
      );
}
