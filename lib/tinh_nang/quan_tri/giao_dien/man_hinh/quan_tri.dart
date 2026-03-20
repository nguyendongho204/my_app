import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import 'tab_quan_tri/quan_li_tuyen.dart';
import 'tab_quan_tri/quan_li_xe.dart';
import 'tab_quan_tri/quan_li_tai_xe.dart';
import 'tab_quan_tri/quan_li_don_ve.dart';
import 'tab_quan_tri/doi_soat_thu.dart';
import 'tab_quan_tri/bao_cao.dart';
import 'tab_quan_tri/quan_li_nguoi_dung.dart';
import 'tab_quan_tri/ho_tro_kh.dart';
import 'tab_quan_tri/cau_hinh.dart';
import 'quan_li_khuyen_mai.dart';

// ─── Main ─────────────────────────────────────────────────────────

class QuanTri extends StatefulWidget {
  final Admin admin;
  const QuanTri({super.key, required this.admin});

  @override
  State<QuanTri> createState() => _QuanTriState();
}

class _QuanTriState extends State<QuanTri> {
  bool _dangTaiStats = true;
  int _soVe = 0;
  int _doanhThu = 0;
  int _soNV = 0;
  int _soKhieuNai = 0;

  @override
  void initState() {
    super.initState();
    _taiStats();
  }

  Future<void> _taiStats() async {
    setState(() => _dangTaiStats = true);
    try {
      // Tải song song các nguồn dữ liệu để hiển thị số liệu tổng quan nhanh hơn.
      final r = await Future.wait([
        CoSoDuLieu().layTatCaNguoiDung(),
        CoSoDuLieu().layTatCaKhieuNai(),
        CoSoDuLieu().layTatCaNhanVien(),
        CoSoDuLieu().layTatCaVe(),
      ]);
      final kns = r[1] as List<KhieuNai>;
      final nvs = r[2] as List<NhanVien>;
      final ves = r[3] as List<Ve>;
      final doanh = ves
          .where((v) => v.trangThai == 'hoan_thanh')
          .fold<int>(0, (s, v) => s + v.tongTien);
      if (!mounted) return;
      setState(() {
        _soVe = ves.length;
        _doanhThu = doanh;
        _soNV = nvs.length;
        _soKhieuNai =
            kns.where((k) => k.trangThai == 'cho_xu_ly').length;
        _dangTaiStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTaiStats = false);
    }
  }

  void _dangXuat() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Thoát khỏi trang quản trị?'),
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
  }

  String _fTien(int t) {
    if (t >= 1000000) return '${(t / 1000000).toStringAsFixed(1)}M đ';
    if (t >= 1000) return '${(t / 1000).toStringAsFixed(0)}K đ';
    return '$tđ';
  }

  static const _features = [
    _ChucNang('Tuyến & Lịch chạy', CupertinoIcons.map_pin_ellipse,
        Color(0xFF00BFF3)),
    _ChucNang('Phương tiện', CupertinoIcons.bus, Color(0xFF9C27B0)),
    _ChucNang(
        'Tài xế',
        CupertinoIcons.person_crop_circle_badge_checkmark,
        Color(0xFF00BCD4)),
    _ChucNang(
        'Đơn đặt vé', CupertinoIcons.ticket_fill, Color(0xFFFF9800)),
    _ChucNang('Thanh toán', CupertinoIcons.creditcard_fill,
        Color(0xFF4CAF50)),
    _ChucNang(
        'Báo cáo', CupertinoIcons.chart_bar_fill, Color(0xFFF44336)),
    _ChucNang(
        'Người dùng', CupertinoIcons.person_2_fill, Color(0xFFE91E63)),
    _ChucNang(
        'Khuyến mãi', CupertinoIcons.gift_fill, Color(0xFF8BC34A)),
    _ChucNang('Hỗ trợ KH', CupertinoIcons.chat_bubble_2_fill,
        Color(0xFFFF5722)),
    _ChucNang(
        'Cấu hình', CupertinoIcons.settings_solid, Color(0xFF607D8B)),
  ];

