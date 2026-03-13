import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';
import 'tim_tuyen_xe.dart';
import 've_cua_toi.dart';
import 'tai_khoan.dart';
import 'ket_qua_tuyen.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  late final CupertinoTabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CupertinoTabController();
    DieuHuongTab.controller = _ctrl;
  }

  @override
  void dispose() {
    DieuHuongTab.controller = null;
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _ctrl,
      backgroundColor: mauThanhDieuHuong,
      tabBar: CupertinoTabBar(
        backgroundColor: mauThanhDieuHuong,
        activeColor: mauXanhSang,
        inactiveColor: mauTextXam,
        border: const Border(
          top: BorderSide(color: mauCardVien, width: 0.5),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search),
            label: 'Tìm tuyến',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ticket),
            activeIcon: Icon(CupertinoIcons.ticket_fill),
            label: 'Vé của tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Tài khoản',
          ),
        ],
      ),
      tabBuilder: (ctx, idx) {
        switch (idx) {
          case 0:
            return CupertinoTabView(
              builder: (_) => ManHinhTrangChu(
                onTimTuyen: () => _ctrl.index = 1,
              ),
            );
          case 1:
            return CupertinoTabView(builder: (_) => const TimTuyenXe());
          case 2:
            return CupertinoTabView(builder: (_) => const VeCuaToi());
          case 3:
          default:
            return CupertinoTabView(builder: (_) => const TaiKhoan());
        }
      },
    );
  }
}

enum _LoaiNhac { sapKhoiHanh, boLo }

