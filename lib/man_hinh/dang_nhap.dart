import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';
import 'trang_chu.dart';

class DangNhap extends StatefulWidget {
  final bool laModal;
  const DangNhap({super.key, this.laModal = false});

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _doiTab(int tab) {
    if (_tab == tab) return;
    _animCtrl.reverse().then((_) {
      setState(() => _tab = tab);
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                const SizedBox(height: 40),
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
                  child: const Icon(CupertinoIcons.bus,
                      color: CupertinoColors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BookBus Cần Thơ',
                  style: TextStyle(
                      color: mauTextTrang,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Đặt vé xe nội tỉnh tiện lợi',
                  style: TextStyle(color: mauTextXam, fontSize: 14),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: Row(
                    children: [
                      _NutTab(
                        nhan: 'Đăng nhập',
                        duocChon: _tab == 0,
                        onNhan: () => _doiTab(0),
                      ),
                      _NutTab(
                        nhan: 'Đăng ký',
                        duocChon: _tab == 1,
                        onNhan: () => _doiTab(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _tab == 0
                      ? _FormDangNhap(key: const ValueKey('login'), laModal: widget.laModal)
                      : _FormDangKy(key: const ValueKey('register'), laModal: widget.laModal),
                ),
                const Spacer(),
                const SizedBox(height: 30),
              ],
            ),
          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
class _NutTab extends StatelessWidget {
  final String nhan;
  final bool duocChon;
  final VoidCallback onNhan;

  const _NutTab({
    required this.nhan,
    required this.duocChon,
    required this.onNhan,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onNhan,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: duocChon ? gradientChinh : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            nhan,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: duocChon ? CupertinoColors.white : mauTextXam,
              fontWeight: duocChon ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
class _FormDangNhap extends StatefulWidget {
  final bool laModal;
  const _FormDangNhap({super.key, this.laModal = false});

  @override
  State<_FormDangNhap> createState() => _FormDangNhapState();
}

class _FormDangNhapState extends State<_FormDangNhap> {
  final _sdtCtrl = TextEditingController();
  final _mkCtrl = TextEditingController();
  final _mkFocus = FocusNode();
  bool _anMk = true;
  bool _dangXuLy = false;
  String? _loi;

  @override
  void dispose() {
    _sdtCtrl.dispose();
    _mkCtrl.dispose();
    _mkFocus.dispose();
    super.dispose();
  }

  String? _kiemTra() {
    final sdt = _sdtCtrl.text.trim();
    final mk = _mkCtrl.text;
    if (sdt.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^0[0-9]{9}$').hasMatch(sdt)) {
      return 'Số điện thoại không hợp lệ (VD: 0912345678)';
    }
    if (mk.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (mk.length < 6) return 'Mật khẩu phải từ 6 ký tự';
    return null;
  }

  List<Widget> _buildGoiY(String sdt, String ten) {
    return [
      GestureDetector(
        onTap: () {
          _sdtCtrl.text = sdt;
          setState(() => _loi = null);
          FocusScope.of(context).requestFocus(_mkFocus);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: mauXanhChinh.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauXanhChinh.withAlpha(77)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  gradient: gradientChinh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ten.isNotEmpty ? ten[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ten,
                        style: const TextStyle(
                            color: mauTextTrang,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(sdt,
                        style: const TextStyle(
                            color: mauTextXam, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right,
                  color: mauXanhSang, size: 16),
            ],
          ),
        ),
      ),
      const Text('hoặc đăng nhập tài khoản khác',
          style: TextStyle(color: mauTextXamNhat, fontSize: 12)),
      const SizedBox(height: 12),
    ];
  }

  Future<void> _dangNhap() async {
    final loi = _kiemTra();
    if (loi != null) {
      setState(() => _loi = loi);
      return;
    }
    setState(() {
      _dangXuLy = true;
      _loi = null;
    });
    NguoiDung? nguoiDung;
    try {
      nguoiDung = await CoSoDuLieu().dangNhap(
        sdt: _sdtCtrl.text.trim(),
        matKhau: _mkCtrl.text,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _dangXuLy = false; _loi = 'Lỗi kết nối: $e'; });
      return;
    }
    if (!mounted) return;
    setState(() => _dangXuLy = false);
    if (nguoiDung == null) {
      setState(() => _loi = 'Số điện thoại hoặc mật khẩu không đúng');
      return;
    }
    TrangThaiUngDung().dangNhap(nguoiDung);
    if (!mounted) return;
    if (widget.laModal) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        CupertinoPageRoute(builder: (_) => const TrangChu()),
      );
    }
  }

  void _quenMatKhau() {
    // Bước 1: Nhập SĐT + email
    final sdtCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mkMoiCtrl = TextEditingController();
    final xnCtrl = TextEditingController();
    bool step1 = true; // true = nhập SĐT/email, false = đặt mk mới
    bool anMk = true, anXn = true;
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          color: mauCardNen,
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      step1 ? 'Quên mật khẩu' : 'Đặt mật khẩu mới',
                      style: const TextStyle(
                          color: mauTextTrang,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: mauTextXam),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step1
                      ? 'Nhập SĐT và email đăng ký để xác minh tài khoản'
                      : 'Nhập mật khẩu mới cho tài khoản ${sdtCtrl.text.trim()}',
                  style: const TextStyle(color: mauTextXam, fontSize: 13),
                ),
                const SizedBox(height: 16),
                if (step1) ...[
                  CupertinoTextField(
                    controller: sdtCtrl,
                    keyboardType: TextInputType.phone,
                    placeholder: 'Số điện thoại',
                    placeholderStyle: const TextStyle(color: mauTextXam),
                    style: const TextStyle(color: mauTextTrang),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(CupertinoIcons.phone, color: mauTextXam, size: 18),
                    ),
                    decoration: BoxDecoration(
                      color: mauNenToi,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mauCardVien),
                    ),
                    padding: const EdgeInsets.all(12),
                    onChanged: (_) => setModal(() => loi = null),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'Email đăng ký',
                    placeholderStyle: const TextStyle(color: mauTextXam),
                    style: const TextStyle(color: mauTextTrang),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(CupertinoIcons.mail, color: mauTextXam, size: 18),
                    ),
                    decoration: BoxDecoration(
                      color: mauNenToi,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mauCardVien),
                    ),
                    padding: const EdgeInsets.all(12),
                    onChanged: (_) => setModal(() => loi = null),
                  ),
                ] else ...[
                  DangnhapPasswordInput(
                    ctrl: mkMoiCtrl,
                    placeholder: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                    an: anMk,
                    onDoiAn: () => setModal(() => anMk = !anMk),
                    onChange: (_) => setModal(() => loi = null),
                  ),
                  const SizedBox(height: 10),
                  DangnhapPasswordInput(
                    ctrl: xnCtrl,
                    placeholder: 'Xác nhận mật khẩu mới',
                    an: anXn,
                    onDoiAn: () => setModal(() => anXn = !anXn),
                    onChange: (_) => setModal(() => loi = null),
                  ),
                ],
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!, style: const TextStyle(color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                NutGradient(
                  nhanDe: step1 ? 'Xác minh tài khoản' : 'Đặt mật khẩu',
                  bieuTuong: step1
                      ? CupertinoIcons.checkmark_shield
                      : CupertinoIcons.lock_rotation,
                  chieuRong: double.infinity,
                  onNhan: () async {
                    if (step1) {
                      final sdt = sdtCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      if (!RegExp(r'^0[0-9]{9}$').hasMatch(sdt)) {
                        setModal(() => loi = 'Số điện thoại không hợp lệ');
                        return;
                      }
                      if (email.isEmpty) {
                        setModal(() => loi = 'Vui lòng nhập email đầy đủ');
                        return;
                      }
                      // Kiểm tra SĐT + email khớp với Firestore
                      setModal(() => loi = null);
                      final q = await CoSoDuLieu().kiemTraSdtEmail(sdt: sdt, email: email);
                      if (!ctx.mounted) return;
                      if (!q) {
                        setModal(() => loi = 'Số điện thoại hoặc email không khớp');
                        return;
                      }
                      setModal(() => step1 = false);
                    } else {
                      final mk = mkMoiCtrl.text;
                      final xn = xnCtrl.text;
                      if (mk.length < 6) {
                        setModal(() => loi = 'Mật khẩu phải từ 6 ký tự');
                        return;
                      }
                      if (mk != xn) {
                        setModal(() => loi = 'Mật khẩu xác nhận không khớp');
                        return;
                      }
                      final ok = await CoSoDuLieu().quenMatKhau(
                        sdt: sdtCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        matKhauMoi: mk,
                      );
                      if (!ctx.mounted) return;
                      if (!ok) {
                        setModal(() => loi = 'Có lỗi xảy ra, vui lòng thử lại');
                        return;
                      }
                      Navigator.pop(ctx);
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Thành công'),
                          content: const Text(
                              'Mật khẩu đã được đặt lại. Vui lòng đăng nhập bằng mật khẩu mới.'),
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
                  },
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
    final sdt = TrangThaiUngDung().sdtGanDay;
    final ten = TrangThaiUngDung().tenGanDay;
    final coGoiY = sdt != null && ten != null && !TrangThaiUngDung().daDangNhap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coGoiY) ..._buildGoiY(sdt, ten),
        DangnhapTextInput(
          ctrl: _sdtCtrl,
          placeholder: 'Số điện thoại',
          bieu: CupertinoIcons.phone,
          loaiBanPhim: TextInputType.phone,
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 12),
        DangnhapPasswordInput(
          ctrl: _mkCtrl,
          placeholder: 'Mật khẩu',
          an: _anMk,
          focusNode: _mkFocus,
          onDoiAn: () => setState(() => _anMk = !_anMk),
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _quenMatKhau,
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(color: mauXanhSang, fontSize: 13),
            ),
          ),
        ),
        if (_loi != null) ...[
          const SizedBox(height: 4),
          DangnhapErrorBox(loi: _loi!),
        ],
        const SizedBox(height: 16),
        DangnhapActionButton(
          nhan: 'Đăng nhập',
          dangXuLy: _dangXuLy,
          onNhan: _dangNhap,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Container(height: 0.5, color: mauCardVien)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'hoặc đăng nhập với',
                style: TextStyle(color: mauTextXamNhat, fontSize: 12),
              ),
            ),
            Expanded(child: Container(height: 0.5, color: mauCardVien)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            DangnhapSocialButton(
              nhan: 'Google',
              bieu: CupertinoIcons.search,
              mau: const Color(0xFFEA4335),
            ),
            const SizedBox(width: 12),
            DangnhapSocialButton(
              nhan: 'Facebook',
              bieu: CupertinoIcons.person_2_fill,
              mau: const Color(0xFF1877F2),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
class _FormDangKy extends StatefulWidget {
  final bool laModal;
  const _FormDangKy({super.key, this.laModal = false});

  @override
  State<_FormDangKy> createState() => _FormDangKyState();
}

class _FormDangKyState extends State<_FormDangKy> {
  final _tenCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mkCtrl = TextEditingController();
  final _xnCtrl = TextEditingController();
  bool _anMk = true;
  bool _anXn = true;
  bool _dongY = false;
  bool _dangXuLy = false;
  String? _loi;

  @override
  void dispose() {
    _tenCtrl.dispose();
    _sdtCtrl.dispose();
    _emailCtrl.dispose();
    _mkCtrl.dispose();
    _xnCtrl.dispose();
    super.dispose();
  }

  String? _kiemTra() {
    final ten = _tenCtrl.text.trim();
    final sdt = _sdtCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final mk = _mkCtrl.text;
    final xn = _xnCtrl.text;
    if (ten.isEmpty) return 'Vui lòng nhập họ và tên';
    if (ten.length < 3) return 'Họ tên phải từ 3 ký tự';
    if (sdt.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^0[0-9]{9}$').hasMatch(sdt)) {
      return 'Số điện thoại không hợp lệ (VD: 0912345678)';
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    if (mk.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (mk.length < 6) return 'Mật khẩu phải từ 6 ký tự';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(mk)) {
      return 'Mật khẩu phải có cả chữ và số';
    }
    if (xn != mk) return 'Mật khẩu xác nhận không khớp';
    if (!_dongY) return 'Vui lòng đồng ý điều khoản sử dụng';
    return null;
  }

  Future<void> _dangKy() async {
    final loi = _kiemTra();
    if (loi != null) {
      setState(() => _loi = loi);
      return;
    }
    setState(() {
      _dangXuLy = true;
      _loi = null;
    });
    // Kiểm tra SĐT đã tồn tại chưa
    final existing = await CoSoDuLieu().dangKy(
      ten: _tenCtrl.text.trim(),
      sdt: _sdtCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      matKhau: _mkCtrl.text,
    ).timeout(const Duration(seconds: 10)).catchError((_) => null);
    if (!mounted) return;
    setState(() => _dangXuLy = false);
    // kiểm tra null = số đã tồn tại
    if (existing == null) {
      // Thử kiểm tra lại xem số đã tồn tại hay lỗi khác
      final check = await CoSoDuLieu().dangNhap(
        sdt: _sdtCtrl.text.trim(), matKhau: _mkCtrl.text);
      if (!mounted) return;
      if (check != null) {
        // Số điện thoại đã tồn tại
        setState(() => _loi = 'Số điện thoại này đã được đăng ký');
      } else {
        setState(() => _loi = 'Lỗi kết nối, vui lòng thử lại');
      }
      // Đã tạo xong → xoá bằng cách set null – không cần xử lý thêm
      return;
    }
    // Trước khi hoàn tất, xác minh OTP
    final otp = TrangThaiUngDung().taoOTP();
    if (!mounted) return;
    final xacNhan = await _hienThiXacThucOTP(otp);
    if (!mounted) return;
    if (!xacNhan) {
      // xóa tài khoản vừa tạo nếu OTP sai/hết hạn
      await CoSoDuLieu().xoaTaiKhoanMoi(existing.id!);
      setState(() => _loi = 'Xác thực OTP thất bại. Vui lòng thử lại.');
      return;
    }
    TrangThaiUngDung().dangNhap(existing);
    if (!mounted) return;
    _hienThiThanhCong(existing.ten);
  }

  Future<bool> _hienThiXacThucOTP(String otpCode) async {
    final completer = Completer<bool>();
    final otpCtrl = TextEditingController();
    String? loi;

    await showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          color: mauCardNen,
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.device_phone_portrait,
                      color: CupertinoColors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Xác minh số điện thoại',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Mã OTP gồm 6 chữ số đã được gửi.',
                  style: TextStyle(color: mauTextXam, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Hiển thị OTP chế độ demo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: mauCam.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mauCam.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.info_circle,
                          color: mauCam, size: 14),
                      const SizedBox(width: 6),
                      Text('Demo – Mã OTP: $otpCode',
                          style: const TextStyle(
                              color: mauCam,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoTextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                      color: mauTextTrang,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8),
                  placeholder: '------',
                  placeholderStyle: const TextStyle(
                      color: mauTextXamNhat,
                      fontSize: 28,
                      letterSpacing: 8),
                  decoration: BoxDecoration(
                    color: mauNenToi,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onChanged: (_) => setModal(() => loi = null),
                ),
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!, style: const TextStyle(color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                NutGradient(
                  nhanDe: 'Xác nhận',
                  bieuTuong: CupertinoIcons.checkmark_circle,
                  chieuRong: double.infinity,
                  onNhan: () {
                    if (TrangThaiUngDung().xacThucOTP(otpCtrl.text)) {
                      Navigator.of(ctx).pop();
                      completer.complete(true);
                    } else {
                      setModal(() => loi = 'Mã OTP không đúng hoặc đã hết hạn');
                    }
                  },
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    completer.complete(false);
                  },
                  child: const Text('Hủy',
                      style: TextStyle(color: mauTextXam, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!completer.isCompleted) completer.complete(false);
    return completer.future;
  }

  void _hienThiThanhCong(String ten) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: mauXanhLa, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.checkmark_alt,
                  color: CupertinoColors.white, size: 28),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đăng ký thành công!',
              style: TextStyle(
                  color: mauXanhLa, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text('Chào mừng $ten đến với BookBus Cần Thơ!'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              if (widget.laModal) {
                Navigator.of(context, rootNavigator: true).pop();
              } else {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  CupertinoPageRoute(builder: (_) => const TrangChu()),
                );
              }
            },
            child: const Text('Bắt đầu ngay'),
          ),
        ],
      ),
    );
  }

  void _xemDieuKhoan() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 400,
        color: mauCardNen,
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Điều khoản sử dụng',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: mauTextXam),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Text(
                    'BookBus Cần Thơ cam kết bảo mật thông tin cá nhân của bạn.\n\n'
                    '1. Thông tin cá nhân chỉ được dùng để xử lý đặt vé.\n\n'
                    '2. Vé đã đặt không được hoàn tiền trong vòng 2 giờ trước giờ khởi hành.\n\n'
                    '3. Người dùng chịu trách nhiệm về tính chính xác của thông tin đặt vé.\n\n'
                    '4. BookBus có quyền hủy vé nếu phát hiện gian lận.\n\n'
                    '5. Mọi thắc mắc vui lòng liên hệ hotline 1900 1234.',
                    style: TextStyle(
                        color: mauTextXam, fontSize: 14, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Đã hiểu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DangnhapTextInput(
          ctrl: _tenCtrl,
          placeholder: 'Họ và tên',
          bieu: CupertinoIcons.person,
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 12),
        DangnhapTextInput(
          ctrl: _sdtCtrl,
          placeholder: 'Số điện thoại',
          bieu: CupertinoIcons.phone,
          loaiBanPhim: TextInputType.phone,
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 12),
        DangnhapTextInput(
          ctrl: _emailCtrl,
          placeholder: 'Email (không bắt buộc)',
          bieu: CupertinoIcons.mail,
          loaiBanPhim: TextInputType.emailAddress,
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 12),
        DangnhapPasswordInput(
          ctrl: _mkCtrl,
          placeholder: 'Mật khẩu (chữ + số, tối thiểu 6 ký tự)',
          an: _anMk,
          onDoiAn: () => setState(() => _anMk = !_anMk),
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 12),
        DangnhapPasswordInput(
          ctrl: _xnCtrl,
          placeholder: 'Xác nhận mật khẩu',
          an: _anXn,
          onDoiAn: () => setState(() => _anXn = !_anXn),
          onChange: (_) => setState(() => _loi = null),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => setState(() => _dongY = !_dongY),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _dongY
                      ? mauXanhChinh
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _dongY ? mauXanhChinh : mauCardVien,
                    width: 1.5,
                  ),
                ),
                child: _dongY
                    ? const Icon(CupertinoIcons.checkmark,
                        color: CupertinoColors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: mauTextXam, fontSize: 13, height: 1.4),
                    children: [
                      const TextSpan(text: 'Tôi đồng ý với '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: _xemDieuKhoan,
                          child: const Text(
                            'điều khoản sử dụng',
                            style: TextStyle(
                              color: mauXanhSang,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' của BookBus'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_loi != null) ...[
          const SizedBox(height: 10),
          DangnhapErrorBox(loi: _loi!),
        ],
        const SizedBox(height: 20),
        DangnhapActionButton(
          nhan: 'Tạo tài khoản',
          dangXuLy: _dangXuLy,
          onNhan: _dangKy,
        ),
      ],
    );
  }
}

// ============================================================
// Shared widgets (public to allow use from other files if needed)
// ============================================================

class DangnhapTextInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String placeholder;
  final IconData bieu;
  final TextInputType loaiBanPhim;
  final ValueChanged<String>? onChange;

  const DangnhapTextInput({
    super.key,
    required this.ctrl,
    required this.placeholder,
    required this.bieu,
    this.loaiBanPhim = TextInputType.text,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mauCardVien),
      ),
      child: CupertinoTextField(
        controller: ctrl,
        keyboardType: loaiBanPhim,
        onChanged: onChange,
        style: const TextStyle(color: mauTextTrang, fontSize: 15),
        placeholder: placeholder,
        placeholderStyle:
            const TextStyle(color: mauTextXamNhat, fontSize: 14),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(bieu, color: mauTextXam, size: 18),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(),
      ),
    );
  }
}

class DangnhapPasswordInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String placeholder;
  final bool an;
  final VoidCallback onDoiAn;
  final ValueChanged<String>? onChange;
  final FocusNode? focusNode;

  const DangnhapPasswordInput({
    super.key,
    required this.ctrl,
    required this.placeholder,
    required this.an,
    required this.onDoiAn,
    this.onChange,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mauCardVien),
      ),
      child: CupertinoTextField(
        controller: ctrl,
        focusNode: focusNode,
        obscureText: an,
        onChanged: onChange,
        style: const TextStyle(color: mauTextTrang, fontSize: 15),
        placeholder: placeholder,
        placeholderStyle:
            const TextStyle(color: mauTextXamNhat, fontSize: 14),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: Icon(CupertinoIcons.lock, color: mauTextXam, size: 18),
        ),
        suffix: CupertinoButton(
          padding: const EdgeInsets.only(right: 12),
          onPressed: onDoiAn,
          child: Icon(
            an ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: mauTextXam,
            size: 18,
          ),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(),
      ),
    );
  }
}

