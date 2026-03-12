import 'package:flutter/cupertino.dart';
import '../../cau_hinh/hang_so.dart';
import '../../du_lieu/co_so_du_lieu.dart';

class QuanLiDonVe extends StatefulWidget {
  const QuanLiDonVe({super.key});
  @override
  State<QuanLiDonVe> createState() => _QuanLiDonVeState();
}

class _QuanLiDonVeState extends State<QuanLiDonVe> {
  bool _dangTai = true;
  List<Ve> _ds = [];
  String _loc = 'tat_ca';
  DateTime _ngay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tai();
  }

  String get _ngayStr =>
      '${_ngay.day}/${_ngay.month}/${_ngay.year}';

  Future<void> _tai() async {
    setState(() => _dangTai = true);
    try {
      final ds = await CoSoDuLieu().layTatCaVe(ngay: _ngayStr);
      if (!mounted) return;
      setState(() {
        _ds = ds;
        _dangTai = false;
      });
    } catch (_) {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  List<Ve> get _hienThi =>
      _loc == 'tat_ca' ? _ds : _ds.where((v) => v.trangThai == _loc).toList();

  Color _mauTT(String t) {
    switch (t) {
      case 'cho':
        return mauCam;
      case 'hoan_thanh':
        return const Color(0xFF00C853);
      case 'bo_lo':
        return const Color(0xFFFF9800);
      case 'huy':
        return mauDoHong;
      default:
        return mauTextXam;
    }
  }

  String _tenTT(String t) {
    switch (t) {
      case 'cho':
        return 'Chờ';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'bo_lo':
        return 'Bỏ lỡ';
      case 'huy':
        return 'Đã hủy';
      default:
        return t;
    }
  }

  String _tien(int t) {
    final s = t.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}đ';
  }

  void _chiTiet(Ve ve) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: mauCardNen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 24,
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
              Row(
                children: [
                  Expanded(
                    child: Text(ve.maVe,
                        style: const TextStyle(
                            color: mauXanhSang,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _mauTT(ve.trangThai).withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_tenTT(ve.trangThai),
                        style: TextStyle(
                            color: _mauTT(ve.trangThai),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Row('Tuyến', '${ve.diemDi} → ${ve.diemDen}'),
              _Row('Ngày đi', '${ve.ngay}  ${ve.gio}'),
              _Row('Loại xe', ve.loaiXe),
              _Row('Số ghế',
                  (ve.danhSachGheParsed..sort()).join(', ')),
              _Row('Tổng tiền', _tien(ve.tongTien)),
              _Row('Ngày đặt', ve.ngayDat),
              const SizedBox(height: 20),
              if (ve.trangThai == 'cho') ...[
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: mauDoHong,
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await CoSoDuLieu()
                          .capNhatTrangThaiVe(ve.id!, 'huy');
                      _tai();
                    },
                    child: const Text('Hủy vé này',
                        style: TextStyle(color: CupertinoColors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locItems = [
      ['tat_ca', 'Tất cả'],
      ['cho', 'Chờ'],
      ['hoan_thanh', 'Hoàn thành'],
      ['bo_lo', 'Bỏ lỡ'],
      ['huy', 'Đã hủy'],
    ];

    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: mauNenToi2,
        border: null,
        middle: const Text('Quản lý đơn đặt vé',
            style: TextStyle(color: mauTextTrang)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _tai,
          child: const Icon(CupertinoIcons.arrow_clockwise,
              color: mauXanhSang, size: 18),
        ),
      ),
      child: Column(
        children: [
          Container(
            color: mauNenToi2,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    DateTime tg = _ngay;
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (_) => Container(
                        height: 280,
                        color: mauCardNen,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: _ngay,
                                onDateTimeChanged: (d) => tg = d,
                              ),
                            ),
                            CupertinoButton(
                              onPressed: () {
                                setState(() => _ngay = tg);
                                Navigator.of(context,
                                        rootNavigator: true)
                                    .pop();
                                _tai();
                              },
                              child: const Text('Áp dụng'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.calendar,
                          color: mauXanhSang, size: 16),
                      const SizedBox(width: 6),
                      Text(_ngayStr,
                          style: const TextStyle(
                              color: mauXanhSang, fontSize: 14)),
                      const Icon(CupertinoIcons.chevron_down,
                          color: mauXanhSang, size: 12),
                    ],
                  ),
                ),
                const Spacer(),
                Text('${_hienThi.length} vé',
                    style: const TextStyle(
                        color: mauTextXam, fontSize: 13)),
              ],
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              children: locItems
                  .map((item) {
                    final act = _loc == item[0];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            setState(() => _loc = item[0]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: act
                                ? mauXanhChinh.withAlpha(50)
                                : mauCardNen,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: act
                                    ? mauXanhSang
                                    : mauCardVien),
                          ),
                          child: Text(item[1],
                              style: TextStyle(
                                  color: act
                                      ? mauXanhSang
                                      : mauTextXam,
                                  fontSize: 12,
                                  fontWeight: act
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          Expanded(
            child: _dangTai
                ? const Center(
                    child: CupertinoActivityIndicator(
                        radius: 14, color: mauXanhSang))
                : _hienThi.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.doc_plaintext,
                                color: mauTextXam, size: 48),
                            SizedBox(height: 12),
                            Text('Không có vé nào',
                                style: TextStyle(color: mauTextXam)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _hienThi.length,
                        itemBuilder: (_, i) {
                          final ve = _hienThi[i];
                          final mau = _mauTT(ve.trangThai);
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _chiTiet(ve),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: mauCardNen,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: mau.withAlpha(60)),
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
                                                fontSize: 13)),
                                        Text(
                                            '${ve.diemDi} → ${ve.diemDen}',
                                            style: const TextStyle(
                                                color: mauTextTrang,
                                                fontSize: 13)),
                                        Text(
                                            '${ve.ngay}  ${ve.gio}  •  ${_tien(ve.tongTien)}',
                                            style: const TextStyle(
                                                color: mauTextXam,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color: mau.withAlpha(40),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                            _tenTT(ve.trangThai),
                                            style: TextStyle(
                                                color: mau,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold)),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text('Chi tiết →',
                                          style: TextStyle(
                                              color: mauTextXam,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
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

class _Row extends StatelessWidget {
  final String nhan;
  final String giaTri;
  const _Row(this.nhan, this.giaTri);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(nhan,
                style: const TextStyle(
                    color: mauTextXam, fontSize: 13)),
          ),
          Expanded(
            child: Text(giaTri,
                style: const TextStyle(
                    color: mauTextTrang,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
