import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../tinh_nang/dang_nhap/model/nguoi_dung_model.dart';

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
    final user = context.read<NguoiDungModel>().nguoiDung;
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
      final user = context.read<NguoiDungModel>().nguoiDung;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví Điện Tử'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- CARD SO DU ----------
            _buildCardSoDu(),
            const SizedBox(height: 24),

            // ---------- NAP TIEN ----------
            _buildSectionNapTien(),
            const SizedBox(height: 24),

            // ---------- GIAO DICH GAN DAY ----------
            _buildSectionGiaoDich(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSoDu() {
    return Consumer<NguoiDungModel>(
      builder: (context, model, _) {
        final soDu = model.nguoiDung?.sotien ?? 0.0;
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
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
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_dinhDangTien(soDu)}đ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${soDu.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} đ',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionNapTien() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nạp tiền nhanh',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

        // ---------- NAP TUY CHON ----------
        const Text(
          'Nhập số tiền tùy chọn',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _soTienController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập số tiền...',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // ---------- CHON PHUONG THUC ----------
        const Text(
          'Phương thức nạp tiền',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildPhuongThucThanhToan(),
        const SizedBox(height: 20),

        // ---------- NUT NAP TIEN ----------
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _dangXuLy
                ? null
                : () {
                    final soTien = double.tryParse(_soTienController.text) ?? 0;
                    _napTien(soTien);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _dangXuLy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Nạp tiền',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutGoiNap(double soTien, String tieuDe) {
    return GestureDetector(
      onTap: () => _napTien(soTien),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
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
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nạp ngay',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
                        ? Colors.blue
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: _phuongThucChon == pt['id']
                          ? Colors.blue
                          : Colors.grey.shade300,
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
                              ? Colors.white
                              : Colors.black,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_danhSachGiaoDich.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: const Text(
              'Chưa có giao dịch nào',
              style: TextStyle(color: Colors.grey),
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
    final color = gd.loai == 'nap' || gd.loai == 'hoan_tien'
        ? Colors.green
        : Colors.red;

    final tenLoai = gd.loai == 'nap'
        ? 'Nạp tiền'
        : gd.loai == 'thanh_toan'
            ? 'Thanh toán vé'
            : 'Hoàn tiền';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                  ),
                ),
                Text(
                  gd.ngayTao,
                  style: const TextStyle(
                    color: Colors.grey,
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
                      ? Colors.green.shade100
                      : gd.trangThai == 'that_bai'
                          ? Colors.red.shade100
                          : Colors.orange.shade100,
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
                        ? Colors.green
                        : gd.trangThai == 'that_bai'
                            ? Colors.red
                            : Colors.orange,
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
