import 'package:flutter/cupertino.dart';
import 'package:my_app/du_lieu/co_so_du_lieu.dart';
import 'package:my_app/cau_hinh/hang_so.dart';

class KhuyenMaiScreen extends StatefulWidget {
  const KhuyenMaiScreen({super.key});

  @override
  State<KhuyenMaiScreen> createState() => _KhuyenMaiScreenState();
}

class _KhuyenMaiScreenState extends State<KhuyenMaiScreen> {
  bool _dangTai = true;
  List<KhuyenMai> _ds = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaKhuyenMai();
      if (!mounted) return;
      setState(() {
        _ds = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Color _mauTrangThai(String tt) {
    switch (tt) {
      case 'hoat_dong':
        return const Color(0xFF00C853);
      case 'tam_dung':
        return const Color(0xFFFF9800);
      default:
        return mauDoHong;
    }
  }

  String _nhanTrangThai(String tt) {
    switch (tt) {
      case 'hoat_dong':
        return '  ộng';
      case 'tam_dung':
        return 'Tạm dừng';
      default:
        return 'Hết hạn';
    }
  }

  String _nhanMucGiam(KhuyenMai km) {
    if (km.loaiGiam == 'phan_tram') return '-${km.giaTriGiam}%';
    return '-${km.giaTriGiam}đ';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Khuyến mãi', style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _tai,
          child: const Icon(CupertinoIcons.arrow_clockwise, color: mauXanhSang, size: 18),
        ),
      ),
      child: _dangTai
          ? const Center(child: CupertinoActivityIndicator(radius: 14, color: mauXanhSang))
          : _ds.isEmpty
              ? const Center(
                  child: Text('Chưa có khuyến mãi nào', style: TextStyle(color: mauTextXam)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ds.length,
                  itemBuilder: (_, i) {
                    final km = _ds[i];
                    final mau = _mauTrangThai(km.trangThai);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mauCardNen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mau.withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: gradientChinh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              km.ma,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  km.ten,
                                  style: const TextStyle(
                                    color: mauTextTrang,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${_nhanMucGiam(km)} • ${km.daSuDung}/${km.gioiHanSuDung == 0 ? '∞' : km.gioiHanSuDung} lượt',
                                  style: const TextStyle(color: mauTextXam, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mau.withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _nhanTrangThai(km.trangThai),
                              style: TextStyle(
                                color: mau,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