class ManHinhTrangChu extends StatefulWidget {
  final VoidCallback onTimTuyen;
  const ManHinhTrangChu({super.key, required this.onTimTuyen});

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

class _ManHinhTrangChuState extends State<ManHinhTrangChu>
    with SingleTickerProviderStateMixin {
  late AnimationController _hieuUngHien;
  late Animation<double> _doMo;
  Timer? _timerNhacNho;
  String _thongBaoHeThong = '';
  // Set lưu id vé đã hiện thông báo để tránh hiện lại trong cùng phiên
  final Set<String> _daNhacVeId = {};

  @override
  void initState() {
    super.initState();
    _hieuUngHien = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _doMo = CurvedAnimation(parent: _hieuUngHien, curve: Curves.easeIn);
    // Kiểm tra nhắc nhở sau khi widget được gắn vào cây
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kiemTraNhacNho();
      _taiThongBaoHeThong();
    });
    // Kiểm tra lại mỗi 1 phút để bắt đúng khoảng giờ nhắc
    _timerNhacNho = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _kiemTraNhacNho(),
    );
    TrangThaiUngDung().addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
    _kiemTraNhacNho();
  }

  @override
  void dispose() {
    _timerNhacNho?.cancel();
    TrangThaiUngDung().removeListener(_onStateChange);
    _hieuUngHien.dispose();
    super.dispose();
  }

  Future<void> _taiThongBaoHeThong() async {
    try {
      final cfg = await CoSoDuLieu().layCauHinh();
      if (!mounted) return;
      setState(() {
        _thongBaoHeThong =
            (cfg['thong_bao_he_thong'] as String?)?.trim() ?? '';
      });
    } catch (_) {}
  }

  void _kiemTraNhacNho() {
    if (!TrangThaiUngDung().daDangNhap) return;
    final now = DateTime.now();

    for (final ve in TrangThaiUngDung().danhSachVe) {
      if (ve.id == null || ve.trangThai != 'cho') continue;
      final kh = CoSoDuLieu.parseGioKhoiHanh(ve.ngay, ve.gio);
      if (kh == null) continue;
      final diffPhut = kh.difference(now).inMinutes;

      // Chưa đến giờ: nhắc khi còn ≤ 60 phút
      if (diffPhut > 0 && diffPhut <= 60) {
        final key = '${ve.id}_sap';
        if (!_daNhacVeId.contains(key)) {
          _daNhacVeId.add(key);
          _hienThiNhacNho(ve, loai: _LoaiNhac.sapKhoiHanh);
          break;
        }
      }

      // Đã qua giờ khởi hành (trong vòng 4 giờ): nhắc bỏ lỡ
      if (diffPhut < 0 && diffPhut >= -240) {
        final key = '${ve.id}_bolo';
        if (!_daNhacVeId.contains(key)) {
          _daNhacVeId.add(key);
          _hienThiNhacNho(ve, loai: _LoaiNhac.boLo);
          break;
        }
      }
    }
  }

  void _hienThiNhacNho(Ve ve, {required _LoaiNhac loai}) {
    if (!mounted) return;
    final bool laBoLo = loai == _LoaiNhac.boLo;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              laBoLo ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.bus,
              color: laBoLo ? mauDoHong : mauXanhSang,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              laBoLo ? '⚠️ Bạn đã bỏ lỡ chuyến này!' : '🚌 Chạy rồi! Chuyến xe sắp đi',
              style: TextStyle(
                  color: laBoLo ? mauDoHong : mauCam, fontSize: 15),
            ),
          ],
        ),
        content: Text(
          laBoLo
              ? 'Chuyến ${ve.diemDi} → ${ve.diemDen}\nlúc ${ve.gio} ngày ${ve.ngay}\nđã khởi hành nhưng không có bạn.\nVé: ${ve.maVe}'
              : 'Bạn có chuyến ${ve.diemDi} → ${ve.diemDen}\nlúc ${ve.gio} ngày ${ve.ngay}\nMã vé: ${ve.maVe}',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Đã biết'),
          ),
          if (!laBoLo)
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                DieuHuongTab.controller?.index = 2;
              },
              child: const Text('Xem vé'),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _danhSachThongBao {
    final dsVe = TrangThaiUngDung().danhSachVe;
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> result = [];
    for (final ve in dsVe) {
      try {
        if (ve.trangThai == 'huy') {
          result.add({
            'icon': CupertinoIcons.xmark_circle_fill,
            'mau': mauDoHong,
            'tieu_de': 'Vé ${ve.maVe} đã hủy',
            'noi_dung': '${ve.diemDi} → ${ve.diemDen}, ${ve.ngay} ${ve.gio}',
          });
          continue;
        }
        if (ve.trangThai == 'bo_lo') {
          result.add({
            'icon': CupertinoIcons.exclamationmark_triangle_fill,
            'mau': mauDoHong,
            'tieu_de': '⚠️ Bỏ lỡ chuyến lúc ${ve.gio} ngày ${ve.ngay}',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
          continue;
        }
        // Chỉ xử lý vé đang 'cho'
        final kh = CoSoDuLieu.parseGioKhoiHanh(ve.ngay, ve.gio);
        if (kh == null) continue;
        final diffPhut = kh.difference(now).inMinutes;
        final diffNgay = DateTime(kh.year, kh.month, kh.day)
            .difference(homNay)
            .inDays;

        if (diffPhut < 0 && diffPhut >= -240) {
          // Đã qua giờ, chưa xác nhận lên xe
          result.add({
            'icon': CupertinoIcons.exclamationmark_circle_fill,
            'mau': mauCam,
            'tieu_de': '⚠️ Chưa xác nhận lên xe ${ve.gio}',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diffPhut > 0 && diffPhut <= 60) {
          result.add({
            'icon': CupertinoIcons.alarm_fill,
            'mau': mauCam,
            'tieu_de': '🚌 Sắp khởi hành lúc ${ve.gio} hôm nay!',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diffNgay == 0) {
          result.add({
            'icon': CupertinoIcons.alarm_fill,
            'mau': mauCam,
            'tieu_de': '⏰ Chuyến hôm nay lúc ${ve.gio}',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diffNgay == 1) {
          result.add({
            'icon': CupertinoIcons.clock_fill,
            'mau': mauXanhSang,
            'tieu_de': 'Chuyến ngày mai lúc ${ve.gio}',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diffNgay > 1 && diffNgay <= 7) {
          result.add({
            'icon': CupertinoIcons.checkmark_seal_fill,
            'mau': mauXanhSang,
            'tieu_de': 'Đặt vé thành công',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}, ${ve.ngay} ${ve.gio}',
          });
        }
      } catch (_) {}
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: gradientNen),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: ShaderMask(
              shaderCallback: (b) => gradientChinh.createShader(b),
              child: const Text(
                'BookBus Cần Thơ',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
            backgroundColor: CupertinoColors.transparent,
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: gradientChinh,
                    ),
                    child: const Icon(CupertinoIcons.bell,
                        color: CupertinoColors.white, size: 18),
                  ),
                  if (_danhSachThongBao.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: mauDoHong,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_danhSachThongBao.length > 9 ? '9+' : _danhSachThongBao.length}',
                            style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                final tbs = _danhSachThongBao;
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                    height: 460,
                    color: mauCardNen,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Thông báo',
                                  style: TextStyle(
                                      color: mauTextTrang,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.of(context,
                                    rootNavigator: true).pop(),
                                child: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    color: mauTextXam),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (tbs.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.bell_slash,
                                        color: mauTextXamNhat, size: 48),
                                    SizedBox(height: 12),
                                    Text('Không có thông báo nào',
                                        style: TextStyle(
                                            color: mauTextXam, fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: tbs.length,
                                separatorBuilder: (_, __) => Container(
                                    height: 0.5,
                                    margin: const EdgeInsets.only(left: 52),
                                    color: mauCardVien),
                                itemBuilder: (_, i) {
                                  final tb = tbs[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: (tb['mau'] as Color)
                                                .withAlpha(38),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                              tb['icon'] as IconData,
                                              color: tb['mau'] as Color,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  tb['tieu_de'] as String,
                                                  style: const TextStyle(
                                                      color: mauTextTrang,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              const SizedBox(height: 3),
                                              Text(
                                                  tb['noi_dung'] as String,
                                                  style: const TextStyle(
                                                      color: mauTextXam,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _doMo,
              child: Column(
                children: [
                  if (_thongBaoHeThong.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFF9800).withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.exclamationmark_circle_fill,
                                color: Color(0xFFFF9800), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _thongBaoHeThong,
                                style: const TextStyle(
                                    color: Color(0xFFFF9800),
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _TimNhanhHome(onTap: widget.onTimTuyen),
                  const SizedBox(height: 28),
                  _KhuVucTrungTam(onTap: widget.onTimTuyen),
                  const SizedBox(height: 32),
                  _TuyenPhoBien(
                    onChon: (di, den) => Navigator.of(
                      context,
                      rootNavigator: true,
                    ).push(
                      CupertinoPageRoute(
                        builder: (_) => KetQuaTuyen(
                          diemDi: di,
                          diemDen: den,
                          ngay: DateTime.now(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimNhanhHome extends StatelessWidget {
  final VoidCallback onTap;
  const _TimNhanhHome({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauCardVien),
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.search, color: mauTextXamNhat, size: 18),
              SizedBox(width: 10),
              Text(
                'Bạn muốn đi đâu?',
                style: TextStyle(color: mauTextXamNhat, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KhuVucTrungTam extends StatelessWidget {
  final VoidCallback onTap;
  const _KhuVucTrungTam({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: VongTronPulse(
              kichThuoc: 130,
              mauGradient: const [Color(0xFF1565C0), Color(0xFF6A1B9A)],
              noiDungTrungTam: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bus,
                      color: CupertinoColors.white, size: 38),
                  SizedBox(height: 4),
                  Text(
                    'ĐẶT VÉ',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nhấn để tìm chuyến xe',
            style: TextStyle(color: mauTextXam, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TuyenPhoBien extends StatelessWidget {
  static const _danhSach = [
    {'di': 'BX Ninh Kiều', 'den': 'BX Bình Thủy', 'gio': '06:00', 'gia': '15.000đ', 'xe': 'Xe buýt số 01'},
    {'di': 'BX Ninh Kiều', 'den': 'BX Cái Răng', 'gio': '06:30', 'gia': '12.000đ', 'xe': 'Xe buýt số 03'},
    {'di': 'BX Ô Môn', 'den': 'BX Ninh Kiều', 'gio': '07:00', 'gia': '18.000đ', 'xe': 'Xe buýt số 05'},
  ];

  final void Function(String di, String den) onChon;
  const _TuyenPhoBien({required this.onChon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tuyến phổ biến',
            style: TextStyle(
              color: mauTextTrang,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...(_danhSach.map(
          (t) => CardTuyenXe(
            diemDi: t['di']!,
            diemDen: t['den']!,
            gioKhoiHanh: t['gio']!,
            gia: t['gia']!,
            loaiXe: t['xe']!,
            onNhan: () => onChon(t['di']!, t['den']!),
          ),
        )),
      ],
    );
  }
}
