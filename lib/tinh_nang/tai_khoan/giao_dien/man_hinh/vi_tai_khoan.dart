import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';

class ViTaiKhoan extends StatefulWidget {
  const ViTaiKhoan({Key? key}) : super(key: key);

  @override
  State<ViTaiKhoan> createState() => _ViTaiKhoanState();
}

class _ViTaiKhoanState extends State<ViTaiKhoan> {
  final _db = CoSoDuLieu();
  final _soTienController = TextEditingController();
  String _phuongThucChon = 'momo';
  bool _dangXuLy = false;

  List<GoiNap> _goiNap = [];
  List<GiaoDich> _danhSachGiaoDich = [];

  @override
  void initState() {
    super.initState();
    _db.taoGoiNapMacDinh();
    _taiGoiNap();
    _taiGiaoDich();
  }

  Future<void> _taiGoiNap() async {
    final goi = await _db.layGoiNapHoatDong();
    setState(() => _goiNap = goi);
  }

  Future<void> _taiGiaoDich() async {
    final user = TrangThaiUngDung().nguoiDungHienTai;
    if (user != null) {
      final gd = await _db.layDanhSachGiaoDich(user.id!);
      setState(() => _danhSachGiaoDich = gd);
    }
  }

  Future<void> _napTien(double soTien) async {
    if (soTien <= 0) {
      _thongBao('Vui lòng nhập số tiền hợp lệ');
      return;
    }

    setState(() => _dangXuLy = true);

    try {
      final user = TrangThaiUngDung().nguoiDungHienTai;
      if (user == null) return;

      final success = await _db.napTien(
        userId: user.id!,
        soTien: soTien,
        phuongThuc: _phuongThucChon,
        moTa: 'Nạp tiền vào ví - $_phuongThucChon',
      );

      if (success) {
        _thongBao('Nạp tiền thành công!');
        _soTienController.clear();
        await _taiGiaoDich();
        // Update balance in state
        final soDuMoi = await _db.laySoDuVi(user.id!);
        TrangThaiUngDung().capNhatNguoiDung(user.copyWith(sotien: soDuMoi));
      } else {
        _thongBao('Nạp tiền thất bại. Vui lòng thử lại');
      }
    } catch (e) {
      _thongBao('Lỗi: $e');
    } finally {
      setState(() => _dangXuLy = false);
    }
  }

