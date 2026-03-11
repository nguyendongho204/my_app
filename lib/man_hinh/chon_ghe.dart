import 'package:flutter/cupertino.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';
import 'dang_nhap.dart';
import 'thanh_toan.dart';

class ChonGhe extends StatefulWidget {
  final Map<String, dynamic> chuyen;
  final String diemDi;
  final String diemDen;
  final DateTime ngay;

  const ChonGhe({
    super.key,
    required this.chuyen,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
  });

  @override
  State<ChonGhe> createState() => _ChonGheState();
}

class _ChonGheState extends State<ChonGhe> {
  late final Set<int> _gheDaDat;
  final Set<int> _gheDangChon = {};
  static const int _soGheToiDa = 4;

  @override
  void initState() {
    super.initState();
    final gheTrong = (widget.chuyen['gheTrong'] as int).clamp(0, 15);
    final soDaDat = 15 - gheTrong;
    _gheDaDat = {};
    for (final s in [3, 7, 5, 11, 9, 14, 1, 13, 6, 2, 12, 10, 4, 8, 15]) {
      if (_gheDaDat.length >= soDaDat) break;
      _gheDaDat.add(s);
    }
  }

  void _bamGhe(int so) {
    if (_gheDaDat.contains(so)) return;
    setState(() {
      if (_gheDangChon.contains(so)) {
        _gheDangChon.remove(so);
      } else if (_gheDangChon.length < _soGheToiDa) {
        _gheDangChon.add(so);
      }
    });
  }

