import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class BaoCao extends StatefulWidget {
  const BaoCao({super.key});
  @override
  State<BaoCao> createState() => _BaoCaoState();
}

class _BaoCaoState extends State<BaoCao> {
  bool _dangTai = true;
  List<Ve> _tatCaVe = [];
  // Key: ngay string, Value: revenue
  final Map<String, int> _doanhThu7Ngay = {};
  final Map<String, int> _soVe7Ngay = {};
  Map<String, int> _topTuyen = {};

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaVe();
      if (!mounted) return;
      // Build 7-day stats
      final now = DateTime.now();
      final thu = <String, int>{};
      final soV = <String, int>{};
      for (var d = 6; d >= 0; d--) {
        final day = now.subtract(Duration(days: d));
        final key = '${day.day}/${day.month}/${day.year}';
        thu[key] = 0;
        soV[key] = 0;
      }
      final tuyenCount = <String, int>{};
      for (final ve in ds) {
        final kN = ve.ngay;
        if (thu.containsKey(kN)) {
          soV[kN] = (soV[kN] ?? 0) + 1;
          if (ve.trangThai == 'hoan_thanh') {
            thu[kN] = (thu[kN] ?? 0) + ve.tongTien;
          }
        }
        final tk = '${ve.diemDi} → ${ve.diemDen}';
        tuyenCount[tk] = (tuyenCount[tk] ?? 0) + 1;
      }
      final sorted = tuyenCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (!mounted) return;
      setState(() {
        _tatCaVe = ds;
        _doanhThu7Ngay
          ..clear()
          ..addAll(thu);
        _soVe7Ngay
          ..clear()
          ..addAll(soV);
        _topTuyen = Map.fromEntries(sorted.take(5));
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  String _tien(int t) {
    if (t == 0) return '0đ';
    final s = t.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}đ';
  }

  int get _tongDoanhThu => _tatCaVe
      .where((v) => v.trangThai == 'hoan_thanh')
      .fold(0, (s, v) => s + v.tongTien);

  int get _tongVe => _tatCaVe.length;
  int get _veHT =>
      _tatCaVe.where((v) => v.trangThai == 'hoan_thanh').length;

  double get _tiLeHT =>
      _tongVe == 0 ? 0 : _veHT / _tongVe;

  @override
  Widget build(BuildContext context) {
    final maxThu = _doanhThu7Ngay.values.isEmpty
        ? 1
        : _doanhThu7Ngay.values
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, double.maxFinite)
            .toInt();

    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Báo cáo & Thống kê',
            style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _tai,
          child: const Icon(CupertinoIcons.arrow_clockwise,
              color: mauXanhSang, size: 18),
        ),
      ),
      child: _dangTai
          ? const Center(
              child: CupertinoActivityIndicator(
                  radius: 14, color: mauXanhSang))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Tổng quát
                const Text('Tổng quát',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      mau: mauXanhSang,
                      so: _tien(_tongDoanhThu),
                      nhan: 'Tổng doanh thu',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: CupertinoIcons.ticket_fill,
                      mau: const Color(0xFFFF9800),
                      so: '$_tongVe',
                      nhan: 'Tổng số vé',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatCard(
                      icon: CupertinoIcons.checkmark_seal_fill,
                      mau: const Color(0xFF00C853),
                      so: '$_veHT',
                      nhan: 'Vé hoàn thành',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: CupertinoIcons.chart_bar_fill,
                      mau: const Color(0xFF9C27B0),
                      so: '${(_tiLeHT * 100).toStringAsFixed(1)}%',
                      nhan: 'Tỉ lệ hoàn thành',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 7 ngày gần nhất
                const Text('Doanh thu 7 ngày gần nhất',
                    style: TextStyle(
                        color: mauTextTrang,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: Column(
                    children: _doanhThu7Ngay.entries.map((e) {
                      final pct =
                          maxThu == 0 ? 0.0 : e.value / maxThu;
                      final parts = e.key.split('/');
                      final label =
                          parts.length >= 2 ? '${parts[0]}/${parts[1]}' : e.key;
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(label,
                                  style: const TextStyle(
                                      color: mauTextXam,
                                      fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 18,
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: pct
                                          .clamp(0.02, 1.0)
                                          .toDouble(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: gradientChinh,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _tien(e.value),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: e.value > 0
                                      ? mauXanhSang
                                      : mauTextXam,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Top tuyến
                if (_topTuyen.isNotEmpty) ...[
                  const Text('Top tuyến đặt nhiều nhất',
                      style: TextStyle(
                          color: mauTextTrang,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: mauCardNen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: mauCardVien),
                    ),
                    child: Column(
                      children:
                          _topTuyen.entries.toList().asMap().entries.map((entry) {
                        final idx = entry.key;
                        final e = entry.value;
                        final medals = ['🥇', '🥈', '🥉', '4.', '5.'];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: idx <
                                    _topTuyen.length - 1
                                ? const Border(
                                    bottom: BorderSide(
                                        color: mauCardVien))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(medals[idx],
                                  style: const TextStyle(
                                      fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(e.key,
                                    style: const TextStyle(
                                        color: mauTextTrang,
                                        fontSize: 13)),
                              ),
                              Text('${e.value} vé',
                                  style: const TextStyle(
                                      color: mauXanhSang,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color mau;
  final String so;
  final String nhan;
  const _StatCard(
      {required this.icon,
      required this.mau,
      required this.so,
      required this.nhan});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mauCardNen,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: mau.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: mau, size: 22),
              const SizedBox(height: 10),
              Text(so,
                  style: TextStyle(
                      color: mau,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(nhan,
                  style: const TextStyle(
                      color: mauTextXam, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
