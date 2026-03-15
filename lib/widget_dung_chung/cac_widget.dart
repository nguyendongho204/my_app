import 'package:flutter/cupertino.dart';

import '../cau_hinh/hang_so.dart';

/// Widget vong tron pulse giong Shazam (hieu ung song lan toa ra)
class VongTronPulse extends StatefulWidget {
  final double kichThuoc;
  final Widget? noiDungTrungTam;
  final List<Color> mauGradient;

  const VongTronPulse({
    super.key,
    this.kichThuoc = 200,
    this.noiDungTrungTam,
    this.mauGradient = const [Color(0xFF1565C0), Color(0xFF6A1B9A)],
  });

  @override
  State<VongTronPulse> createState() => _VongTronPulseState();
}

class _VongTronPulseState extends State<VongTronPulse>
    with TickerProviderStateMixin {
  late AnimationController _bdk1;
  late AnimationController _bdk2;
  late AnimationController _bdk3;
  late Animation<double> _hieuUngTo;
  late Animation<double> _hieuUngMoDan;

  @override
  void initState() {
    super.initState();

    _bdk1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bdk2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bdk3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _hieuUngTo = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _bdk1, curve: Curves.easeOut),
    );

    _hieuUngMoDan = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _bdk2, curve: Curves.easeOut),
    );

    // Làn sóng thứ 2 trễ pha để hiệu ứng pulse tự nhiên hơn.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _bdk2.repeat();
    });
  }

  @override
  void dispose() {
    _bdk1.dispose();
    _bdk2.dispose();
    _bdk3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.kichThuoc * 2,
      height: widget.kichThuoc * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _bdk1,
            builder: (context, child) {
              return Opacity(
                opacity: _hieuUngMoDan.value,
                child: Container(
                  width: widget.kichThuoc * _hieuUngTo.value,
                  height: widget.kichThuoc * _hieuUngTo.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.mauGradient[0].withAlpha(128),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bdk2,
            builder: (context, child) {
              final scale = 0.8 + _bdk2.value * 0.7;
              final opacity = (1 - _bdk2.value) * 0.4;
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: widget.kichThuoc * scale,
                  height: widget.kichThuoc * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.mauGradient[1].withAlpha(102),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: widget.kichThuoc * 1.1,
            height: widget.kichThuoc * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.mauGradient[0].withAlpha(38),
                  const Color(0x00000000),
                ],
              ),
            ),
          ),
          Container(
            width: widget.kichThuoc,
            height: widget.kichThuoc,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.mauGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.mauGradient[0].withAlpha(128),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: widget.mauGradient[1].withAlpha(77),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: widget.noiDungTrungTam,
          ),
        ],
      ),
    );
  }
}

/// Card tuyen xe phong cach toi
class CardTuyenXe extends StatelessWidget {
  final String diemDi;
  final String diemDen;
  final String gioKhoiHanh;
  final String gia;
  final String loaiXe;
  final VoidCallback? onNhan;

  const CardTuyenXe({
    super.key,
    required this.diemDi,
    required this.diemDen,
    required this.gioKhoiHanh,
    required this.gia,
    required this.loaiXe,
    this.onNhan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNhan,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Xuất phát',
                          style: TextStyle(color: mauTextXam, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(diemDi,
                          style: const TextStyle(
                              color: mauTextTrang,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(CupertinoIcons.arrow_right,
                        color: mauXanhSang, size: 20),
                    Text(gioKhoiHanh,
                        style: const TextStyle(
                            color: mauXanhSang,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Điểm đến',
                          style: TextStyle(color: mauTextXam, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(diemDen,
                          style: const TextStyle(
                              color: mauTextTrang,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 0.5, color: mauCardVien),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.bus,
                        color: mauTextXam, size: 16),
                    const SizedBox(width: 4),
                    Text(loaiXe,
                        style: const TextStyle(color: mauTextXam, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: gradientChinh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(gia,
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Nut gradient giong Shazam
class NutGradient extends StatelessWidget {
  final String nhanDe;
  final VoidCallback? onNhan;
  final List<Color> mau;
  final double? chieuRong;
  final IconData? bieuTuong;

  const NutGradient({
    super.key,
    required this.nhanDe,
    this.onNhan,
    this.mau = const [Color(0xFF1565C0), Color(0xFF6A1B9A)],
    this.chieuRong,
    this.bieuTuong,
  });

  @override
  Widget build(BuildContext context) {
    // Hỗ trợ trạng thái disabled khi onNhan = null bằng giảm độ mờ.
    return GestureDetector(
      onTap: onNhan,
      child: Container(
        // Giữ độ tương phản tốt giữa các màn hình sáng/tối nhờ gradient mặc định.
        width: chieuRong,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: mau),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: mau[0].withAlpha(102),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: bieuTuong != null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (bieuTuong != null) ...[
              Icon(bieuTuong, color: CupertinoColors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              nhanDe,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// O tim kiem phong cach toi
class OTimKiem extends StatelessWidget {
  final String goiY;
  final TextEditingController? boDieuKhien;
  final ValueChanged<String>? khiThayDoi;
  final IconData bieuTuong;

  const OTimKiem({
    super.key,
    required this.goiY,
    this.boDieuKhien,
    this.khiThayDoi,
    this.bieuTuong = CupertinoIcons.search,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mauCardVien),
      ),
      child: CupertinoTextField(
        controller: boDieuKhien,
        onChanged: khiThayDoi,
        style: const TextStyle(color: mauTextTrang),
        placeholder: goiY,
        placeholderStyle: const TextStyle(color: mauTextXamNhat),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(bieuTuong, color: mauTextXam, size: 18),
        ),
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}