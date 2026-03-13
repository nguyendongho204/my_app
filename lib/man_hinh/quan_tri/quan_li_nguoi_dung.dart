import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class QuanLiNguoiDung extends StatefulWidget {
  const QuanLiNguoiDung({super.key});
  @override
  State<QuanLiNguoiDung> createState() => _QuanLiNguoiDungState();
}

class _QuanLiNguoiDungState extends State<QuanLiNguoiDung> {
  int _tab = 0; // 0=Khách hàng, 1=Admin, 2=Nhân viên
  bool _dangTai = true;
  List<NguoiDung> _kh = [];
  List<Admin> _admins = [];
  List<NhanVien> _nvs = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final r = await Future.wait([
        CoSoDuLieu().layTatCaNguoiDung(),
        CoSoDuLieu().layTatCaAdmin(),
        CoSoDuLieu().layTatCaNhanVien(),
      ]);
      if (!mounted) return;
      setState(() {
        _kh = r[0] as List<NguoiDung>;
        _admins = r[1] as List<Admin>;
        _nvs = r[2] as List<NhanVien>;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  void _themAdmin() {
    final tenCtrl = TextEditingController();
    final maTKCtrl = TextEditingController();
    final mkCtrl = TextEditingController();
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
                const Text('Thêm quản trị viên',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _Cf(ctrl: tenCtrl, ph: 'Họ và tên'),
                const SizedBox(height: 10),
                _Cf(ctrl: maTKCtrl, ph: 'Tên đăng nhập'),
                const SizedBox(height: 10),
                _Cf(ctrl: mkCtrl, ph: 'Mật khẩu'),
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
                      final ma = maTKCtrl.text.trim();
                      final mk = mkCtrl.text;
                      if (ten.isEmpty || ma.isEmpty || mk.length < 6) {
                        setM(() => loi =
                            'Mật khẩu tối thiểu 6 ký tự, điền đủ thông tin');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().taoAdmin(
                          ten: ten, maTK: ma, matKhau: mk);
                      _tai();
                    },
                    child: const Text('Thêm'),
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
        middle: const Text('Người dùng & Phân quyền',
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
            if (_tab == 1)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _themAdmin,
                child: const Icon(CupertinoIcons.add,
                    color: mauXanhSang, size: 22),
              )
            else if (_tab == 2)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _themNhanVien,
                child: const Icon(CupertinoIcons.add,
                    color: mauXanhSang, size: 22),
              ),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            color: mauNenToi2,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _tab,
              backgroundColor: mauNenToi,
              children: {
                0: Text('Khách hàng (${_kh.length})',
                    style: const TextStyle(fontSize: 12)),
                1: Text('Admin (${_admins.length})',
                    style: const TextStyle(fontSize: 12)),
                2: Text('NV (${_nvs.length})',
                    style: const TextStyle(fontSize: 12)),
              },
              onValueChanged: (v) {
                if (v != null) setState(() => _tab = v);
              },
            ),
          ),
          Expanded(
            child: _dangTai
                ? const Center(
                    child: CupertinoActivityIndicator(
                        radius: 14, color: mauXanhSang))
                : _tab == 0
                    ? _buildKH()
                    : _tab == 1
                        ? _buildAdmin()
                        : _buildNV(),
          ),
        ],
      ),
    );
  }

  Widget _buildKH() {
    if (_kh.isEmpty) {
      return const Center(
          child: Text('Chưa có khách hàng nào',
              style: TextStyle(color: mauTextXam)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kh.length,
      itemBuilder: (_, i) {
        final kh = _kh[i];
        final khoa = kh.biKhoa;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauCardVien),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    gradient: gradientChinh, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    kh.ten.isNotEmpty ? kh.ten[0].toUpperCase() : '?',
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
                    Text(kh.ten,
                        style: const TextStyle(
                            color: mauTextTrang,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(kh.sdt,
                        style: const TextStyle(
                            color: mauTextXam, fontSize: 12)),
                    Text(kh.email,
                        style: const TextStyle(
                            color: mauTextXamNhat, fontSize: 11)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await CoSoDuLieu().khoaTaiKhoan(kh.id!, !khoa);
                  _tai();
                },
                child: Icon(
                  khoa
                      ? CupertinoIcons.lock_fill
                      : CupertinoIcons.lock_open,
                  color: khoa ? mauDoHong : mauTextXam,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdmin() {
    if (_admins.isEmpty) {
      return const Center(
          child: Text('Chưa có admin nào',
              style: TextStyle(color: mauTextXam)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _admins.length,
      itemBuilder: (_, i) {
        final a = _admins[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauXanhSang.withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: mauXanhChinh.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                    CupertinoIcons.shield_fill,
                    color: mauXanhSang,
                    size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.ten,
                        style: const TextStyle(
                            color: mauTextTrang,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text('@${a.maTK}',
                        style: const TextStyle(
                            color: mauXanhSang, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.checkmark_seal_fill,
                  color: mauXanhSang, size: 18),
            ],
          ),
        );
      },
    );
  }

  void _themNhanVien() {
    final tenCtrl = TextEditingController();
    final maNVCtrl = TextEditingController();
    final mkCtrl = TextEditingController();
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
                const Text('Thêm nhân viên',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _Cf(ctrl: tenCtrl, ph: 'Họ và tên'),
                const SizedBox(height: 10),
                _Cf(ctrl: maNVCtrl, ph: 'Mã nhân viên'),
                const SizedBox(height: 10),
                _Cf(ctrl: mkCtrl, ph: 'Mật khẩu (tối thiểu 6 ký tự)'),
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
                      final ma = maNVCtrl.text.trim();
                      final mk = mkCtrl.text;
                      if (ten.isEmpty || ma.isEmpty || mk.length < 6) {
                        setM(() => loi =
                            'Mật khẩu tối thiểu 6 ký tự, điền đủ thông tin');
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu().taoNhanVien(
                          ten: ten, maNV: ma, matKhau: mk);
                      _tai();
                    },
                    child: const Text('Thêm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNV() {
    if (_nvs.isEmpty) {
      return const Center(
          child: Text('Chưa có nhân viên nào',
              style: TextStyle(color: mauTextXam)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nvs.length,
      itemBuilder: (_, i) {
        final nv = _nvs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mauCardVien),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: mauXanhLa.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                    CupertinoIcons.person_badge_plus,
                    color: mauXanhLa,
                    size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nv.ten,
                        style: const TextStyle(
                            color: mauTextTrang,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text('Mã NV: ${nv.maNV}',
                        style: const TextStyle(
                            color: mauTextXam, fontSize: 12)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final confirm = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: const Text('Xóa nhân viên'),
                      content: Text(
                          'Xóa "${nv.ten}" khỏi hệ thống?'),
                      actions: [
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.of(
                                    context,
                                    rootNavigator: true)
                                .pop(true),
                            child: const Text('Xóa')),
                        CupertinoDialogAction(
                            onPressed: () => Navigator.of(
                                    context,
                                    rootNavigator: true)
                                .pop(false),
                            child: const Text('Hủy')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await CoSoDuLieu().xoaNhanVien(nv.id!);
                    _tai();
                  }
                },
                child: const Icon(CupertinoIcons.trash,
                    color: mauDoHong, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Cf extends StatelessWidget {
  final TextEditingController ctrl;
  final String ph;
  const _Cf({required this.ctrl, required this.ph});

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
