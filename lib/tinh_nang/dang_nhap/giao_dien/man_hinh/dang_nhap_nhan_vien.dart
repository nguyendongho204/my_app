import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import '../../../soat_ve/giao_dien/man_hinh/soat_ve.dart';

class DangNhapNhanVien extends StatefulWidget {
  const DangNhapNhanVien({super.key});

  @override
  State<DangNhapNhanVien> createState() => _DangNhapNhanVienState();
}

class _DangNhapNhanVienState extends State<DangNhapNhanVien> {
  final _maNVCtrl = TextEditingController();
  final _matKhauCtrl = TextEditingController();
  bool _anMatKhau = true;
  bool _dangTai = false;
  String? _loi;

  @override
  void dispose() {
    _maNVCtrl.dispose();
    _matKhauCtrl.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    final maNV = _maNVCtrl.text.trim();
    final matKhau = _matKhauCtrl.text;
    // Kiểm tra nhanh dữ liệu đầu vào trước khi truy vấn dữ liệu nhân viên.
    if (maNV.isEmpty || matKhau.isEmpty) {
      setState(() => _loi = 'Vui lòng điền đầy đủ thông tin');
      return;
    }
    setState(() {
      _dangTai = true;
      _loi = null;
    });
    final nv = await CoSoDuLieu().dangNhapNhanVien(maNV: maNV, matKhau: matKhau);
    if (!mounted) return;
    setState(() => _dangTai = false);
    if (nv == null) {
      setState(() => _loi = 'Mã nhân viên hoặc mật khẩu không đúng');
      return;
    }
    // Chuyển sang màn hình soát vé sau khi xác thực thành công.
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => SoatVe(nhanVien: nv)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Đăng nhập nhân viên',
            style: TextStyle(color: mauTextTrang)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: mauXanhSang),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: mauXanhChinh.withAlpha(128),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(CupertinoIcons.shield_lefthalf_fill,
                      color: CupertinoColors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('Cổng nhân viên',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Đăng nhập để soát vé hành khách',
                    style: TextStyle(color: mauTextXam, fontSize: 14)),
                const SizedBox(height: 48),
                CupertinoTextField(
                  controller: _maNVCtrl,
                  placeholder: 'Mã nhân viên',
                  placeholderStyle: const TextStyle(color: mauTextXam),
                  style: const TextStyle(color: mauTextTrang),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(CupertinoIcons.person_badge_plus,
                        color: mauXanhSang, size: 20),
                  ),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  padding: const EdgeInsets.all(14),
                  onChanged: (_) => setState(() => _loi = null),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _matKhauCtrl,
                  obscureText: _anMatKhau,
                  placeholder: 'Mật khẩu',
                  placeholderStyle: const TextStyle(color: mauTextXam),
                  style: const TextStyle(color: mauTextTrang),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(CupertinoIcons.lock, color: mauXanhSang, size: 20),
                  ),
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.only(right: 10),
                    onPressed: () => setState(() => _anMatKhau = !_anMatKhau),
                    child: Icon(
                      _anMatKhau ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      color: mauTextXam,
                      size: 18,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  padding: const EdgeInsets.all(14),
                  onChanged: (_) => setState(() => _loi = null),
                  onSubmitted: (_) => _dangNhap(),
                ),
                if (_loi != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _loi!,
                    style: const TextStyle(color: mauDoHong, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 28),
                NutGradient(
                  nhanDe: _dangTai ? 'Đang xử lý...' : 'Đăng nhập',
                  bieuTuong: _dangTai ? null : CupertinoIcons.arrow_right,
                  chieuRong: double.infinity,
                  onNhan: _dangTai ? null : _dangNhap,
                ),
                if (_dangTai) ...[
                  const SizedBox(height: 16),
                  const CupertinoActivityIndicator(
                      radius: 14, color: mauXanhSang),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