class DangnhapErrorBox extends StatelessWidget {
  final String loi;

  const DangnhapErrorBox({super.key, required this.loi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: mauDoHong.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mauDoHong.withAlpha(100)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle,
              color: mauDoHong, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loi,
              style: const TextStyle(color: mauDoHong, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class DangnhapActionButton extends StatelessWidget {
  final String nhan;
  final bool dangXuLy;
  final VoidCallback onNhan;

  const DangnhapActionButton({
    super.key,
    required this.nhan,
    required this.dangXuLy,
    required this.onNhan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dangXuLy ? null : onNhan,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: dangXuLy ? null : gradientChinh,
          color: dangXuLy ? mauCardNen : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: dangXuLy
              ? null
              : [
                  BoxShadow(
                    color: mauXanhChinh.withAlpha(102),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: dangXuLy
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(
                      radius: 10, color: mauXanhSang),
                  SizedBox(width: 10),
                  Text(
                    'Dang xu ly...',
                    style: TextStyle(color: mauTextXam, fontSize: 15),
                  ),
                ],
              )
            : Text(
                nhan,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class DangnhapSocialButton extends StatelessWidget {
  final String nhan;
  final IconData bieu;
  final Color mau;

  const DangnhapSocialButton({
    super.key,
    required this.nhan,
    required this.bieu,
    required this.mau,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mauCardVien),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(bieu, color: mau, size: 20),
              const SizedBox(width: 8),
              Text(
                nhan,
                style: const TextStyle(
                    color: mauTextTrang, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