  int get _tongTien {
    final gia = int.parse(widget.chuyen['gia'] as String);
    return gia * _gheDangChon.length;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: mauXanhSang,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text('Chọn ghế',
            style: TextStyle(color: mauTextTrang)),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: Column(
            children: [
              // Thong tin chuyen
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: mauXanhChinh.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mauXanhChinh.withAlpha(77)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(widget.diemDi,
                        style: const TextStyle(color: mauTextTrang, fontWeight: FontWeight.bold)),
                    Column(children: [
                      const Icon(CupertinoIcons.arrow_right, color: mauXanhSang, size: 14),
                      Text(widget.chuyen['gio'] as String,
                          style: const TextStyle(color: mauXanhSang, fontSize: 11)),
                    ]),
                    Text(widget.diemDen,
                        style: const TextStyle(color: mauTextTrang, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Chu thich
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OChuThich(mau: mauCardNen, nhan: 'Trống', coVien: true),
                    const SizedBox(width: 16),
                    _OChuThich(mau: mauTextXamNhat, nhan: 'Đã đặt', coVien: false),
                    const SizedBox(width: 16),
                    _OChuThich(mau: mauXanhChinh, nhan: 'Đang chọn', coVien: false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // So do xe
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _SoDoXe(
                        gheDaDat: _gheDaDat,
                        gheDangChon: _gheDangChon,
                        khiBam: _bamGhe,
                      ),
                      if (_gheDangChon.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _ThongTinChon(
                          gheChon: _gheDangChon,
                          tongTien: _tongTien,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Nut tiep tuc
              if (_gheDangChon.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: NutGradient(
                    nhanDe: 'Tiếp tục  ${_dinhDang(_tongTien)}',
                    bieuTuong: CupertinoIcons.arrow_right,
                    chieuRong: double.infinity,
                    onNhan: () async {
                      if (!TrangThaiUngDung().daDangNhap) {
                        await showCupertinoModalPopup(
                          context: context,
                          builder: (_) => Container(
                            decoration: const BoxDecoration(
                              color: mauNenToi2,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36, height: 4,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: mauCardVien,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.lock_circle,
                                      color: mauXanhSang, size: 64),
                                  const SizedBox(height: 16),
                                  const Text('Cần đăng nhập',
                                      style: TextStyle(
                                          color: mauTextTrang,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Vui lòng đăng nhập để tiếp tục đặt vé',
                                    style: TextStyle(
                                        color: mauTextXam, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),
                                  NutGradient(
                                    nhanDe: 'Đăng nhập',
                                    bieuTuong: CupertinoIcons.arrow_right,
                                    chieuRong: double.infinity,
                                    onNhan: () async {
                                      Navigator.of(context,
                                              rootNavigator: true)
                                          .pop();
                                      await Navigator.of(context,
                                              rootNavigator: true)
                                          .push(CupertinoPageRoute(
                                        builder: (_) =>
                                            const DangNhap(laModal: true),
                                      ));
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pop(),
                                    child: const Text('Để sau',
                                        style:
                                            TextStyle(color: mauTextXam)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        if (!mounted) return;
                        if (!TrangThaiUngDung().daDangNhap) return;
                      }
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ThanhToan(
                            chuyen: widget.chuyen,
                            diemDi: widget.diemDi,
                            diemDen: widget.diemDen,
                            ngay: widget.ngay,
                            gheChon: _gheDangChon.toList(),
                            tongTien: _tongTien,
                          ),
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

  String _dinhDang(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}d';
  }
}

class _OChuThich extends StatelessWidget {
  final Color mau;
  final String nhan;
  final bool coVien;

  const _OChuThich({required this.mau, required this.nhan, required this.coVien});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: mau,
            borderRadius: BorderRadius.circular(4),
            border: coVien ? Border.all(color: mauCardVien) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(nhan, style: const TextStyle(color: mauTextXam, fontSize: 12)),
      ],
    );
  }
}

class _SoDoXe extends StatelessWidget {
  final Set<int> gheDaDat;
  final Set<int> gheDangChon;
  final ValueChanged<int> khiBam;

  const _SoDoXe({
    required this.gheDaDat,
    required this.gheDangChon,
    required this.khiBam,
  });

  Widget _ghe(int so) => _NutGhe(
    so: so,
    daDat: gheDaDat.contains(so),
    dangChon: gheDangChon.contains(so),
    khiBam: khiBam,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mauCardVien),
      ),
      child: Column(
        children: [
          // Đầu xe
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: gradientChinh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bus, color: CupertinoColors.white, size: 18),
                SizedBox(width: 8),
                Text('Đầu xe',
                    style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Hàng 0: Tài xế (trái) + Ghế 1 (phải)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 22),
              Container(
                width: 44, height: 38,
                decoration: BoxDecoration(
                  color: mauNenToi,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: mauCardVien.withAlpha(77)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.person_fill, color: mauTextXamNhat, size: 14),
                    Text('TX', style: TextStyle(color: mauTextXamNhat, fontSize: 9)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(width: 44), // khoảng trống bên trái
              const SizedBox(width: 20), // lối đi
              _ghe(1),
              const SizedBox(width: 4),
              const SizedBox(width: 44), // khoảng trống bên phải
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 0.5, color: mauCardVien),
          const SizedBox(height: 8),
          // Hàng 1–3: 4 ghế mỗi hàng (2 trái | lối đi | 2 phải)
          ...List.generate(3, (i) {
            final b = i * 4 + 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text('${i + 1}',
                        style: const TextStyle(color: mauTextXamNhat, fontSize: 10),
                        textAlign: TextAlign.center),
                  ),
                  _ghe(b),
                  const SizedBox(width: 4),
                  _ghe(b + 1),
                  const SizedBox(width: 20), // lối đi
                  _ghe(b + 2),
                  const SizedBox(width: 4),
                  _ghe(b + 3),
                ],
              ),
            );
          }),
          Container(height: 0.5, color: mauCardVien),
          const SizedBox(height: 8),
          // Hàng cuối: Ghế 14 và 15 (giữa xe)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 22),
              const SizedBox(width: 44), // ô trống cửa sổ
              const SizedBox(width: 4),
              _ghe(14),
              const SizedBox(width: 20), // lối đi
              _ghe(15),
              const SizedBox(width: 4),
              const SizedBox(width: 44), // ô trống cửa sổ
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NutGhe extends StatelessWidget {
  final int so;
  final bool daDat;
  final bool dangChon;
  final ValueChanged<int> khiBam;

  const _NutGhe({required this.so, required this.daDat, required this.dangChon, required this.khiBam});

  @override
  Widget build(BuildContext context) {
    Color mauNen;
    Color mauChu;
    if (daDat) {
      mauNen = mauTextXamNhat.withAlpha(102);
      mauChu = mauTextXamNhat;
    } else if (dangChon) {
      mauNen = mauXanhChinh;
      mauChu = CupertinoColors.white;
    } else {
      mauNen = mauCardNen;
      mauChu = mauTextXam;
    }

    return GestureDetector(
      onTap: () => khiBam(so),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 38,
        decoration: BoxDecoration(
          color: mauNen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: dangChon ? mauXanhSang : daDat ? CupertinoColors.transparent : mauCardVien,
            width: dangChon ? 2 : 1,
          ),
          boxShadow: dangChon ? [
            BoxShadow(color: mauXanhChinh.withAlpha(102), blurRadius: 8),
          ] : null,
        ),
        child: Center(
          child: Text('$so',
              style: TextStyle(
                color: mauChu, fontSize: 12,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
              )),
        ),
      ),
    );
  }
}

class _ThongTinChon extends StatelessWidget {
  final Set<int> gheChon;
  final int tongTien;

  const _ThongTinChon({required this.gheChon, required this.tongTien});

  @override
  Widget build(BuildContext context) {
    final sorted = gheChon.toList()..sort();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mauXanhChinh.withAlpha(38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mauXanhChinh.withAlpha(102)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ghế đã chọn', style: TextStyle(color: mauTextXam, fontSize: 12)),
              Text(sorted.join(', '),
                  style: const TextStyle(color: mauXanhSang, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Tổng tiền', style: TextStyle(color: mauTextXam, fontSize: 12)),
              Text(
                _dinhDang(tongTien),
                style: const TextStyle(color: mauXanhLa, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dinhDang(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}d';
  }
}