import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';
import 'dang_nhap.dart';

class VeCuaToi extends StatefulWidget {
  const VeCuaToi({super.key});

  @override
  State<VeCuaToi> createState() => _VeCuaToiState();
}

class _VeCuaToiState extends State<VeCuaToi> {
  int _tabChon = 0;
  bool _dangTai = false;
  bool _daDangNhapTruoc = false;

  @override
  void initState() {
    super.initState();
    _daDangNhapTruoc = TrangThaiUngDung().daDangNhap;
    TrangThaiUngDung().addListener(_khoiTaiNeuCan);
    if (TrangThaiUngDung().daDangNhap) _taiDanhSachVe();
  }

  @override
  void dispose() {
    TrangThaiUngDung().removeListener(_khoiTaiNeuCan);
    super.dispose();
  }

  void _khoiTaiNeuCan() {
    final daDangNhap = TrangThaiUngDung().daDangNhap;
    if (daDangNhap && !_daDangNhapTruoc) _taiDanhSachVe();
    _daDangNhapTruoc = daDangNhap;
    if (mounted) setState(() {});
  }

  Future<void> _taiDanhSachVe() async {
    if (!TrangThaiUngDung().daDangNhap) return;
    setState(() => _dangTai = true);
    await TrangThaiUngDung().taiLaiDanhSachVe();
    await TrangThaiUngDung().kiemTraBoLo();
    if (mounted) setState(() => _dangTai = false);
  }

  List<Ve> get _veHienThi {
    final dsVe = TrangThaiUngDung().danhSachVe;
    if (_tabChon == 0) return dsVe.toList();
    final map = {1: 'cho', 2: 'hoan_thanh', 3: 'bo_lo', 4: 'huy'};
    final trang = map[_tabChon];
    return dsVe.where((v) => v.trangThai == trang).toList();
  }

  /// True nếu chàyến trong cửa sổ -15 phút đến +4 giờ so với giờ khởi hành
  bool _laGanKhoiHanh(Ve ve) {
    final kh = CoSoDuLieu.parseGioKhoiHanh(ve.ngay, ve.gio);
    if (kh == null) return false;
    final now = DateTime.now();
    return now.isAfter(kh.subtract(const Duration(minutes: 15))) &&
        now.isBefore(kh.add(const Duration(hours: 4)));
  }

