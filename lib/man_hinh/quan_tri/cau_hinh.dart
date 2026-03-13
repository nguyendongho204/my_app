import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class CauHinhHT extends StatefulWidget {
  const CauHinhHT({super.key});
  @override
  State<CauHinhHT> createState() => _CauHinhHTState();
}

class _CauHinhHTState extends State<CauHinhHT> {
  bool _dangTai = true;
  bool _dangLuu = false;
  final _phiCtrl = TextEditingController();
  final _csHoanCtrl = TextEditingController();
  final _tbCtrl = TextEditingController();

  List<Map<String, dynamic>> _lichSu = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  @override
  void dispose() {
    _phiCtrl.dispose();
    _csHoanCtrl.dispose();
    _tbCtrl.dispose();
    super.dispose();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final futures = await Future.wait([
        CoSoDuLieu().layCauHinh(),
        CoSoDuLieu().layLichSuSoatTatCa(tatCa: true),
      ]);
      final cfg = futures[0] as Map<String, dynamic>;
      final ls = futures[1] as List<Map<String, dynamic>>;
      if (!mounted) return;
      _phiCtrl.text =
          (cfg['phi_dich_vu'] ?? 0).toString();
      _csHoanCtrl.text =
          cfg['chinh_sach_hoan_ve'] ?? '';
      _tbCtrl.text =
          cfg['thong_bao_he_thong'] ?? '';
      setState(() {
        _lichSu = ls.take(10).toList();
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _luu() async {
    final phi = int.tryParse(_phiCtrl.text.trim()) ?? 0;
    if (phi < 0 || phi > 100) {
      _showAlert('Lỗi', 'Phí dịch vụ phải từ 0–100%');
      return;
    }
    setState(() => _dangLuu = true);
    await CoSoDuLieu().capNhatCauHinh({
      'phi_dich_vu': phi,
      'chinh_sach_hoan_ve': _csHoanCtrl.text.trim(),
      'thong_bao_he_thong': _tbCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _dangLuu = false);
    _showAlert('Thành công', 'Đã lưu cấu hình hệ thống.');
  }

  void _showAlert(String title, String msg) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(msg),
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Cấu hình & Bảo mật',
            style: TextStyle(color: mauTextTrang)),
        trailing: _dangLuu
            ? const CupertinoActivityIndicator(
                radius: 10, color: mauXanhSang)
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _luu,
                child: const Text('Lưu',
                    style: TextStyle(
                        color: mauXanhSang,
                        fontWeight: FontWeight.bold)),
              ),
      ),
      child: _dangTai
          ? const Center(
              child: CupertinoActivityIndicator(
                  radius: 14, color: mauXanhSang))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Config form ─────────────────────────
                  _SecHeader('Cài đặt hệ thống',
                      CupertinoIcons.settings_solid),
                  const SizedBox(height: 12),
                  _LabelField(
                    label: 'Phí dịch vụ (%)',
                    child: CupertinoTextField(
                      controller: _phiCtrl,
                      placeholder: 'VD: 5',
                      keyboardType: TextInputType.number,
                      placeholderStyle: const TextStyle(
                          color: mauTextXam, fontSize: 14),
                      style: const TextStyle(
                          color: mauTextTrang, fontSize: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mauCardVien),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabelField(
                    label: 'Chính sách hoàn vé',
                    child: CupertinoTextField(
                      controller: _csHoanCtrl,
                      placeholder:
                          'Nhập chính sách hoàn trả vé...',
                      placeholderStyle: const TextStyle(
                          color: mauTextXam, fontSize: 13),
                      style: const TextStyle(
                          color: mauTextTrang, fontSize: 14),
                      padding: const EdgeInsets.all(12),
                      maxLines: 4,
                      minLines: 3,
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mauCardVien),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabelField(
                    label: 'Thông báo hệ thống',
                    child: CupertinoTextField(
                      controller: _tbCtrl,
                      placeholder:
                          'Thông báo hiển thị cho khách hàng...',
                      placeholderStyle: const TextStyle(
                          color: mauTextXam, fontSize: 13),
                      style: const TextStyle(
                          color: mauTextTrang, fontSize: 14),
                      padding: const EdgeInsets.all(12),
                      maxLines: 3,
                      minLines: 2,
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mauCardVien),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Audit log ────────────────────────────
                  _SecHeader(
                      'Nhật ký soát vé (10 gần nhất)',
                      CupertinoIcons.list_bullet_below_rectangle),
                  const SizedBox(height: 12),
                  if (_lichSu.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Chưa có dữ liệu soát vé',
                            style: TextStyle(
                                color: mauTextXam)),
                      ),
                    )
                  else
                    ..._lichSu.asMap().entries.map((e) {
                      final idx = e.key;
                      final item = e.value;
                      final ok = item['trangThai'] == 'hop_le' ||
                          item['trangThai'] == 'thanh_cong';
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mauCardNen,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                              color: (ok
                                      ? const Color(0xFF00C853)
                                      : mauDoHong)
                                  .withAlpha(50)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: (ok
                                        ? const Color(
                                            0xFF00C853)
                                        : mauDoHong)
                                    .withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                      color: ok
                                          ? const Color(
                                              0xFF00C853)
                                          : mauDoHong,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      item['maVe'] ??
                                          item['nhanVienId'] ??
                                          'N/A',
                                      style: const TextStyle(
                                          color: mauTextTrang,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 13)),
                                  Text(
                                      '${item['nhanVienTen'] ?? ''}  •  ${item['thoiGian'] ?? ''}',
                                      style: const TextStyle(
                                          color: mauTextXam,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3),
                              decoration: BoxDecoration(
                                color: (ok
                                        ? const Color(
                                            0xFF00C853)
                                        : mauDoHong)
                                    .withAlpha(30),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['trangThai'] ?? '',
                                style: TextStyle(
                                    color: ok
                                        ? const Color(
                                            0xFF00C853)
                                        : mauDoHong,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _SecHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SecHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: mauXanhSang, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: mauTextTrang,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      );
}

class _LabelField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabelField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: mauTextXam, fontSize: 12)),
          const SizedBox(height: 6),
          child,
        ],
      );
}