  void _moManHinh(int idx) {
    // Ánh xạ từng ô chức năng sang màn hình quản trị tương ứng.
    final Widget dest;
    switch (idx) {
      case 0:
        dest = const QuanLiTuyen();
        break;
      case 1:
        dest = const QuanLiXe();
        break;
      case 2:
        dest = const QuanLiTaiXe();
        break;
      case 3:
        dest = const QuanLiDonVe();
        break;
      case 4:
        dest = const DoiSoatThu();
        break;
      case 5:
        dest = const BaoCao();
        break;
      case 6:
        dest = const QuanLiNguoiDung();
        break;
      case 7:
        dest = const KhuyenMaiScreen();
        break;
      case 8:
        dest = const HoTroKH();
        break;
      case 9:
        dest = const CauHinhHT();
        break;
      default:
        return;
    }
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (_) => dest))
      // Sau khi quay về dashboard thì tải lại thống kê để phản ánh thay đổi mới.
        .then((_) => _taiStats());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        automaticallyImplyLeading: false,
        middle: Text(
          'Quản trị  |  ${widget.admin.ten}',
          style: const TextStyle(color: mauTextTrang, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _taiStats,
              child: const Icon(CupertinoIcons.arrow_clockwise,
                  color: mauXanhSang, size: 18),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _dangXuat,
              child: const Text('Thoát',
                  style:
                      TextStyle(color: mauDoHong, fontSize: 14)),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─ Stats card ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: gradientChinh,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng quan hệ thống',
                        style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _dangTaiStats
                        ? const Center(
                            child: CupertinoActivityIndicator(
                                color: CupertinoColors.white))
                        : Row(
                            children: [
                              Expanded(child: _StatChip(
                                  'Doanh thu',
                                  _fTien(_doanhThu),
                                  CupertinoIcons.chart_bar_fill)),
                              const SizedBox(width: 6),
                              Expanded(child: _StatChip('Tổng vé', '$_soVe',
                                  CupertinoIcons.ticket_fill)),
                              const SizedBox(width: 6),
                              Expanded(child: _StatChip('Nhân viên', '$_soNV',
                                  CupertinoIcons.person_2_fill)),
                              const SizedBox(width: 6),
                              Expanded(child: _StatChip(
                                  'Khiếu nại',
                                  '$_soKhieuNai',
                                  CupertinoIcons.chat_bubble_2_fill)),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ─ Feature grid ─────────────────────────────
              const Text('Chức năng quản trị',
                  style: TextStyle(
                      color: mauTextTrang,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _features.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (_, i) => _CardChucNang(
                  chucNang: _features[i],
                  onTap: () => _moManHinh(i),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data & widgets ───────────────────────────────────────────────

class _ChucNang {
  final String ten;
  final IconData icon;
  final Color mau;
  const _ChucNang(this.ten, this.icon, this.mau);
}

class _CardChucNang extends StatelessWidget {
  final _ChucNang chucNang;
  final VoidCallback onTap;
  const _CardChucNang({required this.chucNang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: mauCardNen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: chucNang.mau.withAlpha(50)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: chucNang.mau.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(chucNang.icon, color: chucNang.mau, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                chucNang.ten,
                style: const TextStyle(
                    color: mauTextTrang,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String nhan;
  final String giaTri;
  final IconData icon;
  const _StatChip(this.nhan, this.giaTri, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: CupertinoColors.white, size: 16),
            const SizedBox(height: 4),
            Text(giaTri,
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            Text(nhan,
                style: TextStyle(
                    color: CupertinoColors.white.withAlpha(178),
                    fontSize: 9)),
          ],
        ),
      );
  }
}

// ─── Tab 0: Tổng quan ─────────────────────────────────────────────

class _TabTongQuan extends StatefulWidget {
  final Admin admin;
  const _TabTongQuan({required this.admin});

  @override
  State<_TabTongQuan> createState() => _TabTongQuanState();
}

class _TabTongQuanState extends State<_TabTongQuan> {
  bool _dangTai = true;
  int _soVeHomNay = 0;
  int _soVeDaSoat = 0;
  int _soVeHuy = 0;
  int _soVeChoDuyet = 0;
  int _soVeBoLo = 0;
  int _doanhThu = 0;
  int _soNhanVien = 0;
  String _tuyenNhieu = '—';

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  static String _homNay() {
    final n = DateTime.now();
    return '${n.day}/${n.month}/${n.year}';
  }

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    try {
      final db = CoSoDuLieu();
      final results = await Future.wait([
        db.layTatCaVe(ngay: _homNay()),
        db.layTatCaNhanVien(),
        db.layLichSuSoatTatCa(ngay: _homNay()),
      ]);
      final veHomNay = results[0] as List<Ve>;
      final nhanVien = results[1] as List<NhanVien>;
      final lichSu = results[2] as List<Map<String, dynamic>>;

      String tuyenNhieu = '—';
      if (lichSu.isNotEmpty) {
        final dem = <String, int>{};
        for (final item in lichSu) {
          final t = '${item['diemDi']} → ${item['diemDen']}';
          dem[t] = (dem[t] ?? 0) + 1;
        }
        tuyenNhieu =
            dem.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      if (!mounted) return;
      setState(() {
        _soVeHomNay = veHomNay.length;
        _soVeDaSoat =
            veHomNay.where((v) => v.trangThai == 'hoan_thanh').length;
        _soVeHuy = veHomNay.where((v) => v.trangThai == 'huy').length;
        _soVeChoDuyet = veHomNay.where((v) => v.trangThai == 'cho').length;
        _soVeBoLo = veHomNay.where((v) => v.trangThai == 'bo_lo').length;
        _doanhThu = veHomNay
            .where((v) => v.trangThai == 'hoan_thanh')
            .fold(0, (s, v) => s + v.tongTien);
        _soNhanVien = nhanVien.length;
        _tuyenNhieu = tuyenNhieu;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  String _dinhDangTien(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '$kqđ';
  }

  @override
  Widget build(BuildContext context) {
    if (_dangTai) {
      return const Center(
          child: CupertinoActivityIndicator(
              radius: 16, color: mauXanhSang));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng quan',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Hôm nay, ${_homNay()}',
                    style:
                        const TextStyle(color: mauTextXam, fontSize: 13)),
              ],
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _taiDuLieu,
              child: const Icon(CupertinoIcons.arrow_clockwise,
                  color: mauXanhSang, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Doanh thu card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradientChinh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.money_dollar_circle_fill,
                      color: Color(0xB3FFFFFF), size: 18),
                  SizedBox(width: 6),
                  Text('Doanh thu hôm nay',
                      style: TextStyle(
                          color: Color(0xB3FFFFFF), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _dinhDangTien(_doanhThu),
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipSo(so: _soVeDaSoat, nhan: 'Hoàn thành', mau: const Color(0xFF00C853)),
                  _ChipSo(so: _soVeChoDuyet, nhan: 'Chờ', mau: mauCam),
                  _ChipSo(so: _soVeBoLo, nhan: 'Bỏ lỡ', mau: const Color(0xFFFF9800)),
                  _ChipSo(so: _soVeHuy, nhan: 'Đã hủy', mau: mauDoHong),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Lưới 4 card
        _LuoiCard(children: [
          _CardThongKe(
            icon: CupertinoIcons.ticket_fill,
            mau: mauXanhSang,
            so: '$_soVeHomNay',
            nhan: 'Vé bán hôm nay',
          ),
          _CardThongKe(
            icon: CupertinoIcons.checkmark_seal_fill,
            mau: const Color(0xFF00C853),
            so: '$_soVeDaSoat',
            nhan: 'Đã soát xong',
          ),
          _CardThongKe(
            icon: CupertinoIcons.person_2_fill,
            mau: const Color(0xFF9C27B0),
            so: '$_soNhanVien',
            nhan: 'Nhân viên',
          ),
          _CardThongKe(
            icon: CupertinoIcons.map_fill,
            mau: const Color(0xFFFF9800),
            so: '',
            nhan: _tuyenNhieu,
            tieuDe: 'Tuyến nhiều nhất',
          ),
        ]),
      ],
    );
  }
}

// ─── Tab 1: Danh sách vé ─────────────────────────────────────────

class _TabDanhSachVe extends StatefulWidget {
  const _TabDanhSachVe();

  @override
  State<_TabDanhSachVe> createState() => _TabDanhSachVeState();
}

class _TabDanhSachVeState extends State<_TabDanhSachVe> {
  bool _dangTai = true;
  List<Ve> _danhSach = [];
  String _locTrang = 'tat_ca';
  DateTime _ngay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  String get _ngayStr =>
      '${_ngay.day}/${_ngay.month}/${_ngay.year}';

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaVe(ngay: _ngayStr);
      if (!mounted) return;
      setState(() {
        _danhSach = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  List<Ve> get _veHienThi {
    if (_locTrang == 'tat_ca') return _danhSach;
    return _danhSach.where((v) => v.trangThai == _locTrang).toList();
  }

  Color _mauTrangThai(String t) {
    switch (t) {
      case 'cho':
        return mauCam;
      case 'hoan_thanh':
        return const Color(0xFF00C853);
      case 'bo_lo':
        return const Color(0xFFFF9800);
      case 'huy':
        return mauDoHong;
      default:
        return mauTextXam;
    }
  }

  String _tenTrangThai(String t) {
    switch (t) {
      case 'cho':
        return 'Chờ';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'bo_lo':
        return 'Bỏ lỡ';
      case 'huy':
        return 'Đã hủy';
      default:
        return t;
    }
  }

  String _dinhDangTien(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '$kqđ';
  }

  @override
  Widget build(BuildContext context) {
    final locItems = [
      ['tat_ca', 'Tất cả'],
      ['cho', 'Đang chờ'],
      ['hoan_thanh', 'Hoàn thành'],
      ['bo_lo', 'Bỏ lỡ'],
      ['huy', 'Đã hủy'],
    ];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: mauNenToi2,
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  DateTime tg = _ngay;
                  await showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                      height: 280,
                      color: mauCardNen,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: _ngay,
                              maximumDate:
                                  DateTime.now().add(const Duration(days: 60)),
                              minimumDate: DateTime(2025),
                              onDateTimeChanged: (d) => tg = d,
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () {
                              setState(() => _ngay = tg);
                              Navigator.of(context, rootNavigator: true)
                                  .pop();
                              _taiDuLieu();
                            },
                            child: const Text('Áp dụng'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        color: mauXanhSang, size: 16),
                    const SizedBox(width: 6),
                    Text(_ngayStr,
                        style: const TextStyle(
                            color: mauXanhSang, fontSize: 14)),
                    const Icon(CupertinoIcons.chevron_down,
                        color: mauXanhSang, size: 12),
                  ],
                ),
              ),
              const Spacer(),
              Text('${_veHienThi.length} vé',
                  style:
                      const TextStyle(color: mauTextXam, fontSize: 13)),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _taiDuLieu,
                child: const Icon(CupertinoIcons.arrow_clockwise,
                    color: mauXanhSang, size: 18),
              ),
            ],
          ),
        ),
        // Filter chips
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: locItems.map((item) {
              final active = _locTrang == item[0];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _locTrang = item[0]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? mauXanhChinh.withAlpha(50)
                          : mauCardNen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active ? mauXanhSang : mauCardVien),
                    ),
                    child: Text(item[1],
                        style: TextStyle(
                            color: active ? mauXanhSang : mauTextXam,
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // List
        Expanded(
          child: _dangTai
              ? const Center(
                  child: CupertinoActivityIndicator(
                      radius: 14, color: mauXanhSang))
              : _veHienThi.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.doc_plaintext,
                              color: mauTextXam, size: 48),
                          SizedBox(height: 12),
                          Text('Không có vé nào',
                              style: TextStyle(color: mauTextXam)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _veHienThi.length,
                      itemBuilder: (_, i) {
                        final ve = _veHienThi[i];
                        final mau = _mauTrangThai(ve.trangThai);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: mau.withAlpha(60)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(ve.maVe,
                                      style: const TextStyle(
                                          color: mauXanhSang,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const Spacer(),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: mau.withAlpha(40),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                        _tenTrangThai(ve.trangThai),
                                        style: TextStyle(
                                            color: mau,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                  '${ve.diemDi} → ${ve.diemDen}',
                                  style: const TextStyle(
                                      color: mauTextTrang,
                                      fontSize: 13)),
                              Text(
                                  '${ve.ngay}  ${ve.gio}  •  Ghế: ${(ve.danhSachGheParsed..sort()).join(', ')}',
                                  style: const TextStyle(
                                      color: mauTextXam, fontSize: 12)),
                              Text(
                                  _dinhDangTien(ve.tongTien),
                                  style: const TextStyle(
                                      color: mauTextXam, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ─── Tab 2: Nhân viên ────────────────────────────────────────────

class _TabNhanVien extends StatefulWidget {
  const _TabNhanVien();

  @override
  State<_TabNhanVien> createState() => _TabNhanVienState();
}

class _TabNhanVienState extends State<_TabNhanVien> {
  bool _dangTai = true;
  List<NhanVien> _danhSach = [];

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaNhanVien();
      if (!mounted) return;
      setState(() {
        _danhSach = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  void _themNhanVien() {
    final tenCtrl = TextEditingController();
    final maNVCtrl = TextEditingController();
    final mkCtrl = TextEditingController();
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
            color: mauCardNen,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
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
                    Icon(CupertinoIcons.person_badge_plus,
                        color: mauXanhSang, size: 20),
                    SizedBox(width: 8),
                    Text('Thêm nhân viên',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _ONhapMini(
                    ctrl: tenCtrl,
                    placeholder: 'Họ tên nhân viên'),
                const SizedBox(height: 10),
                _ONhapMini(
                    ctrl: maNVCtrl,
                    placeholder: 'Mã nhân viên (VD: nv02)'),
                const SizedBox(height: 10),
                _ONhapMini(
                    ctrl: mkCtrl,
                    placeholder: 'Mật khẩu (tối thiểu 6 ký tự)'),
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!,
                      style: const TextStyle(
                          color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                NutGradient(
                  nhanDe: 'Thêm nhân viên',
                  bieuTuong: CupertinoIcons.checkmark_circle_fill,
                  chieuRong: double.infinity,
                  onNhan: () async {
                    final ten = tenCtrl.text.trim();
                    final ma = maNVCtrl.text.trim();
                    final mk = mkCtrl.text;
                    if (ten.isEmpty || ma.isEmpty || mk.isEmpty) {
                      setModal(
                          () => loi = 'Vui lòng nhập đầy đủ thông tin');
                      return;
                    }
                    if (mk.length < 6) {
                      setModal(() =>
                          loi = 'Mật khẩu phải có ít nhất 6 ký tự');
                      return;
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                    await CoSoDuLieu()
                        .taoNhanVien(ten: ten, maNV: ma, matKhau: mk);
                    _taiDuLieu();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _xoaNhanVien(NhanVien nv) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Xóa nhân viên'),
        content: Text(
            'Xác nhận xóa tài khoản "${nv.ten}" (${nv.maNV})?\n\nLịch sử soát vé của nhân viên này vẫn được giữ lại.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await CoSoDuLieu().xoaNhanVien(nv.id!);
              _taiDuLieu();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: mauNenToi2,
              child: Row(
                children: [
                  const Text('Danh sách nhân viên',
                      style: TextStyle(
                          color: mauTextTrang,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${_danhSach.length} người',
                      style: const TextStyle(
                          color: mauTextXam, fontSize: 13)),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _taiDuLieu,
                    child: const Icon(
                        CupertinoIcons.arrow_clockwise,
                        color: mauXanhSang,
                        size: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _dangTai
                  ? const Center(
                      child: CupertinoActivityIndicator(
                          radius: 14, color: mauXanhSang))
                  : _danhSach.isEmpty
                      ? const Center(
                          child: Text('Chưa có nhân viên nào',
                              style: TextStyle(color: mauTextXam)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              16, 12, 16, 90),
                          itemCount: _danhSach.length,
                          itemBuilder: (_, i) {
                            final nv = _danhSach[i];
                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: mauCardNen,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border:
                                    Border.all(color: mauCardVien),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: gradientChinh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        nv.ten.isNotEmpty
                                            ? nv.ten[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color:
                                                CupertinoColors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(nv.ten,
                                            style: const TextStyle(
                                                color: mauTextTrang,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15)),
                                        Text('Mã NV: ${nv.maNV}',
                                            style: const TextStyle(
                                                color: mauTextXam,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () =>
                                        _xoaNhanVien(nv),
                                    child: const Icon(
                                        CupertinoIcons.trash,
                                        color: mauDoHong,
                                        size: 20),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        // FAB
        Positioned(
          bottom: 24,
          right: 20,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _themNhanVien,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradientChinh,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: mauXanhChinh.withAlpha(120),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(CupertinoIcons.add,
                  color: CupertinoColors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tab 3: Lịch sử soát vé ──────────────────────────────────────

class _TabLichSuSoat extends StatefulWidget {
  const _TabLichSuSoat();

  @override
  State<_TabLichSuSoat> createState() => _TabLichSuSoatState();
}

class _TabLichSuSoatState extends State<_TabLichSuSoat> {
  bool _dangTai = true;
  List<Map<String, dynamic>> _danhSach = [];
  String? _locNV;
  DateTime _ngay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  String get _ngayStr =>
      '${_ngay.day}/${_ngay.month}/${_ngay.year}';

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layLichSuSoatTatCa(ngay: _ngayStr);
      if (!mounted) return;
      setState(() {
        _danhSach = ds;
        _locNV = null;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  List<Map<String, dynamic>> get _hienThi {
    if (_locNV == null) return _danhSach;
    return _danhSach.where((d) => d['maNV'] == _locNV).toList();
  }

  Set<String> get _dsMaNV =>
      _danhSach.map((d) => d['maNV'] as String? ?? '').toSet();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: mauNenToi2,
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  DateTime tg = _ngay;
                  await showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                      height: 280,
                      color: mauCardNen,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: _ngay,
                              maximumDate: DateTime.now(),
                              minimumDate: DateTime(2025),
                              onDateTimeChanged: (d) => tg = d,
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () {
                              setState(() => _ngay = tg);
                              Navigator.of(context,
                                      rootNavigator: true)
                                  .pop();
                              _taiDuLieu();
                            },
                            child: const Text('Áp dụng'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        color: mauXanhSang, size: 16),
                    const SizedBox(width: 6),
                    Text(_ngayStr,
                        style: const TextStyle(
                            color: mauXanhSang, fontSize: 14)),
                    const Icon(CupertinoIcons.chevron_down,
                        color: mauXanhSang, size: 12),
                  ],
                ),
              ),
              const Spacer(),
              Text('${_hienThi.length} lần soát',
                  style:
                      const TextStyle(color: mauTextXam, fontSize: 13)),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _taiDuLieu,
                child: const Icon(CupertinoIcons.arrow_clockwise,
                    color: mauXanhSang, size: 18),
              ),
            ],
          ),
        ),
        // Filter by NV
        if (_dsMaNV.isNotEmpty)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ChipLoc(
                    nhan: 'Tất cả',
                    active: _locNV == null,
                    onTap: () => setState(() => _locNV = null),
                  ),
                ),
                ..._dsMaNV.map((m) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChipLoc(
                        nhan: m,
                        active: _locNV == m,
                        onTap: () => setState(() => _locNV = m),
                      ),
                    )),
              ],
            ),
          ),
        // List
        Expanded(
          child: _dangTai
              ? const Center(
                  child: CupertinoActivityIndicator(
                      radius: 14, color: mauXanhSang))
              : _hienThi.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.barcode_viewfinder,
                              color: mauTextXam, size: 48),
                          SizedBox(height: 12),
                          Text('Chưa có lịch sử soát vé',
                              style: TextStyle(color: mauTextXam)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _hienThi.length,
                      itemBuilder: (_, i) {
                        final item = _hienThi[i];
                        final tStr = item['thoiGian'] as String? ?? '';
                        final t = tStr.isNotEmpty
                            ? (DateTime.tryParse(tStr) ?? DateTime.now())
                            : DateTime.now();
                        final tg =
                            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                        final ghiChu =
                            item['ghiChu'] as String? ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF00C853)
                                    .withAlpha(50)),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      CupertinoIcons
                                          .checkmark_circle_fill,
                                      color: Color(0xFF00C853),
                                      size: 15),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                        item['maVe'] as String? ?? '',
                                        style: const TextStyle(
                                            color: mauXanhSang,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                  Text(
                                      'NV: ${item['maNV'] ?? ''}',
                                      style: const TextStyle(
                                          color: mauTextXam,
                                          fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Text(tg,
                                      style: const TextStyle(
                                          color: mauTextXam,
                                          fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['diemDi']} → ${item['diemDen']}  •  ${item['ngay']}  ${item['gio']}',
                                style: const TextStyle(
                                    color: mauTextTrang, fontSize: 13),
                              ),
                              if (ghiChu.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.pencil,
                                        color: Color(0xFFFF9800),
                                        size: 12),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(ghiChu,
                                          style: const TextStyle(
                                              color: Color(0xFFFF9800),
                                              fontSize: 12,
                                              fontStyle:
                                                  FontStyle.italic)),
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
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────

class _ChipSo extends StatelessWidget {
  final int so;
  final String nhan;
  final Color mau;
  const _ChipSo(
      {required this.so, required this.nhan, required this.mau});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: mau.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mau.withAlpha(120)),
      ),
      child: Text('$so $nhan',
          style: TextStyle(
              color: mau, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _LuoiCard extends StatelessWidget {
  final List<Widget> children;
  const _LuoiCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 10),
            Expanded(child: children[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: children[2]),
            const SizedBox(width: 10),
            Expanded(child: children[3]),
          ],
        ),
      ],
    );
  }
}

class _CardThongKe extends StatelessWidget {
  final IconData icon;
  final Color mau;
  final String so;
  final String nhan;
  final String? tieuDe;

  const _CardThongKe({
    required this.icon,
    required this.mau,
    required this.so,
    required this.nhan,
    this.tieuDe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mau.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: mau, size: 22),
          const SizedBox(height: 10),
          if (tieuDe != null) ...[
            Text(tieuDe!,
                style: TextStyle(color: mau, fontSize: 11)),
            const SizedBox(height: 2),
          ],
          if (so.isNotEmpty)
            Text(so,
                style: TextStyle(
                    color: mau,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
          Text(nhan,
              style:
                  const TextStyle(color: mauTextXam, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ONhapMini extends StatelessWidget {
  final TextEditingController ctrl;
  final String placeholder;
  const _ONhapMini({required this.ctrl, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: ctrl,
      placeholder: placeholder,
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
}

class _ChipLoc extends StatelessWidget {
  final String nhan;
  final bool active;
  final VoidCallback onTap;
  const _ChipLoc(
      {required this.nhan, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? mauXanhChinh.withAlpha(50) : mauCardNen,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: active ? mauXanhSang : mauCardVien),
        ),
        child: Text(nhan,
            style: TextStyle(
                color: active ? mauXanhSang : mauTextXam,
                fontSize: 12,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}