  void _lenXe(Ve ve) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Xác nhận lên xe?'),
        content: Text(
            'Bạn xác nhận đã lên xe\n${ve.diemDi} → ${ve.diemDen} lúc ${ve.gio}?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Huỷ'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              TrangThaiUngDung().lenXeLocal(ve.id!);
              await CoSoDuLieu().lenXe(ve.id!);
            },
            child: const Text('Đã lên xe ✓'),
          ),
        ],
      ),
    );
  }

  void _xemChiTiet(Ve ve) {
    final mauTrangThai = ve.trangThai == 'cho'
        ? mauCam
        : ve.trangThai == 'hoan_thanh'
            ? mauXanhLa
            : ve.trangThai == 'bo_lo'
                ? mauTimChinh
                : mauDoHong;
    final nhanTrangThai = ve.trangThai == 'cho'
        ? 'Chờ đi'
        : ve.trangThai == 'hoan_thanh'
            ? 'Hoàn thành'
            : ve.trangThai == 'bo_lo'
                ? 'Bỏ lỡ'
                : 'Đã hủy';
    final ganKhoiHanh = _laGanKhoiHanh(ve);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: mauNenToi2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: mauCardVien, borderRadius: BorderRadius.circular(2)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chi tiết vé',
                      style: TextStyle(
                          color: mauTextTrang,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: mauTrangThai.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mauTrangThai),
                    ),
                    child: Text(nhanTrangThai,
                        style: TextStyle(
                            color: mauTrangThai,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mauCardNen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: mauCardVien),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Từ', style: TextStyle(color: mauTextXam, fontSize: 11)),
                          Text(ve.diemDi,
                              style: const TextStyle(
                                  color: mauTextTrang,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ]),
                        const Icon(CupertinoIcons.arrow_right,
                            color: mauXanhSang, size: 18),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Đến', style: TextStyle(color: mauTextXam, fontSize: 11)),
                          Text(ve.diemDen,
                              style: const TextStyle(
                                  color: mauTextTrang,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ]),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(height: 0.5, color: mauCardVien),
                    ),
                    _DongChiTiet(nhan: 'Mã vé', gia: ve.maVe, laMauXanh: true),
                    const SizedBox(height: 6),
                    _DongDiaChiVe(
                      bieu: CupertinoIcons.location_solid,
                      nhan: 'Điểm đón',
                      ten: ve.diemDi,
                      diaChi: diaChiBenXe[ve.diemDi] ?? ve.diemDi,
                    ),
                    const SizedBox(height: 6),
                    _DongDiaChiVe(
                      bieu: CupertinoIcons.location,
                      nhan: 'Điểm xuống',
                      ten: ve.diemDen,
                      diaChi: diaChiBenXe[ve.diemDen] ?? ve.diemDen,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(height: 0.5, color: mauCardVien),
                    ),
                    _DongChiTiet(nhan: 'Ngày đi', gia: ve.ngay),
                    const SizedBox(height: 6),
                    _DongChiTiet(nhan: 'Giờ khởi hành', gia: ve.gio),
                    const SizedBox(height: 6),
                    _DongChiTiet(nhan: 'Loại xe', gia: ve.loaiXe),
                    const SizedBox(height: 6),
                    _DongChiTiet(
                        nhan: 'Ghế số',
                        gia: (ve.danhSachGheParsed..sort()).join(', ')),
                    const SizedBox(height: 6),
                    _DongChiTiet(nhan: 'Ngày đặt', gia: ve.ngayDat),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(height: 0.5, color: mauCardVien),
                    ),
                    _DongChiTiet(
                        nhan: 'Tổng tiền',
                        gia: _dinhDangVe(ve.tongTien),
                        laMauXanh: true,
                        laBold: true),
                  ],
                ),
              ),
              if (ve.trangThai == 'cho') ...[
                const SizedBox(height: 16),
                if (ganKhoiHanh) ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      _lenXe(ve);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.checkmark_circle_fill,
                              color: CupertinoColors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Xác nhận lên xe ✓',
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _xemQR(ve);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mauXanhChinh.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mauXanhChinh.withAlpha(102)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.qrcode, color: mauXanhSang, size: 18),
                            SizedBox(width: 8),
                            Text('Xem mã QR',
                                style: TextStyle(
                                    color: mauXanhSang, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _huyVe(ve);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mauDoHong.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mauDoHong.withAlpha(100)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.xmark_circle, color: mauDoHong, size: 18),
                            SizedBox(width: 8),
                            Text('Hủy vé',
                                style: TextStyle(
                                    color: mauDoHong, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
              // Nút chia sẻ + đánh giá cho vé hoàn thành
              if (ve.trangThai == 'hoan_thanh') ...[  
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _chiaSeVe(ve);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mauXanhChinh.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mauXanhChinh.withAlpha(102)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.share, color: mauXanhSang, size: 18),
                            SizedBox(width: 6),
                            Text('Chia sẻ',
                                style: TextStyle(
                                    color: mauXanhSang, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _danhGiaVe(ve);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ve.danhGia != null
                              ? mauXanhLa.withAlpha(25)
                              : const Color(0xFFFFD700).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ve.danhGia != null
                                ? mauXanhLa.withAlpha(100)
                                : const Color(0xFFFFD700).withAlpha(100)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              ve.danhGia != null
                                  ? CupertinoIcons.star_fill
                                  : CupertinoIcons.star,
                              color: ve.danhGia != null
                                  ? mauXanhLa
                                  : const Color(0xFFFFD700),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ve.danhGia != null
                                  ? 'Đã đánh giá ${ve.danhGia}/5'
                                  : 'Đánh giá',
                              style: TextStyle(
                                  color: ve.danhGia != null
                                      ? mauXanhLa
                                      : const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _dinhDangVe(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}đ';
  }

  void _xemQR(Ve ve) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        color: mauCardNen,
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vé điện tử',
                      style: TextStyle(
                          color: mauTextTrang, fontWeight: FontWeight.bold, fontSize: 17)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, color: mauTextXam),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  color: mauNenToi,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mauXanhChinh.withAlpha(128)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.qrcode, color: mauTextTrang, size: 100),
                    SizedBox(height: 8),
                    Text('Mã QR', style: TextStyle(color: mauTextXam, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(ve.maVe,
                  style: const TextStyle(
                      color: mauXanhSang, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${ve.diemDi}  \u2192  ${ve.diemDen}',
                  style: const TextStyle(color: mauTextTrang)),
              Text('${ve.ngay} | ${ve.gio}',
                  style: const TextStyle(color: mauTextXam, fontSize: 13)),
              const SizedBox(height: 20),
              // Nút chia sẻ vé
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _chiaSeVe(ve);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  decoration: BoxDecoration(
                    color: mauXanhChinh.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauXanhChinh.withAlpha(100)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.share, color: mauXanhSang, size: 18),
                      SizedBox(width: 8),
                      Text('Chia sẻ vé',
                          style: TextStyle(
                              color: mauXanhSang, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _chiaSeVe(Ve ve) {
    final ghe = (ve.danhSachGheParsed..sort()).join(', ');
    final text = '🙌 Vé xe BookBus\n'
        'Mã vé: ${ve.maVe}\n'
        'Tuyến: ${ve.diemDi} \u2192 ${ve.diemDen}\n'
        'Ngày: ${ve.ngay} | Giờ: ${ve.gio}\n'
        'Ghế: $ghe | Loại xe: ${ve.loaiXe}\n'
        'Tổng tiền: ${_dinhDangVe(ve.tongTien)}\n'
        '🚌 BookBus - Đặt vé nhanh, đi xe tiện lợi!';
    Share.share(text);
  }

  void _danhGiaVe(Ve ve) {
    int soSao = ve.danhGia ?? 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          color: mauCardNen,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: mauCardVien,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.star_fill,
                      color: CupertinoColors.white, size: 28),
                ),
                const SizedBox(height: 14),
                const Text('Đánh giá chuyến đi',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${ve.diemDi} \u2192 ${ve.diemDen} | ${ve.ngay}',
                    style: const TextStyle(color: mauTextXam, fontSize: 13)),
                const SizedBox(height: 24),
                // 5 ngôi sao
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final selected = i < soSao;
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onPressed: () => setModal(() => soSao = i + 1),
                      child: Icon(
                        selected
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: selected ? const Color(0xFFFFD700) : mauTextXamNhat,
                        size: 38,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  soSao == 0
                      ? 'Chạm vào sao để đánh giá'
                      : soSao == 1
                          ? 'Rất tệ 😞'
                          : soSao == 2
                              ? 'Không tốt lắm 😕'
                              : soSao == 3
                                  ? 'Bình thường 😐'
                                  : soSao == 4
                                      ? 'Khá tốt 🙂'
                                      : 'Tuyệt vời! 🌟',
                  style: TextStyle(
                    color: soSao > 0
                        ? const Color(0xFFFFD700)
                        : mauTextXamNhat,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                NutGradient(
                  nhanDe: 'Gửi đánh giá',
                  bieuTuong: CupertinoIcons.checkmark_circle,
                  chieuRong: double.infinity,
                  onNhan: soSao == 0
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          TrangThaiUngDung().danhGiaVeLocal(ve.id!, soSao);
                          await CoSoDuLieu().luuDanhGia(ve.id!, soSao);
                          if (!mounted) return;
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('Cảm ơn bạn!'),
                              content: Text(
                                  'Bạn đã đánh giá $soSao/5 sao cho chuyến ${ve.diemDi} \u2192 ${ve.diemDen}.'),
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
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _huyVe(Ve ve) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hủy vé?'),
        content: Text('Bạn chắc chắn muốn hủy vé ${ve.maVe}?\nHành động này không thể hoàn tác.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Không'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              TrangThaiUngDung().huyVeLocal(ve.id!);
              await CoSoDuLieu().huyVe(ve.id!);
            },
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: mauNenToi2.withAlpha(230),
              border: null,
              largeTitle: const Text('Vé của tôi',
                  style: TextStyle(color: mauTextTrang)),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _taiDanhSachVe,
                child: const Icon(CupertinoIcons.refresh, color: mauXanhSang, size: 20),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: CupertinoSlidingSegmentedControl<int>(
                  backgroundColor: mauCardNen,
                  thumbColor: mauXanhChinh,
                  groupValue: _tabChon,
                  onValueChanged: (v) {
                    if (v != null) setState(() => _tabChon = v);
                  },
                  children: const {
                    0: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('Tất cả', style: TextStyle(fontSize: 11, color: mauTextTrang))),
                    1: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('Chờ đi', style: TextStyle(fontSize: 11, color: mauTextTrang))),
                    2: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('Đã đi', style: TextStyle(fontSize: 11, color: mauTextTrang))),
                    3: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('Bỏ lỡ', style: TextStyle(fontSize: 11, color: mauTextTrang))),
                    4: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('Đã hủy', style: TextStyle(fontSize: 11, color: mauTextTrang))),
                  },
                ),
              ),
            ),
            if (_dangTai)
              const SliverFillRemaining(
                child: Center(
                  child: CupertinoActivityIndicator(radius: 16, color: mauXanhSang),
                ),
              )
            else if (!TrangThaiUngDung().daDangNhap)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.lock_circle,
                            color: mauTextXamNhat, size: 72),
                        const SizedBox(height: 16),
                        const Text('Vui lòng đăng nhập',
                            style: TextStyle(
                                color: mauTextTrang,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Đăng nhập để xem và quản lý vé của bạn',
                          style: TextStyle(color: mauTextXam, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        NutGradient(
                          nhanDe: 'Đăng nhập ngay',
                          bieuTuong: CupertinoIcons.arrow_right,
                          chieuRong: double.infinity,
                          onNhan: () => Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => const DangNhap(laModal: true)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_veHienThi.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.ticket, color: mauTextXamNhat, size: 60),
                      SizedBox(height: 12),
                      Text('Chưa có vé', style: TextStyle(color: mauTextXam, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Đặt vé để xem lịch sử của bạn',
                          style: TextStyle(color: mauTextXamNhat, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => GestureDetector(
                      onTap: () => _xemChiTiet(_veHienThi[i]),
                      child: _CardVe(
                        ve: _veHienThi[i],
                        onXemQR: () => _xemQR(_veHienThi[i]),
                        onHuy: () => _huyVe(_veHienThi[i]),
                        onChiaSe: () => _chiaSeVe(_veHienThi[i]),
                        onDanhGia: () => _danhGiaVe(_veHienThi[i]),
                        onLenXe: _laGanKhoiHanh(_veHienThi[i])
                            ? () => _lenXe(_veHienThi[i])
                            : null,
                      ),
                    ),
                    childCount: _veHienThi.length,
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }
}

class _CardVe extends StatelessWidget {
  final Ve ve;
  final VoidCallback onXemQR;
  final VoidCallback onHuy;
  final VoidCallback? onChiaSe;
  final VoidCallback? onDanhGia;
  final VoidCallback? onLenXe;

  const _CardVe({
    required this.ve,
    required this.onXemQR,
    required this.onHuy,
    this.onChiaSe,
    this.onDanhGia,
    this.onLenXe,
  });

  Color get _mauTrangThai {
    switch (ve.trangThai) {
      case 'cho': return mauCam;
      case 'hoan_thanh': return mauXanhLa;
      case 'bo_lo': return mauTimChinh;
      default: return mauDoHong;
    }
  }

  String get _nhanTrangThai {
    switch (ve.trangThai) {
      case 'cho': return 'Chờ đi';
      case 'hoan_thanh': return 'Hoàn thành';
      case 'bo_lo': return 'Bỏ lỡ';
      default: return 'Đã hủy';
    }
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

  @override
  Widget build(BuildContext context) {
    final ghe = ve.danhSachGheParsed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mauCardVien),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: gradientChinh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ve.maVe,
                      style: const TextStyle(
                          color: CupertinoColors.white, fontWeight: FontWeight.bold)),
                  Text('${ve.ngay} | ${ve.gio}',
                      style: const TextStyle(
                          color: CupertinoColors.systemGrey5, fontSize: 12)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _mauTrangThai.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _mauTrangThai),
                  ),
                  child: Text(_nhanTrangThai,
                      style: TextStyle(
                          color: _mauTrangThai,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Từ', style: TextStyle(color: mauTextXam, fontSize: 11)),
                        Text(ve.diemDi,
                            style: const TextStyle(
                                color: mauTextTrang,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ]),
                    ),
                    const Icon(CupertinoIcons.arrow_right, color: mauXanhSang, size: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('Đến', style: TextStyle(color: mauTextXam, fontSize: 11)),
                        Text(ve.diemDen,
                            style: const TextStyle(
                                color: mauTextTrang,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Ghế số', style: TextStyle(color: mauTextXam, fontSize: 11)),
                      Text(ghe.join(', '),
                          style: const TextStyle(
                              color: mauXanhSang,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Tổng tiền', style: TextStyle(color: mauTextXam, fontSize: 11)),
                      Text(_dinhDang(ve.tongTien),
                          style: const TextStyle(
                              color: mauXanhLa,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ]),
                  ],
                ),
                if (ve.trangThai == 'cho') ...[
                  const SizedBox(height: 12),
                  if (onLenXe != null) ...[
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onLenXe,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.checkmark_circle_fill,
                                color: CupertinoColors.white, size: 17),
                            SizedBox(width: 8),
                            Text('Xác nhận lên xe ✓',
                                style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onXemQR,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: mauXanhChinh.withAlpha(38),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: mauXanhChinh.withAlpha(102)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.qrcode, color: mauXanhSang, size: 16),
                              SizedBox(width: 8),
                              Text('Xem mã QR',
                                  style: TextStyle(color: mauXanhSang, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onHuy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: mauDoHong.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: mauDoHong.withAlpha(100)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.xmark_circle, color: mauDoHong, size: 16),
                              SizedBox(width: 8),
                              Text('Hủy vé',
                                  style: TextStyle(color: mauDoHong, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
                if (ve.trangThai == 'hoan_thanh') ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onChiaSe,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: mauXanhChinh.withAlpha(38),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: mauXanhChinh.withAlpha(102)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.share, color: mauXanhSang, size: 16),
                              SizedBox(width: 8),
                              Text('Chia sẻ',
                                  style: TextStyle(color: mauXanhSang, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onDanhGia,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: ve.danhGia != null
                                ? mauXanhLa.withAlpha(25)
                                : const Color(0xFFFFD700).withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: ve.danhGia != null
                                    ? mauXanhLa.withAlpha(100)
                                    : const Color(0xFFFFD700).withAlpha(100)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ve.danhGia != null
                                    ? CupertinoIcons.star_fill
                                    : CupertinoIcons.star,
                                color: ve.danhGia != null
                                    ? mauXanhLa
                                    : const Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ve.danhGia != null
                                    ? 'Đã đánh giá ${ve.danhGia}★'
                                    : 'Đánh giá',
                                style: TextStyle(
                                  color: ve.danhGia != null
                                      ? mauXanhLa
                                      : const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DongChiTiet extends StatelessWidget {
  final String nhan;
  final String gia;
  final bool laMauXanh;
  final bool laBold;

  const _DongChiTiet({
    required this.nhan,
    required this.gia,
    this.laMauXanh = false,
    this.laBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nhan, style: const TextStyle(color: mauTextXam, fontSize: 13)),
        Flexible(
          child: Text(gia,
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: laMauXanh ? mauXanhSang : mauTextTrang,
                  fontWeight: laBold ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13)),
        ),
      ],
    );
  }
}

class _DongDiaChiVe extends StatelessWidget {
  final IconData bieu;
  final String nhan;
  final String ten;
  final String diaChi;
  const _DongDiaChiVe({required this.bieu, required this.nhan, required this.ten, required this.diaChi});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(bieu, color: mauXanhSang, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nhan, style: const TextStyle(color: mauTextXam, fontSize: 11)),
              Text(ten, style: const TextStyle(color: mauTextTrang, fontWeight: FontWeight.w600, fontSize: 13)),
              Text(diaChi, style: const TextStyle(color: mauTextXam, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}