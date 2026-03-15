import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import '../../../quan_tri/giao_dien/man_hinh/quan_tri.dart';

class DangNhapAdmin extends StatefulWidget {
  const DangNhapAdmin({super.key});

  @override
  State<DangNhapAdmin> createState() => _DangNhapAdminState();
}

class _DangNhapAdminState extends State<DangNhapAdmin> {
  final _maTKCtrl = TextEditingController();
  final _mkCtrl = TextEditingController();
  bool _anMk = true;
  bool _dangXuLy = false;
  String? _loi;

  @override
  void dispose() {
    _maTKCtrl.dispose();
    _mkCtrl.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    // Chặn gọi API khi chưa điền đủ dữ liệu bắt buộc.
    if (_maTKCtrl.text.trim().isEmpty || _mkCtrl.text.isEmpty) {
      setState(() => _loi = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    setState(() {
      _dangXuLy = true;
      _loi = null;
    });
    try {
      final admin = await CoSoDuLieu().dangNhapAdmin(
        maTK: _maTKCtrl.text.trim(),
        matKhau: _mkCtrl.text,
      );
      if (!mounted) return;
      setState(() => _dangXuLy = false);
      if (admin == null) {
        setState(() => _loi = 'Tên đăng nhập hoặc mật khẩu không đúng');
        return;
      }
      // Đăng nhập thành công: thay toàn bộ stack bằng màn hình quản trị.
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => QuanTri(admin: admin)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dangXuLy = false;
        _loi = 'Lỗi kết nối: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.back, color: mauXanhSang),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    shape: BoxShape.circle,
                    border: Border.all(color: mauXanhChinh, width: 2),
                  ),
                  child: const Icon(CupertinoIcons.shield_fill,
                      color: mauXanhSang, size: 42),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quản trị viên',
                  style: TextStyle(
                      color: mauTextTrang,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('BookBus Cần Thơ',
                    style: TextStyle(color: mauTextXam, fontSize: 14)),
                const SizedBox(height: 40),
                // Ô tên đăng nhập
                Container(
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: CupertinoTextField(
                    controller: _maTKCtrl,
                    placeholder: 'Tên đăng nhập',
                    placeholderStyle: const TextStyle(color: mauTextXam),
                    style: const TextStyle(color: mauTextTrang),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.person_fill,
                          color: mauTextXam, size: 18),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 14, 12, 14),
                    decoration: null,
                    onSubmitted: (_) => _dangNhap(),
                  ),
                ),
                const SizedBox(height: 12),
                // Ô mật khẩu
                Container(
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: CupertinoTextField(
                    controller: _mkCtrl,
                    placeholder: 'Mật khẩu',
                    placeholderStyle: const TextStyle(color: mauTextXam),
                    style: const TextStyle(color: mauTextTrang),
                    obscureText: _anMk,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(CupertinoIcons.lock_fill,
                          color: mauTextXam, size: 18),
                    ),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.only(right: 8),
                      onPressed: () => setState(() => _anMk = !_anMk),
                      child: Icon(
                          _anMk
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: mauTextXam,
                          size: 18),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 14, 12, 14),
                    decoration: null,
                    onSubmitted: (_) => _dangNhap(),
                  ),
                ),
                if (_loi != null) ...[
                  const SizedBox(height: 8),
                  Text(_loi!,
                      style:
                          const TextStyle(color: mauDoHong, fontSize: 13)),
                ],
                const SizedBox(height: 28),
                if (_dangXuLy)
                  const CupertinoActivityIndicator(
                      radius: 14, color: mauXanhSang)
                else
                  NutGradient(
                    nhanDe: 'Đăng nhập',
                    bieuTuong: CupertinoIcons.arrow_right_circle_fill,
                    chieuRong: double.infinity,
                    onNhan: _dangNhap,
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
