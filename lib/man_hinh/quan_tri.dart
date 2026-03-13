import 'package:flutter/cupertino.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';
import 'quan_tri/quan_li_tuyen.dart';
import 'quan_tri/quan_li_xe.dart';
import 'quan_tri/quan_li_tai_xe.dart';
import 'quan_tri/quan_li_don_ve.dart';
import 'quan_tri/doi_soat_thu.dart';
import 'quan_tri/bao_cao.dart';
import 'quan_tri/quan_li_nguoi_dung.dart';
import 'quan_tri/khuyen_mai.dart';
import 'quan_tri/ho_tro_kh.dart';
import 'quan_tri/cau_hinh.dart';

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
    return '${t}đ';
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
