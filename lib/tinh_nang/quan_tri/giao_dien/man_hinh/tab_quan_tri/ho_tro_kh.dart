import 'package:flutter/cupertino.dart';
import '../../../../../cau_hinh/hang_so.dart';
import '../../../../../du_lieu/co_so_du_lieu.dart';

class HoTroKH extends StatefulWidget {
  const HoTroKH({super.key});
  @override
  State<HoTroKH> createState() => _HoTroKHState();
}

class _HoTroKHState extends State<HoTroKH> {
  bool _dangTai = true;
  List<KhieuNai> _ds = [];
  String _loc = 'tat_ca';

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      // Tải toàn bộ khiếu nại để lọc theo trạng thái tại client.
      final ds = await CoSoDuLieu().layTatCaKhieuNai();
      if (!mounted) return;
      setState(() { _ds = ds; _dangTai = false; });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  List<KhieuNai> get _dsLoc {
    if (_loc == 'tat_ca') return _ds;
    return _ds.where((k) => k.trangThai == _loc).toList();
  }

  void _xemChiTiet(KhieuNai kn) {
    final phanHoiCtrl = TextEditingController(text: kn.phanHoi);
    bool dangGui = false;

    // Khi admin mở chi tiết, tự chuyển "chờ xử lý" -> "đang xử lý" để phản ánh tiến trình.
    if (kn.trangThai == 'cho_xu_ly') {
      CoSoDuLieu().capNhatTrangThaiKhieuNai(kn.id!, 'dang_xu_ly').then((_) {
        // Reload để đồng bộ badge và danh sách sau thay đổi trạng thái.
        final idx = _ds.indexWhere((k) => k.id == kn.id);
        if (idx >= 0 && mounted) {
          setState(() {
            // Rebuild sẽ lấy lại từ list đã cập nhật
          });
        }
        _tai(); // Reload để cập nhật badge số đếm trong dashboard
      });
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setM) => Container(
          decoration: const BoxDecoration(
              color: mauCardNen,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(kn.tieuDe,
                            style: const TextStyle(
                                color: mauTextTrang,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ),
                      _Bx(_nhanTT(kn.trangThai), _mauTT(kn.trangThai)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DRow('Khách hàng', kn.tenKhachHang),
                  _DRow('Mã vé', kn.maVe.isEmpty ? 'Không có' : kn.maVe),
                  _DRow('Ngày tạo', kn.ngayTao),
                  const SizedBox(height: 12),
                  const Text('Nội dung khiếu nại:',
                      style: TextStyle(
                          color: mauTextXam,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: mauNenToi,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mauCardVien)),
                    child: Text(kn.noiDung,
                        style: const TextStyle(
                            color: mauTextTrang, fontSize: 14)),
                  ),
                  const SizedBox(height: 14),
                  if (kn.trangThai != 'da_xu_ly') ...[
                    const Text('Phản hồi của admin:',
                        style: TextStyle(
                            color: mauTextXam,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: phanHoiCtrl,
                      placeholder: 'Nhập nội dung phản hồi...',
                      placeholderStyle: const TextStyle(
                          color: mauTextXam, fontSize: 13),
                      style: const TextStyle(
                          color: mauTextTrang, fontSize: 14),
                      padding: const EdgeInsets.all(12),
                      maxLines: 4,
                      minLines: 3,
                      decoration: BoxDecoration(
                        color: mauNenToi,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mauCardVien),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: dangGui
                            ? null
                            : () async {
                                final ph = phanHoiCtrl.text.trim();
                                if (ph.isEmpty) return;
                                setM(() => dangGui = true);
                                await CoSoDuLieu().phanHoiKhieuNai(kn.id!, ph);
                                if (mounted) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  _tai();
                                }
                              },
                        child: dangGui
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white)
                            : const Text('Gửi phản hồi'),
                      ),
                    ),
                  ] else ...[
                    const Text('Phản hồi đã gửi:',
                        style: TextStyle(
                            color: mauTextXam,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF00C853)
                                  .withAlpha(60))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kn.phanHoi,
                              style: const TextStyle(
                                  color: mauTextTrang, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(kn.ngayPhanHoi,
                              style: const TextStyle(
                                  color: mauTextXamNhat,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _mauTT(String tt) {
    switch (tt) {
      case 'cho_xu_ly':    return mauCam;
      case 'dang_xu_ly':   return mauXanhSang;
      case 'da_xu_ly':     return const Color(0xFF00C853);
      default:             return mauTextXam;
    }
  }

  String _nhanTT(String tt) {
    switch (tt) {
      case 'cho_xu_ly':    return 'Chờ xử lý';
      case 'dang_xu_ly':   return 'Đang xử lý';
      case 'da_xu_ly':     return 'Đã xử lý';
      default:             return tt;
    }
  }

  static const _chips = [
    ('tat_ca', 'Tất cả'),
    ('cho_xu_ly', 'Chờ xử lý'),
    ('dang_xu_ly', 'Đang xử lý'),
    ('da_xu_ly', 'Đã xử lý'),
  ];

  @override
  Widget build(BuildContext context) {
    final dsDien = _dsLoc;
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Hỗ trợ & Khiếu nại',
            style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _tai,
          child: const Icon(CupertinoIcons.arrow_clockwise,
              color: mauXanhSang, size: 18),
        ),
      ),
      child: Column(
        children: [
          // Filter chips
          Container(
            color: mauNenToi2,
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 10),
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _chips.map((c) {
                final sel = _loc == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _loc = c.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? mauXanhChinh.withAlpha(40)
                          : mauCardNen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? mauXanhSang
                              : mauCardVien),
                    ),
                    child: Text(c.$2,
                        style: TextStyle(
                            color: sel
                                ? mauXanhSang
                                : mauTextXam,
                            fontSize: 13,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _dangTai
                ? const Center(
                    child: CupertinoActivityIndicator(
                        radius: 14, color: mauXanhSang))
                : dsDien.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                                CupertinoIcons
                                    .chat_bubble_2_fill,
                                color: mauTextXam,
                                size: 48),
                            SizedBox(height: 12),
                            Text('Không có khiếu nại nào',
                                style: TextStyle(
                                    color: mauTextXam)),
                          ],
                        ))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dsDien.length,
                        itemBuilder: (_, i) {
                          final kn = dsDien[i];
                          final mau = _mauTT(kn.trangThai);
                          return GestureDetector(
                            onTap: () => _xemChiTiet(kn),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10),
                              padding:
                                  const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: mauCardNen,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: mau.withAlpha(50)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 56,
                                    decoration: BoxDecoration(
                                        color: mau,
                                        borderRadius:
                                            BorderRadius
                                                .circular(2)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                kn.tieuDe,
                                                style: const TextStyle(
                                                    color:
                                                        mauTextTrang,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                    fontSize:
                                                        14),
                                              ),
                                            ),
                                            _Bx(_nhanTT(
                                                    kn.trangThai),
                                                mau),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            kn.tenKhachHang,
                                            style: const TextStyle(
                                                color: mauTextXam,
                                                fontSize: 12)),
                                        Text(kn.ngayTao,
                                            style: const TextStyle(
                                                color:
                                                    mauTextXamNhat,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                      CupertinoIcons
                                          .chevron_forward,
                                      color: mauTextXam,
                                      size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DRow extends StatelessWidget {
  final String nhan;
  final String gia;
  const _DRow(this.nhan, this.gia);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(nhan,
                  style: const TextStyle(
                      color: mauTextXam, fontSize: 13)),
            ),
            Expanded(
              child: Text(gia,
                  style: const TextStyle(
                      color: mauTextTrang,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

class _Bx extends StatelessWidget {
  final String nhan;
  final Color mau;
  const _Bx(this.nhan, this.mau);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: mau.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(nhan,
            style: TextStyle(
                color: mau,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}
