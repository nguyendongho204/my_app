import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class QuanLiXe extends StatefulWidget {
  const QuanLiXe({super.key});
  @override
  State<QuanLiXe> createState() => _QuanLiXeState();
}

class _QuanLiXeState extends State<QuanLiXe> {
  bool _dangTai = true;
  List<Xe> _ds = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaXe();
      if (!mounted) return;
      setState(() {
        _ds = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  void _sua(Xe x) {
    final bienSoCtrl = TextEditingController(text: x.bienSo);
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
                  Text('Sửa thông tin xe',
                      style: TextStyle(
                          color: mauTextTrang, fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                _F(ctrl: bienSoCtrl, ph: 'Biển số xe'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mauNenToi,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: const Text(
                    'Loại xe: Ghế thường (16 chỗ)',
                    style: TextStyle(color: mauTextTrang, fontSize: 14),
                  ),
                ),
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!, style: const TextStyle(color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () async {
                      final bs = bienSoCtrl.text.trim();
                      if (bs.isEmpty) {
                        setM(() => loi = 'Vui lòng nhập biển số');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().capNhatXe(x.id!, {
                        'bienSo': bs, 'loaiXe': 'Ghế thường', 'soGhe': 16,
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
    final bienSoCtrl = TextEditingController();
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
                    Icon(CupertinoIcons.bus,
                        color: mauXanhSang, size: 20),
                    SizedBox(width: 8),
                    Text('Đăng ký xe mới',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _F(ctrl: bienSoCtrl, ph: 'Biển số xe (VD: 65A-12345)'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mauNenToi,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: const Text(
                    'Loại xe: Ghế thường (16 chỗ)',
                    style: TextStyle(color: mauTextTrang, fontSize: 14),
                  ),
                ),
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
                      final bs = bienSoCtrl.text.trim();
                      if (bs.isEmpty) {
                        setM(() => loi = 'Vui lòng nhập biển số');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().taoXe(Xe(
                          bienSo: bs,
                          loaiXe: 'Ghế thường',
                          soGhe: 16,
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
        middle: const Text('Phương tiện & Chỗ ngồi',
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
                      Icon(CupertinoIcons.bus,
                          color: mauTextXam, size: 48),
                      SizedBox(height: 12),
                      Text('Chưa có xe nào',
                          style: TextStyle(color: mauTextXam)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ds.length,
                  itemBuilder: (_, i) {
                    final x = _ds[i];
                    final ok = x.trangThai == 'san_sang';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: ok
                                ? mauXanhSang.withAlpha(60)
                                : mauDoHong.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: ok
                                  ? mauXanhChinh.withAlpha(30)
                                  : mauDoHong.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(CupertinoIcons.bus,
                                color:
                                    ok ? mauXanhSang : mauDoHong,
                                size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(x.bienSo,
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text(
                                    '${x.loaiXe}  •  ${x.soGhe} ghế',
                                    style: const TextStyle(
                                        color: mauTextXam,
                                        fontSize: 13)),
                                Text(
                                    ok ? 'Sẵn sàng' : 'Đang bảo trì',
                                    style: TextStyle(
                                        color: ok
                                            ? const Color(0xFF00C853)
                                            : const Color(0xFFFF9800),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _sua(x),
                            child: const Icon(CupertinoIcons.pencil,
                                color: mauXanhSang, size: 20),
                          ),
                          const SizedBox(width: 4),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await CoSoDuLieu().capNhatXe(x.id!, {
                                'trangThai': ok ? 'bao_tri' : 'san_sang'
                              });
                              _tai();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: ok
                                    ? const Color(0xFFFF9800)
                                        .withAlpha(30)
                                    : const Color(0xFF00C853)
                                        .withAlpha(30),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                ok ? 'Bảo trì' : 'Khôi phục',
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
                          const SizedBox(width: 4),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (_) => CupertinoAlertDialog(
                                  title: const Text('Xóa xe'),
                                  content: Text(
                                      'Xác nhận xóa xe ${x.bienSo}?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      onPressed: () async {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        await CoSoDuLieu()
                                            .xoaXe(x.id!);
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
                                color: mauDoHong, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _F extends StatelessWidget {
  final TextEditingController ctrl;
  final String ph;
  const _F({required this.ctrl, required this.ph});

  @override
  Widget build(BuildContext context) => CupertinoTextField(
        controller: ctrl,
        placeholder: ph,
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
