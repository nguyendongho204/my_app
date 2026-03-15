import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import '../../../dang_nhap/giao_dien/man_hinh/dang_nhap.dart';
import '../../../dang_nhap/giao_dien/man_hinh/dang_nhap_nhan_vien.dart';
import '../../../dang_nhap/giao_dien/man_hinh/dang_nhap_admin.dart';

class TaiKhoan extends StatefulWidget {
  const TaiKhoan({super.key});

  @override
  State<TaiKhoan> createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> {
  @override
  void initState() {
    super.initState();
    TrangThaiUngDung().addListener(_rebuild);
  }

  @override
  void dispose() {
    TrangThaiUngDung().removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    // Re-render khi dữ liệu người dùng trong trạng thái toàn cục thay đổi.
    if (mounted) setState(() {});
  }

  String _dinhDangTien(int tien) {
    if (tien >= 1000000) return '${(tien / 1000000).toStringAsFixed(1)}M';
    if (tien >= 1000) return '${(tien / 1000).round()}k';
    return tien.toString();
  }

  String _tinhNamSuDung() {
    final nd = TrangThaiUngDung().nguoiDungHienTai;
    if (nd == null) return '0';
    try {
      final parts = nd.ngayTao.split('/');
      final ngayTao = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final years = DateTime.now().difference(ngayTao).inDays ~/ 365;
      return years < 1 ? '< 1' : '$years';
    } catch (_) {
      return '< 1';
    }
  }

  void _suaThongTin() {
    // Hiển thị form modal để cập nhật tên và email của tài khoản hiện tại.
    final nd = TrangThaiUngDung().nguoiDungHienTai!;
    final tenCtrl = TextEditingController(text: nd.ten);
    final emailCtrl = TextEditingController(text: nd.email);
    String? loi;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          color: mauCardNen,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chỉnh sửa thông tin',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: mauTextXam),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(
                    color: mauNenToi,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: Row(children: [
                    const Icon(CupertinoIcons.phone,
                        color: mauTextXamNhat, size: 18),
                    const SizedBox(width: 10),
                    Text(nd.sdt,
                        style: const TextStyle(color: mauTextXamNhat)),
                    const Spacer(),
                    const Text('Không thể đổi',
                        style: TextStyle(
                            color: mauTextXamNhat, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: tenCtrl,
                  placeholder: 'Họ và tên',
                  placeholderStyle: const TextStyle(color: mauTextXam),
                  style: const TextStyle(color: mauTextTrang),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(CupertinoIcons.person,
                        color: mauTextXam, size: 18),
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
                  placeholder: 'Email (tùy chọn)',
                  placeholderStyle: const TextStyle(color: mauTextXam),
                  style: const TextStyle(color: mauTextTrang),
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(CupertinoIcons.mail,
                        color: mauTextXam, size: 18),
                  ),
                  decoration: BoxDecoration(
                    color: mauNenToi,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mauCardVien),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                if (loi != null) ...
                  [
                    const SizedBox(height: 6),
                    Text(loi!,
                        style: const TextStyle(
                            color: mauDoHong, fontSize: 12)),
                  ],
                const SizedBox(height: 16),
                NutGradient(
                  nhanDe: 'Lưu thay đổi',
                  bieuTuong: CupertinoIcons.checkmark,
                  chieuRong: double.infinity,
                  onNhan: () async {
                    final ten = tenCtrl.text.trim();
                    if (ten.length < 3) {
                      setModal(() => loi = 'Họ tên phải từ 3 ký tự');
                      return;
                    }
                    final email = emailCtrl.text.trim();
                    if (email.isNotEmpty &&
                        !RegExp(r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$')
                            .hasMatch(email)) {
                      setModal(() => loi = 'Email không hợp lệ');
                      return;
                    }
                    await CoSoDuLieu()
                        .capNhatThongTin(nd.id!, ten: ten, email: email);
                    TrangThaiUngDung().capNhatNguoiDung(NguoiDung(
                      id: nd.id,
                      ten: ten,
                      sdt: nd.sdt,
                      email: email,
                      matKhau: nd.matKhau,
                      ngayTao: nd.ngayTao,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _doiMatKhau() {
    // Đổi mật khẩu theo quy trình: nhập mật khẩu cũ -> mật khẩu mới -> xác nhận.
    final mkCuCtrl = TextEditingController();
    final mkMoiCtrl = TextEditingController();
    final xnMoiCtrl = TextEditingController();
    bool anCu = true, anMoi = true, anXn = true;
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
                    const Text('Đổi mật khẩu',
                        style: TextStyle(
                            color: mauTextTrang,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: mauTextXam),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _OMatKhauModal(ctrl: mkCuCtrl, placeholder: 'Mật khẩu hiện tại', an: anCu,
                    onDoiAn: () => setModal(() => anCu = !anCu),
                    onChange: (_) => setModal(() => loi = null)),
                const SizedBox(height: 10),
                _OMatKhauModal(ctrl: mkMoiCtrl, placeholder: 'Mật khẩu mới (tối thiểu 6 ký tự)', an: anMoi,
                    onDoiAn: () => setModal(() => anMoi = !anMoi),
                    onChange: (_) => setModal(() => loi = null)),
                const SizedBox(height: 10),
                _OMatKhauModal(ctrl: xnMoiCtrl, placeholder: 'Xác nhận mật khẩu mới', an: anXn,
                    onDoiAn: () => setModal(() => anXn = !anXn),
                    onChange: (_) => setModal(() => loi = null)),
                if (loi != null) ...[
                  const SizedBox(height: 8),
                  Text(loi!, style: const TextStyle(color: mauDoHong, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                NutGradient(
                  nhanDe: 'Đổi mật khẩu',
                  bieuTuong: CupertinoIcons.lock_rotation,
                  chieuRong: double.infinity,
                  onNhan: () async {
                    final cu = mkCuCtrl.text;
                    final moi = mkMoiCtrl.text;
                    final xn = xnMoiCtrl.text;
                    if (cu.isEmpty || moi.isEmpty || xn.isEmpty) {
                      setModal(() => loi = 'Vui lòng điền đầy đủ thông tin');
                      return;
                    }
                    if (moi.length < 6) {
                      setModal(() => loi = 'Mật khẩu mới phải từ 6 ký tự');
                      return;
                    }
                    if (moi != xn) {
                      setModal(() => loi = 'Mật khẩu xác nhận không khớp');
                      return;
                    }
                    final nd = TrangThaiUngDung().nguoiDungHienTai!;
                    final ok = await CoSoDuLieu().doiMatKhau(nd.id!,
                        matKhauCu: cu, matKhauMoi: moi);
                    if (!mounted) return;
                    if (!ok) {
                      setModal(() => loi = 'Mật khẩu hiện tại không đúng');
                      return;
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('Thành công'),
                        content: const Text('Mật khẩu đã được đổi thành công.'),
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _taoDanhSachThongBao() {
    final dsVe = TrangThaiUngDung().danhSachVe;
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> thongBaos = [];

    for (final ve in dsVe) {
      try {
        final parts = ve.ngay.split('/');
        final ngayDi = DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]),
        );
        final diff = ngayDi.difference(homNay).inDays;

        if (ve.trangThai == 'huy') {
          thongBaos.add({
            'icon': CupertinoIcons.xmark_circle_fill,
            'mauIcon': const Color(0xFFFF453A),
            'tieu_de': 'Vé ${ve.maVe} đã hủy',
            'noi_dung': '${ve.diemDi} → ${ve.diemDen}, ${ve.ngay} ${ve.gio}',
          });
        } else if (diff == 0) {
          thongBaos.add({
            'icon': CupertinoIcons.alarm_fill,
            'mauIcon': const Color(0xFFFF9F0A),
            'tieu_de': 'Chuyến hôm nay lúc ${ve.gio}!',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diff == 1) {
          thongBaos.add({
            'icon': CupertinoIcons.clock_fill,
            'mauIcon': const Color(0xFFFF9F0A),
            'tieu_de': 'Chuyến ngày mai lúc ${ve.gio}',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}',
          });
        } else if (diff > 1 && diff <= 7 && ve.trangThai != 'huy') {
          thongBaos.add({
            'icon': CupertinoIcons.checkmark_seal_fill,
            'mauIcon': mauXanhSang,
            'tieu_de': 'Đặt vé thành công',
            'noi_dung': '${ve.maVe} · ${ve.diemDi} → ${ve.diemDen}, ${ve.ngay} ${ve.gio}',
          });
        }
      } catch (_) {}
    }
    return thongBaos;
  }

  void _xemThongBao() {
    final thongBaos = _taoDanhSachThongBao();
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
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, color: mauTextXam),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (thongBaos.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.bell_slash, color: mauTextXamNhat, size: 48),
                        SizedBox(height: 12),
                        Text('Không có thông báo nào',
                            style: TextStyle(color: mauTextXam, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: thongBaos.length,
                    separatorBuilder: (_, index) => Container(
                        height: 0.5, margin: const EdgeInsets.only(left: 52), color: mauCardVien),
                    itemBuilder: (_, i) {
                      final tb = thongBaos[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: (tb['mauIcon'] as Color).withAlpha(38),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(tb['icon'] as IconData,
                                  color: tb['mauIcon'] as Color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tb['tieu_de'] as String,
                                      style: const TextStyle(
                                          color: mauTextTrang,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text(tb['noi_dung'] as String,
                                      style: const TextStyle(
                                          color: mauTextXam, fontSize: 12)),
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
  }

  void _troGiup() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Trợ giúp'),
        content: const Text(
          'Nếu bạn cần hỗ trợ, vui lòng liên hệ:\n\n'
          'Hotline: 1900 1234\n'
          'Email: support@bookbus.vn\n'
          'Giờ làm việc: 7:00 \u2013 22:00',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _chinhSach() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 420,
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
                    'Chính sách sử dụng',
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
                    style:
                        TextStyle(color: mauTextXam, fontSize: 14, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _danhGia() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Đánh giá ứng dụng'),
        content: const Text(
            'Cảm ơn bạn đã sử dụng BookBus Cần Thơ!\n'
            'Sự ủng hộ của bạn là động lực để chúng tôi phát triển ứng dụng tốt hơn.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('★ ★ ★ ★ ★  Gửi đánh giá'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Sau'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nd = TrangThaiUngDung().nguoiDungHienTai;

    // Khi chua dang nhap
    if (!TrangThaiUngDung().daDangNhap) {
      return CupertinoPageScaffold(
        backgroundColor: mauNenToi,
        child: Container(
          decoration: const BoxDecoration(gradient: gradientNen),
          child: CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: mauNenToi2.withAlpha(230),
                border: null,
                largeTitle: const Text('Tài khoản',
                    style: TextStyle(color: mauTextTrang)),
              ),
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.person_crop_circle,
                            color: mauTextXamNhat, size: 80),
                        const SizedBox(height: 16),
                        const Text('Chưa đăng nhập',
                            style: TextStyle(
                                color: mauTextTrang,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Đăng nhập để xem thông tin tài khoản và quản lý vé',
                          style: TextStyle(
                              color: mauTextXam,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        NutGradient(
                          nhanDe: 'Đăng nhập',
                          bieuTuong: CupertinoIcons.arrow_right,
                          chieuRong: double.infinity,
                          onNhan: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => const DangNhap(laModal: true)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => const DangNhapNhanVien()),
                          ),
                          child: const Text(
                            'Nhân viên soát vé? Đăng nhập tại đây →',
                            style: TextStyle(color: mauTextXam, fontSize: 13),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute(
                                builder: (_) => const DangNhapAdmin()),
                          ),
                          child: const Text(
                            'Quản trị viên →',
                            style: TextStyle(color: mauTextXamNhat, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: mauNenToi2.withAlpha(230),
              border: null,
              largeTitle: const Text('Tài khoản',
                  style: TextStyle(color: mauTextTrang)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar + ten
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: gradientChinh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: CupertinoColors.white.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.person_fill,
                                color: CupertinoColors.white, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nd?.ten ?? 'Khách',
                                    style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 4),
                                Text(nd?.sdt ?? '',
                                    style: TextStyle(
                                        color: Color(0xB3FFFFFF),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _suaThongTin,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(CupertinoIcons.pencil,
                                  color: CupertinoColors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Thong ke
                    Builder(builder: (context) {
                      final dsVe = TrangThaiUngDung().danhSachVe;
                      final soChuyenDaDi = dsVe.where((v) => v.trangThai == 'hoan_thanh').length;
                      final tongChiTieu = dsVe.fold<int>(0, (s, v) => s + v.tongTien);
                      return Row(
                        children: [
                          _CardThongKe(so: '$soChuyenDaDi', nhan: 'Chuyến đã đi'),
                          const SizedBox(width: 10),
                          _CardThongKe(so: _dinhDangTien(tongChiTieu), nhan: 'Tổng chi tiêu'),
                          const SizedBox(width: 10),
                          _CardThongKe(so: _tinhNamSuDung(), nhan: 'Năm sử dụng'),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    // Menu
                    _NhomMenu(tieuDe: 'Tài khoản', mucMenu: [
                      _MucMenu(bieu: CupertinoIcons.person_crop_circle, nhan: 'Thông tin cá nhân', onTap: _suaThongTin),
                      _MucMenu(bieu: CupertinoIcons.lock_rotation, nhan: 'Đổi mật khẩu', onTap: _doiMatKhau),
                      _MucMenu(bieu: CupertinoIcons.bell, nhan: 'Thông báo', onTap: _xemThongBao),
                    ]),
                    const SizedBox(height: 14),
                    _NhomMenu(tieuDe: 'Hỗ trợ', mucMenu: [
                      _MucMenu(bieu: CupertinoIcons.question_circle, nhan: 'Trợ giúp', onTap: _troGiup),
                      _MucMenu(bieu: CupertinoIcons.doc_text, nhan: 'Chính sách sử dụng', onTap: _chinhSach),
                      _MucMenu(bieu: CupertinoIcons.star, nhan: 'Đánh giá ứng dụng', onTap: _danhGia),
                    ]),
                    const SizedBox(height: 14),
                    // Dang xuat
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _hienThiXacNhan(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: mauDoHong.withAlpha(38),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: mauDoHong.withAlpha(102)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.square_arrow_left, color: mauDoHong, size: 20),
                            SizedBox(width: 10),
                            Text('Đăng xuất',
                                style: TextStyle(
                                    color: mauDoHong, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('BookBus Cần Thơ v1.0.0',
                        style: TextStyle(color: mauTextXamNhat, fontSize: 12)),
                    const SizedBox(height: 6),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                            builder: (_) => const DangNhapNhanVien()),
                      ),
                      child: const Text(
                        'Nhân viên soát vé? Đăng nhập tại đây →',
                        style: TextStyle(color: mauTextXamNhat, fontSize: 12),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(builder: (_) => const DangNhapAdmin()),
                      ),
                      child: const Text(
                        'Quản trị viên →',
                        style: TextStyle(color: mauTextXamNhat, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hienThiXacNhan(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogCtx, rootNavigator: true).pop();
              TrangThaiUngDung().dangXuat();
            },
            child: const Text('Đăng xuất'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}

class _CardThongKe extends StatelessWidget {
  final String so;
  final String nhan;

  const _CardThongKe({required this.so, required this.nhan});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: mauCardNen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mauCardVien),
        ),
        child: Column(
          children: [
            Text(so,
                style: const TextStyle(
                    color: mauXanhSang, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text(nhan,
                style: const TextStyle(color: mauTextXam, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NhomMenu extends StatelessWidget {
  final String tieuDe;
  final List<_MucMenu> mucMenu;

  const _NhomMenu({required this.tieuDe, required this.mucMenu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(tieuDe.toUpperCase(),
              style: const TextStyle(color: mauTextXamNhat, fontSize: 11, letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauCardVien),
          ),
          child: Column(
            children: List.generate(mucMenu.length, (i) {
              final muc = mucMenu[i];
              return Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: muc.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(muc.bieu, color: mauXanhSang, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(muc.nhan,
                                style: const TextStyle(color: mauTextTrang, fontSize: 15)),
                          ),
                          const Icon(CupertinoIcons.chevron_right,
                              color: mauTextXam, size: 14),
                        ],
                      ),
                    ),
                  ),
                  if (i < mucMenu.length - 1)
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 50),
                      color: mauCardVien,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MucMenu {
  final IconData bieu;
  final String nhan;
  final VoidCallback? onTap;

  const _MucMenu({required this.bieu, required this.nhan, this.onTap});
}

class _OMatKhauModal extends StatelessWidget {
  final TextEditingController ctrl;
  final String placeholder;
  final bool an;
  final VoidCallback onDoiAn;
  final ValueChanged<String>? onChange;

  const _OMatKhauModal({
    required this.ctrl,
    required this.placeholder,
    required this.an,
    required this.onDoiAn,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: ctrl,
      obscureText: an,
      onChanged: onChange,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: mauTextXam, fontSize: 13),
      style: const TextStyle(color: mauTextTrang),
      suffix: CupertinoButton(
        padding: const EdgeInsets.only(right: 8),
        onPressed: onDoiAn,
        child: Icon(an ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: mauTextXam, size: 18),
      ),
      decoration: BoxDecoration(
        color: mauNenToi,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mauCardVien),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}