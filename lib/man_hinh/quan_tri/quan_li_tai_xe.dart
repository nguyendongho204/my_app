import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class QuanLiTaiXe extends StatefulWidget {
  const QuanLiTaiXe({super.key});
  @override
  State<QuanLiTaiXe> createState() => _QuanLiTaiXeState();
}

class _QuanLiTaiXeState extends State<QuanLiTaiXe> {
  bool _dangTai = true;
  List<TaiXe> _ds = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaTaiXe();
      if (!mounted) return;
      setState(() {
        _ds = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  void _sua(TaiXe tx) {
    final tenCtrl = TextEditingController(text: tx.ten);
    final sdtCtrl = TextEditingController(text: tx.sdt);
    final gplxCtrl = TextEditingController(text: tx.soGPLX);
    final nsCtrl = TextEditingController(text: tx.ngaySinh);
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setM) => Container(
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
                const Row(children: [
                  Icon(CupertinoIcons.pencil, color: mauXanhSang, size: 20),
                  SizedBox(width: 8),
                  Text('Sửa hồ sơ tài xế',
                      style: TextStyle(
                          color: mauTextTrang, fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                _Fld(ctrl: tenCtrl, ph: 'Họ và tên'),
                const SizedBox(height: 10),
                _Fld(ctrl: sdtCtrl, ph: 'Số điện thoại', kb: TextInputType.phone),
                const SizedBox(height: 10),
                _Fld(ctrl: gplxCtrl, ph: 'Số GPLX'),
                const SizedBox(height: 10),
                _Fld(ctrl: nsCtrl, ph: 'Ngày sinh (d/m/yyyy)'),
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!, style: const TextStyle(color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () async {
                      final ten = tenCtrl.text.trim();
                      final sdt = sdtCtrl.text.trim();
                      final gplx = gplxCtrl.text.trim();
                      if (ten.isEmpty || sdt.isEmpty || gplx.isEmpty) {
                        setM(() => loi = 'Vui lòng nhập đầy đủ thông tin');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().capNhatTaiXe(tx.id!, {
                        'ten': ten, 'sdt': sdt,
                        'soGPLX': gplx, 'ngaySinh': nsCtrl.text.trim(),
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
    );
  }

  void _them() {
    final tenCtrl = TextEditingController();
    final sdtCtrl = TextEditingController();
    final gplxCtrl = TextEditingController();
    final nsSinhCtrl = TextEditingController();
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setM) => Container(
          decoration: const BoxDecoration(
            color: mauCardNen,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
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
                const Row(
                  children: [
                    Icon(CupertinoIcons.person_crop_circle_badge_checkmark,
                        color: mauXanhSang, size: 20),
                    SizedBox(width: 8),
                    Text('Thêm tài xế',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _Fld(ctrl: tenCtrl, ph: 'Họ và tên'),
                const SizedBox(height: 10),
                _Fld(
                    ctrl: sdtCtrl,
                    ph: 'Số điện thoại',
                    kb: TextInputType.phone),
                const SizedBox(height: 10),
                _Fld(ctrl: gplxCtrl, ph: 'Số GPLX'),
                const SizedBox(height: 10),
                _Fld(ctrl: nsSinhCtrl, ph: 'Ngày sinh (d/m/yyyy)'),
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
                      final ten = tenCtrl.text.trim();
                      final sdt = sdtCtrl.text.trim();
                      final gplx = gplxCtrl.text.trim();
                      final ns = nsSinhCtrl.text.trim();
                      if (ten.isEmpty || sdt.isEmpty || gplx.isEmpty) {
                        setM(() =>
                            loi = 'Vui lòng nhập đầy đủ thông tin');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().taoTaiXe(TaiXe(
                          ten: ten,
                          sdt: sdt,
                          soGPLX: gplx,
                          ngaySinh: ns,
                          trangThai: 'san_sang'));
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Tài xế & Nhân sự',
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
              onPressed: _them,
              child: const Icon(CupertinoIcons.add,
                  color: mauXanhSang, size: 22),
            ),
          ],
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
                      Icon(CupertinoIcons.person_2,
                          color: mauTextXam, size: 48),
                      SizedBox(height: 12),
                      Text('Chưa có tài xế nào',
                          style: TextStyle(color: mauTextXam)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ds.length,
                  itemBuilder: (_, i) {
                    final tx = _ds[i];
                    final ok = tx.trangThai == 'san_sang';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: ok
                                ? mauXanhSang.withAlpha(40)
                                : mauCardVien),
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
                                tx.ten.isNotEmpty
                                    ? tx.ten[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold,
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
                                Text(tx.ten,
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text('SĐT: ${tx.sdt}',
                                    style: const TextStyle(
                                        color: mauTextXam,
                                        fontSize: 12)),
                                Text('GPLX: ${tx.soGPLX}',
                                    style: const TextStyle(
                                        color: mauTextXam,
                                        fontSize: 12)),
                                if (tx.ngaySinh.isNotEmpty)
                                  Text('NS: ${tx.ngaySinh}',
                                      style: const TextStyle(
                                          color: mauTextXamNhat,
                                          fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _sua(tx),
                                child: const Icon(CupertinoIcons.pencil,
                                    color: mauXanhSang, size: 18),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await CoSoDuLieu().capNhatTaiXe(
                                      tx.id!, {
                                    'trangThai': ok
                                        ? 'nghi_viec'
                                        : 'san_sang'
                                  });
                                  _tai();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ok
                                        ? const Color(0xFFFF9800)
                                            .withAlpha(30)
                                        : const Color(0xFF00C853)
                                            .withAlpha(30),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ok ? 'Nghỉ' : 'Kích hoạt',
                                    style: TextStyle(
                                      color: ok
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFF00C853),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (_) =>
                                        CupertinoAlertDialog(
                                      title: const Text('Xóa tài xế'),
                                      content: Text(
                                          'Xác nhận xóa hồ sơ "${tx.ten}"?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () async {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            await CoSoDuLieu()
                                                .xoaTaiXe(tx.id!);
                                            _tai();
                                          },
                                          child: const Text('Xóa'),
                                        ),
                                        CupertinoDialogAction(
                                          isDefaultAction: true,
                                          onPressed: () => Navigator.of(
                                                  context,
                                                  rootNavigator: true)
                                              .pop(),
                                          child: const Text('Hủy'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(CupertinoIcons.trash,
                                    color: mauDoHong, size: 18),
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

class _Fld extends StatelessWidget {
  final TextEditingController ctrl;
  final String ph;
  final TextInputType? kb;
  const _Fld({required this.ctrl, required this.ph, this.kb});

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
