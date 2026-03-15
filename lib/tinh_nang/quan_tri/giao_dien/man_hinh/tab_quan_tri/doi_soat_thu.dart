import 'package:flutter/cupertino.dart';
import '../../../../../cau_hinh/hang_so.dart';
import '../../../../../du_lieu/co_so_du_lieu.dart';

class DoiSoatThu extends StatefulWidget {
  const DoiSoatThu({super.key});
  @override
  State<DoiSoatThu> createState() => _DoiSoatThuState();
}

class _DoiSoatThuState extends State<DoiSoatThu> {
  int _kyChon = 0; // 0=hôm nay, 1=7 ngày, 2=30 ngày
  bool _dangTai = true;
  List<Ve> _ds = [];

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      List<Ve> all = [];
      // Chế độ hôm nay dùng query theo ngày; 7/30 ngày lọc theo ngày đặt sau khi tải tổng.
      if (_kyChon == 0) {
        final n = DateTime.now();
        all = await CoSoDuLieu()
            .layTatCaVe(ngay: '${n.day}/${n.month}/${n.year}');
      } else {
        all = await CoSoDuLieu().layTatCaVe();
        final days = _kyChon == 1 ? 7 : 30;
        final cutoff = DateTime.now().subtract(Duration(days: days));
        all = all.where((v) {
          try {
            final parts = v.ngayDat.split('/');
            if (parts.length < 3) return true;
            final d = DateTime(int.parse(parts[2]),
                int.parse(parts[1]), int.parse(parts[0]));
            return d.isAfter(cutoff);
          } catch (_) {
            return true;
          }
        }).toList();
      }
      if (!mounted) return;
      setState(() {
        _ds = all;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  String _tien(int t) {
    final s = t.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '$kqđ';
  }

  int get _tongThu => _ds
      .where((v) => v.trangThai == 'hoan_thanh')
      .fold(0, (s, v) => s + v.tongTien);

  int get _soHT =>
      _ds.where((v) => v.trangThai == 'hoan_thanh').length;
  int get _soCho => _ds.where((v) => v.trangThai == 'cho').length;
  int get _soHuy => _ds.where((v) => v.trangThai == 'huy').length;
  int get _soBoLo => _ds.where((v) => v.trangThai == 'bo_lo').length;

  void _xuatTongKet() {
    // Hiển thị snapshot đối soát nhanh theo kỳ đang chọn.
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Tổng kết đối soát'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Kỳ: ${["Hôm nay", "7 ngày", "30 ngày"][_kyChon]}'),
            const SizedBox(height: 6),
            Text('Tổng doanh thu: ${_tien(_tongThu)}'),
            Text('Vé hoàn thành: $_soHT'),
            Text('Vé chờ: $_soCho'),
            Text('Bỏ lỡ: $_soBoLo'),
            Text('Đã hủy: $_soHuy'),
            Text('Tổng giao dịch: ${_ds.length}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Đóng'),
          ),
        ],
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
        middle: const Text('Thanh toán & Đối soát',
            style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _xuatTongKet,
          child: const Icon(CupertinoIcons.doc_text,
              color: mauXanhSang, size: 20),
        ),
      ),
      child: Column(
        children: [
          Container(
            color: mauNenToi2,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _kyChon,
              backgroundColor: mauNenToi,
              children: const {
                0: Text('Hôm nay', style: TextStyle(fontSize: 13)),
                1: Text('7 ngày', style: TextStyle(fontSize: 13)),
                2: Text('30 ngày', style: TextStyle(fontSize: 13)),
              },
              onValueChanged: (v) {
                if (v != null) {
                  setState(() => _kyChon = v);
                  _tai();
                }
              },
            ),
          ),
          if (!_dangTai) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: gradientChinh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Doanh thu',
                      style: TextStyle(
                          color: Color(0xB3FFFFFF), fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(_tien(_tongThu),
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Chip(_soHT, 'hoàn thành',
                          const Color(0xFF00C853)),
                      const SizedBox(width: 8),
                      _Chip(_soCho, 'chờ', mauCam),
                      const SizedBox(width: 8),
                      _Chip(_soHuy, 'hủy', mauDoHong),
                    ],
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: _dangTai
                ? const Center(
                    child: CupertinoActivityIndicator(
                        radius: 14, color: mauXanhSang))
                : _ds.isEmpty
                    ? const Center(
                        child: Text('Không có giao dịch nào',
                            style: TextStyle(color: mauTextXam)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 24),
                        itemCount: _ds.length,
                        itemBuilder: (_, i) {
                          final ve = _ds[i];
                          final ok = ve.trangThai == 'hoan_thanh';
                          return Container(
                            margin:
                                const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: mauCardNen,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                  color: mauCardVien),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ve.maVe,
                                          style: const TextStyle(
                                              color: mauXanhSang,
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 12)),
                                      Text(
                                          '${ve.diemDi} → ${ve.diemDen}  •  ${ve.ngay}',
                                          style: const TextStyle(
                                              color: mauTextTrang,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  ok ? _tien(ve.tongTien) : '—',
                                  style: TextStyle(
                                    color: ok
                                        ? const Color(0xFF00C853)
                                        : mauTextXam,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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
    );
  }
}

class _Chip extends StatelessWidget {
  final int so;
  final String nhan;
  final Color mau;
  const _Chip(this.so, this.nhan, this.mau);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: mau.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mau.withAlpha(100)),
        ),
        child: Text('$so $nhan',
            style: TextStyle(
                color: mau,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}
