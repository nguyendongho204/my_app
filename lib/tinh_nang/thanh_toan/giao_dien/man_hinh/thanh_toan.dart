import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../du_lieu/co_so_du_lieu.dart';
import '../../../../widget_dung_chung/cac_widget.dart';

class ThanhToan extends StatefulWidget {
  final Map<String, dynamic> chuyen;
  final String diemDi;
  final String diemDen;
  final DateTime ngay;
  final List<int> gheChon;
  final List<Map<String, dynamic>> loaiXe;

  const ThanhToan({
    super.key,
    required this.chuyen,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
    required this.gheChon,
    required this.loaiXe,
  });

  @override
  State<ThanhToan> createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  late int _giaThucTe;
  int _ptThanhToan = 0; // 0: Vi, 1: The, 2: TTKH
  bool _dangXuLy = false;
  late int _loaiXeChon;

  @override
  void initState() {
    super.initState();
    _loaiXeChon = widget.chuyen['loaiXeChon'] ?? 0;
    _tinhGia();
  }

  void _tinhGia() {
    final loaiXe = widget.loaiXe[_loaiXeChon];
    _giaThucTe = (loaiXe['gia'] as num).toInt() * widget.gheChon.length;
  }

  void _thongBao(String msg, {bool laLoi = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: laLoi ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _xacNhan() async {
    setState(() => _dangXuLy = true);

    try {
      // Neu chon thanh toan bang vi: kiem tra so du
      if (_ptThanhToan == 0) {
        final nd = TrangThaiUngDung().nguoiDungHienTai;
        if (nd == null) return;
        
        final soDuVi = nd.sotien ?? 0.0;
        if (soDuVi < _giaThucTe) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Số dư không đủ'),
              content: Text(
                'Số dư ví của bạn là ${(soDuVi / 1000).toStringAsFixed(0)}k\n'
                'Vui lòng nạp thêm tiền vào ví hoặc chọn phương thức thanh toán khác.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          setState(() => _dangXuLy = false);
          return;
        }

        // Thanh toan bang vi
        final success = await CoSoDuLieu().thanhToanVeBangVi(
          userId: nd.id!,
          maVe: 'VE_${DateTime.now().millisecondsSinceEpoch}',
          soTien: _giaThucTe.toDouble(),
        );

        if (!success) {
          _thongBao('Thanh toán thất bại. Vui lòng thử lại', laLoi: true);
          setState(() => _dangXuLy = false);
          return;
        }

        // Cap nhat so du
        final soDuMoi = await CoSoDuLieu().laySoDuVi(nd.id!);
        TrangThaiUngDung().capNhatNguoiDung(nd.copyWith(sotien: soDuMoi));
      }

      // Gia lap giao dich thanh cong
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      _thongBao('Thanh toán thành công!');

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      _thongBao('Lỗi: $e', laLoi: true);
    } finally {
      setState(() => _dangXuLy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chi tiet chuyen di
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết chuyến đi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildRow('Từ', widget.diemDi),
                    _buildRow('Đến', widget.diemDen),
                    _buildRow(
                      'Ngày',
                      '${widget.ngay.day}/${widget.ngay.month}/${widget.ngay.year}',
                    ),
                    _buildRow('Ghế chọn', widget.gheChon.map((g) => 'A${g + 1}').join(', ')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gia tien
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Giá vé (x${1}):'),
                        Text('${(_giaThucTe / 1000).toStringAsFixed(0)}k đ'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${(_giaThucTe / 1000).toStringAsFixed(0)}k đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phuong thuc thanh toan
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPhuongThuc(),
            const SizedBox(height: 24),

            // Nut xac nhan
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _dangXuLy ? null : _xacNhan,
                child: _dangXuLy
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text('Xác Nhận Thanh Toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPhuongThuc() {
    return Column(
      children: [
        _buildOption(0, 'Ví Điện Tử', 'Thanh toán nhanh bằng ví'),
        _buildOption(1, 'Thẻ Tín Dụng/Ghi Nợ', 'Thanh toán bằng thẻ ngân hàng'),
        _buildOption(2, 'Tài Khoản Ngân Hàng', 'Chuyển khoản trực tiếp'),
      ],
    );
  }

  Widget _buildOption(int index, String title, String subtitle) {
    return GestureDetector(
      onTap: () => setState(() => _ptThanhToan = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _ptThanhToan == index ? CupertinoColors.systemBlue : Colors.grey[300]!,
            width: _ptThanhToan == index ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _ptThanhToan == index ? CupertinoColors.systemBlue.withAlpha(26) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _ptThanhToan == index ? CupertinoColors.systemBlue : Colors.grey[300]!,
                ),
              ),
              child: _ptThanhToan == index
                  ? const Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
