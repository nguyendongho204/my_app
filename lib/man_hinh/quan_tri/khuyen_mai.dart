import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class KhuyenMaiScreen extends StatefulWidget {
  const KhuyenMaiScreen({super.key});
  @override
  State<KhuyenMaiScreen> createState() => _KhuyenMaiScreenState();
}

class _KhuyenMaiScreenState extends State<KhuyenMaiScreen> {
  bool _dangTai = true;
  List<KhuyenMai> _ds = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaKhuyenMai();
      if (!mounted) return;
      setState(() { _ds = ds; _dangTai = false; });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  void _them() {
    final maCtrl   = TextEditingController();
    final tenCtrl  = TextEditingController();
    final giaTriCtrl = TextEditingController();
    final toiDaCtrl  = TextEditingController();
    final bdCtrl   = TextEditingController();
    final ktCtrl   = TextEditingController();
    final gioiHanCtrl = TextEditingController();
    String loai = 'phan_tram';
    String? loi;

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
                  const Text('Thêm khuyến mãi',
                      style: TextStyle(
                          color: mauTextTrang,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _KF(ctrl: maCtrl, ph: 'Mã giảm giá (VD: GIAM50)'),
                  const SizedBox(height: 8),
                  _KF(ctrl: tenCtrl, ph: 'Tên chương trình'),
                  const SizedBox(height: 10),
                  const Text('Loại giảm giá',
                      style: TextStyle(color: mauTextXam, fontSize: 12)),
                  const SizedBox(height: 6),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: loai,
                    backgroundColor: mauNenToi,
                    children: const {
                      'phan_tram': Text('% Phần trăm',
                          style: TextStyle(fontSize: 12)),
                      'so_tien': Text('Số tiền cố định',
                          style: TextStyle(fontSize: 12)),
                    },
                    onValueChanged: (v) {
                      if (v != null) setM(() => loai = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  _KF(
                      ctrl: giaTriCtrl,
                      ph: loai == 'phan_tram'
                          ? 'Giá trị giảm (VD: 20 = 20%)'
                          : 'Số tiền giảm (VNĐ)',
                      kiboard: TextInputType.number),
                  const SizedBox(height: 8),
                  _KF(
                      ctrl: toiDaCtrl,
                      ph: 'Giảm tối đa (VNĐ, 0 = không giới hạn)',
                      kiboard: TextInputType.number),
                  const SizedBox(height: 8),
                  _KF(ctrl: bdCtrl, ph: 'Ngày bắt đầu (d/m/yyyy)'),
                  const SizedBox(height: 8),
                  _KF(ctrl: ktCtrl, ph: 'Ngày kết thúc (d/m/yyyy)'),
                  const SizedBox(height: 8),
                  _KF(
                      ctrl: gioiHanCtrl,
                      ph: 'Giới hạn lượt dùng (0 = không giới hạn)',
                      kiboard: TextInputType.number),
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
                        final ma = maCtrl.text.trim().toUpperCase();
                        final ten = tenCtrl.text.trim();
                        final gt = int.tryParse(giaTriCtrl.text.trim()) ?? 0;
                        if (ma.isEmpty || ten.isEmpty || gt == 0) {
                          setM(() => loi = 'Vui lòng điền đầy đủ thông tin');
                          return;
                        }
                        Navigator.of(context, rootNavigator: true).pop();
                        await CoSoDuLieu().taoKhuyenMai(KhuyenMai(
                          ma: ma, ten: ten, loaiGiam: loai,
                          giaTriGiam: gt,
                          giaTriToiDa: int.tryParse(toiDaCtrl.text.trim()) ?? 0,
                          ngayBatDau: bdCtrl.text.trim(),
                          ngayKetThuc: ktCtrl.text.trim(),
                          gioiHanSuDung: int.tryParse(gioiHanCtrl.text.trim()) ?? 0,
                          daSuDung: 0,
                          trangThai: 'hoat_dong',
                        ));
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

  Color _mau(String tt) {
    switch (tt) {
      case 'hoat_dong':  return const Color(0xFF00C853);
      case 'tam_dung':   return const Color(0xFFFF9800);
      default:           return mauDoHong;
    }
  }

  String _nhan(String tt) {
    switch (tt) {
      case 'hoat_dong':  return 'Hoạt động';
      case 'tam_dung':   return 'Tạm dừng';
      default:           return 'Hết hạn';
    }
  }

  String _loaiNhan(String l, int gt) =>
      l == 'phan_tram' ? '-$gt%' : '-${_f(gt)}';

  String _f(int t) {
    final s = t.toString();
    var r = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) r += '.';
      r += s[i];
    }
    return '${r}đ';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Khuyến mãi & Mã giảm giá',
            style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _them,
          child: const Icon(CupertinoIcons.add,
              color: mauXanhSang, size: 22),
        ),
      ),
      child: _dangTai
          ? const Center(
              child: CupertinoActivityIndicator(
                  radius: 14, color: mauXanhSang))
          : _ds.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.gift_fill,
                          color: mauTextXam, size: 48),
                      SizedBox(height: 12),
                      Text('Chưa có khuyến mãi nào',
                          style: TextStyle(color: mauTextXam)),
                    ],
                  ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ds.length,
                  itemBuilder: (_, i) {
                    final km = _ds[i];
                    final mau = _mau(km.trangThai);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: mau.withAlpha(60)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: gradientChinh,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(km.ma,
                                    style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(km.ten,
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontSize: 14)),
                              ),
                              _Badg(_nhan(km.trangThai), mau),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                    color: mauDoHong.withAlpha(30),
                                    borderRadius:
                                        BorderRadius.circular(6)),
                                child: Text(
                                    _loaiNhan(
                                        km.loaiGiam, km.giaTriGiam),
                                    style: const TextStyle(
                                        color: mauDoHong,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  '${km.daSuDung}/${km.gioiHanSuDung == 0 ? '∞' : km.gioiHanSuDung} lượt',
                                  style: const TextStyle(
                                      color: mauTextXam,
                                      fontSize: 12)),
                              const SizedBox(width: 8),
                              if (km.ngayKetThuc.isNotEmpty)
                                Text('HSD: ${km.ngayKetThuc}',
                                    style: const TextStyle(
                                        color: mauTextXamNhat,
                                        fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  final next =
                                      km.trangThai == 'hoat_dong'
                                          ? 'tam_dung'
                                          : 'hoat_dong';
                                  await CoSoDuLieu()
                                      .capNhatTrangThaiKhuyenMai(
                                          km.id!, next);
                                  _tai();
                                },
                                child: Text(
                                  km.trangThai == 'hoat_dong'
                                      ? 'Tạm dừng'
                                      : 'Kích hoạt',
                                  style: TextStyle(
                                      color: km.trangThai ==
                                              'hoat_dong'
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFF00C853),
                                      fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await CoSoDuLieu()
                                      .xoaKhuyenMai(km.id!);
                                  _tai();
                                },
                                child: const Icon(
                                    CupertinoIcons.trash,
                                    color: mauDoHong,
                                    size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _KF extends StatelessWidget {
  final TextEditingController ctrl;
  final String ph;
  final TextInputType? kiboard;
  const _KF({required this.ctrl, required this.ph, this.kiboard});

  @override
  Widget build(BuildContext context) => CupertinoTextField(
        controller: ctrl,
        placeholder: ph,
        keyboardType: kiboard,
        placeholderStyle:
            const TextStyle(color: mauTextXam, fontSize: 13),
        style:
            const TextStyle(color: mauTextTrang, fontSize: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mauNenToi,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: mauCardVien),
        ),
      );
}

class _Badg extends StatelessWidget {
  final String nhan;
  final Color mau;
  const _Badg(this.nhan, this.mau);

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
