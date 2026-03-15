import 'package:flutter/cupertino.dart';
import '../../../../../cau_hinh/hang_so.dart';
import '../../../../../du_lieu/co_so_du_lieu.dart';

class BaoCao extends StatefulWidget {
  const BaoCao({super.key});
  @override
  State<BaoCao> createState() => _BaoCaoState();
}

class _BaoCaoState extends State<BaoCao> {
  bool _dangTai = true;
  List<Ve> _tatCaVe = [];
  DateTime _ngayChon = DateTime.now();
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
      // Khởi tạo khung 7 ngày lùi từ ngày chọn để đổ dữ liệu doanh thu/số vé.
      final moc = DateTime(_ngayChon.year, _ngayChon.month, _ngayChon.day);
      final thu = <String, int>{};
      final soV = <String, int>{};
      for (var d = 6; d >= 0; d--) {
        final day = moc.subtract(Duration(days: d));
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
    return '$kqđ';
  }

  String _thangTiengViet(int thang) {
    const tenThang = [
      'Một',
      'Hai',
      'Ba',
      'Tư',
      'Năm',
      'Sáu',
      'Bảy',
      'Tám',
      'Chín',
      'Mười',
      'Mười một',
      'Mười hai',
    ];
    if (thang < 1 || thang > 12) return '';
    return tenThang[thang - 1];
  }

  String get _ngayStr {
    final d = _ngayChon.day;
    final m = _thangTiengViet(_ngayChon.month);
    final y = _ngayChon.year;
    return 'ngày $d tháng $m năm $y';
  }

  int _soNgayTrongThang(int nam, int thang) =>
      DateTime(nam, thang + 1, 0).day;

  Future<void> _moChonNgay() async {
    // Bộ chọn ngày tự giới hạn theo thời điểm hiện tại để tránh chọn ngày tương lai.
    final now = DateTime.now();
    const minNam = 2000;
    int nam = _ngayChon.year;
    int thang = _ngayChon.month;
    int ngay = _ngayChon.day;

    final dayCtrl = FixedExtentScrollController(initialItem: ngay - 1);
    final monthCtrl = FixedExtentScrollController(initialItem: thang - 1);
    final yearCtrl =
        FixedExtentScrollController(initialItem: nam - minNam);

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setM) {
          final maxNam = now.year;
          final isThangToiDa = nam == now.year;
          final maxThang = isThangToiDa ? now.month : 12;
          final maxNgay = _soNgayTrongThang(nam, thang);
          final isNgayToiDa = isThangToiDa && thang == now.month;
          final ngayToiDa = isNgayToiDa ? now.day : maxNgay;

          if (ngay > ngayToiDa) {
            ngay = ngayToiDa;
            dayCtrl.jumpToItem(ngay - 1);
          }

          return Container(
            height: 320,
            color: mauCardNen,
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: dayCtrl,
                          itemExtent: 34,
                          onSelectedItemChanged: (i) {
                            setM(() => ngay = i + 1);
                          },
                          children: List.generate(ngayToiDa, (i) {
                            return Center(
                              child: Text('ngày ${i + 1}',
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 18)),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: monthCtrl,
                          itemExtent: 34,
                          onSelectedItemChanged: (i) {
                            setM(() {
                              final thangMoi = i + 1;
                              thang = thangMoi > maxThang ? maxThang : thangMoi;
                              final maxNgayMoi = _soNgayTrongThang(nam, thang);
                              final ngayToiDaMoi =
                                  (nam == now.year && thang == now.month)
                                      ? now.day
                                      : maxNgayMoi;
                              if (ngay > ngayToiDaMoi) {
                                ngay = ngayToiDaMoi;
                                dayCtrl.jumpToItem(ngay - 1);
                              }
                            });
                          },
                          children: List.generate(maxThang, (i) {
                            return Center(
                              child: Text('tháng ${i + 1}',
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 18)),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: yearCtrl,
                          itemExtent: 34,
                          onSelectedItemChanged: (i) {
                            setM(() {
                              nam = minNam + i;
                              if (nam > maxNam) nam = maxNam;
                              if (nam == now.year && thang > now.month) {
                                thang = now.month;
                                monthCtrl.jumpToItem(thang - 1);
                              }
                              final maxNgayMoi = _soNgayTrongThang(nam, thang);
                              final ngayToiDaMoi =
                                  (nam == now.year && thang == now.month)
                                      ? now.day
                                      : maxNgayMoi;
                              if (ngay > ngayToiDaMoi) {
                                ngay = ngayToiDaMoi;
                                dayCtrl.jumpToItem(ngay - 1);
                              }
                            });
                          },
                          children: List.generate(maxNam - minNam + 1, (i) {
                            final y = minNam + i;
                            return Center(
                              child: Text('năm $y',
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 18)),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {
                      _ngayChon = DateTime(nam, thang, ngay);
                    });
                    _tai();
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          );
        },
      ),
    );

    dayCtrl.dispose();
    monthCtrl.dispose();
    yearCtrl.dispose();
  }

  int get _tongDoanhThu => _tatCaVe
      .where((v) => v.trangThai == 'hoan_thanh')
      .fold(0, (s, v) => s + v.tongTien);

  int get _tongVe => _tatCaVe.length;
  int get _veHT =>
      _tatCaVe.where((v) => v.trangThai == 'hoan_thanh').length;

  double get _tiLeHT => _tongVe == 0 ? 0 : _veHT / _tongVe;

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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _moChonNgay,
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.calendar,
                                color: mauXanhSang, size: 16),
                            const SizedBox(width: 6),
                            Text(_ngayStr,
                                style: const TextStyle(
                                    color: mauXanhSang,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_down,
                                color: mauXanhSang, size: 12),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('Mốc báo cáo',
                          style: TextStyle(color: mauTextXam, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                      final pct = maxThu == 0 ? 0.0 : e.value / maxThu;
                      final parts = e.key.split('/');
                      final label = parts.length >= 2 ? '${parts[0]}/${parts[1]}' : e.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(label,
                                  style: const TextStyle(
                                      color: mauTextXam, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 18,
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: pct.clamp(0.02, 1.0).toDouble(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: gradientChinh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _tien(e.value),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: e.value > 0 ? mauXanhSang : mauTextXam,
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
                      children: _topTuyen.entries.toList().asMap().entries.map((entry) {
                        final idx = entry.key;
                        final e = entry.value;
                        final medals = ['🥇', '🥈', '🥉', '4.', '5.'];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: idx < _topTuyen.length - 1
                                ? const Border(bottom: BorderSide(color: mauCardVien))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(medals[idx], style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(e.key,
                                    style: const TextStyle(
                                        color: mauTextTrang, fontSize: 13)),
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