  void _thongBao(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  String _dinhDangTien(double soTien) {
    if (soTien >= 1000000) {
      return '${(soTien / 1000000).toStringAsFixed(1)}M';
    } else if (soTien >= 1000) {
      return '${(soTien / 1000).toStringAsFixed(0)}k';
    }
    return soTien.toStringAsFixed(0);
  }

  String _getIconPhuongThuc(String pt) {
    switch (pt) {
      case 'momo':
        return '💰';
      case 'zalopay':
        return '💳';
      case 'vnpay':
        return '🏦';
      case 'vi':
        return '👝';
      default:
        return '💵';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: mauNenToi2.withAlpha(230),
              border: null,
              largeTitle: const Text(
                'Ví Điện Tử',
                style: TextStyle(color: mauTextTrang),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardSoDu(),
                    const SizedBox(height: 24),
                    _buildSectionNapTien(),
                    const SizedBox(height: 24),
                    _buildSectionGiaoDich(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSoDu() {
    final soDu = TrangThaiUngDung().nguoiDungHienTai?.sotien ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mauCardVien),
        boxShadow: [
          BoxShadow(
            color: mauXanhChinh.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số dư ví',
            style: TextStyle(
              color: mauTextXam,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_dinhDangTien(soDu)}đ',
            style: const TextStyle(
              color: mauTextTrang,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${soDu.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} đ',
            style: const TextStyle(
              color: mauTextXam,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionNapTien() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nạp tiền nhanh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mauTextTrang,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: _goiNap
              .map((goi) => _buildNutGoiNap(goi.soTien, goi.tieuDe))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nhập số tiền tùy chọn',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: mauTextTrang,
          ),
        ),
        const SizedBox(height: 12),
        CupertinoTextField(
          controller: _soTienController,
          keyboardType: TextInputType.number,
          placeholder: 'Nhập số tiền...',
          placeholderStyle: const TextStyle(color: mauTextXam),
          style: const TextStyle(color: mauTextTrang),
          prefix: const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 4, 0),
            child: Text('đ', style: TextStyle(color: mauTextXam)),
          ),
          decoration: BoxDecoration(
            color: mauNenToi,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: mauCardVien),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Phương thức nạp tiền',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: mauTextTrang,
          ),
        ),
        const SizedBox(height: 12),
        _buildPhuongThucThanhToan(),
        const SizedBox(height: 20),
        NutGradient(
          nhanDe: _dangXuLy ? 'Đang xử lý...' : 'Nạp tiền',
          chieuRong: double.infinity,
          onNhan: _dangXuLy
              ? null
              : () {
                  final soTien = double.tryParse(_soTienController.text) ?? 0;
                  _napTien(soTien);
                },
        ),
      ],
    );
  }

  Widget _buildNutGoiNap(double soTien, String tieuDe) {
    return GestureDetector(
      onTap: () => _napTien(soTien),
      child: Container(
        decoration: BoxDecoration(
          color: mauCardNen,
          border: Border.all(color: mauCardVien),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tieuDe,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mauTextTrang,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nạp ngay',
              style: TextStyle(
                fontSize: 12,
                color: mauTextXam,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhuongThucThanhToan() {
    final phuongThuc = [
      {'id': 'momo', 'ten': 'Momo', 'icon': '💰'},
      {'id': 'zalopay', 'ten': 'ZaloPay', 'icon': '💳'},
      {'id': 'vnpay', 'ten': 'VNPay', 'icon': '🏦'},
      {'id': 'the_ngan_hang', 'ten': 'Thẻ ngân hàng', 'icon': '🏧'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: phuongThuc
          .map((pt) => GestureDetector(
                onTap: () => setState(() => _phuongThucChon = pt['id']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _phuongThucChon == pt['id']
                        ? mauXanhChinh
                        : mauCardNen,
                    border: Border.all(
                      color: _phuongThucChon == pt['id']
                          ? mauXanhSang
                          : mauCardVien,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pt['icon']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        pt['ten']!,
                        style: TextStyle(
                          color: _phuongThucChon == pt['id']
                              ? mauTextTrang
                              : mauTextXam,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSectionGiaoDich() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mauTextTrang,
          ),
        ),
        const SizedBox(height: 12),
        if (_danhSachGiaoDich.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: const Text(
              'Chưa có giao dịch nào',
              style: TextStyle(color: mauTextXam),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _danhSachGiaoDich.length,
            itemBuilder: (context, index) {
              final gd = _danhSachGiaoDich[index];
              return _buildItemGiaoDich(gd);
            },
          ),
      ],
    );
  }

  Widget _buildItemGiaoDich(GiaoDich gd) {
    final iamount = gd.loai == 'nap' || gd.loai == 'hoan_tien' ? '+' : '-';
    final isPositive = gd.loai == 'nap' || gd.loai == 'hoan_tien';
    final color = isPositive ? mauXanhLa : mauDoHong;

    final tenLoai = gd.loai == 'nap'
        ? 'Nạp tiền'
        : gd.loai == 'thanh_toan'
            ? 'Thanh toán vé'
            : 'Hoàn tiền';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mauCardVien),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getIconPhuongThuc(gd.loai),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenLoai,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: mauTextTrang,
                  ),
                ),
                Text(
                  gd.ngayTao,
                  style: const TextStyle(
                    color: mauTextXam,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$iamount${_dinhDangTien(gd.soTien)}đ',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: gd.trangThai == 'thanh_cong'
                      ? mauXanhLa.withAlpha(25)
                      : gd.trangThai == 'that_bai'
                          ? mauDoHong.withAlpha(25)
                          : mauCam.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  gd.trangThai == 'thanh_cong'
                      ? 'Thành công'
                      : gd.trangThai == 'that_bai'
                          ? 'Thất bại'
                          : 'Đang xử lý',
                  style: TextStyle(
                    fontSize: 10,
                    color: gd.trangThai == 'thanh_cong'
                        ? mauXanhLa
                        : gd.trangThai == 'that_bai'
                            ? mauDoHong
                            : mauCam,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _soTienController.dispose();
    super.dispose();
  }
}
