import 'package:flutter/cupertino.dart';

import '../cau_hinh/hang_so.dart';

Future<DateTime?> chonNgayKieuBaoCao({
  required BuildContext context,
  required DateTime ngayBanDau,
  DateTime? ngayToiThieu,
  DateTime? ngayToiDa,
  String tieuDe = 'Chọn ngày',
  String nutApDung = 'Áp dụng',
}) async {
  // Chuẩn hóa về đầu ngày để so sánh mốc min/max không lệch theo giờ/phút.
  DateTime boGio(DateTime d) => DateTime(d.year, d.month, d.day);

  final minD = ngayToiThieu != null ? boGio(ngayToiThieu) : DateTime(2000, 1, 1);
  final maxD = ngayToiDa != null ? boGio(ngayToiDa) : DateTime.now();

  DateTime kepNgay(DateTime d) {
    // Ép ngày luôn nằm trong khoảng cho phép trước khi đổ vào picker.
    final x = boGio(d);
    if (x.isBefore(minD)) return minD;
    if (x.isAfter(maxD)) return maxD;
    return x;
  }

  final dau = kepNgay(ngayBanDau);
  int nam = dau.year;
  int thang = dau.month;
  int ngay = dau.day;

  final minNam = minD.year;
  final maxNam = maxD.year;

  final dayCtrl = FixedExtentScrollController(initialItem: ngay - 1);
  final monthCtrl = FixedExtentScrollController(initialItem: thang - 1);
  final yearCtrl = FixedExtentScrollController(initialItem: nam - minNam);

  int soNgayTrongThang(int y, int m) => DateTime(y, m + 1, 0).day;

  DateTime? ketQua;
  await showCupertinoModalPopup(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setM) {
        // Giới hạn tháng/ngày theo năm đang chọn để tránh tạo ngày không hợp lệ.
        final minThang = nam == minNam ? minD.month : 1;
        final maxThang = nam == maxNam ? maxD.month : 12;

        if (thang < minThang) {
          thang = minThang;
          monthCtrl.jumpToItem(thang - 1);
        }
        if (thang > maxThang) {
          thang = maxThang;
          monthCtrl.jumpToItem(thang - 1);
        }

        final minNgay = (nam == minNam && thang == minD.month) ? minD.day : 1;
        final maxNgayTheoThang = soNgayTrongThang(nam, thang);
        final maxNgayTheoMoc =
            (nam == maxNam && thang == maxD.month) ? maxD.day : maxNgayTheoThang;
        final maxNgay = maxNgayTheoMoc < maxNgayTheoThang ? maxNgayTheoMoc : maxNgayTheoThang;

        if (ngay < minNgay) {
          ngay = minNgay;
          dayCtrl.jumpToItem(ngay - 1);
        }
        if (ngay > maxNgay) {
          ngay = maxNgay;
          dayCtrl.jumpToItem(ngay - 1);
        }

        return Container(
          height: 360,
          color: mauCardNen,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        tieuDe,
                        style: const TextStyle(
                          color: mauTextTrang,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ketQua = DateTime(nam, thang, ngay);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text(
                          nutApDung,
                          style: const TextStyle(color: mauXanhSang),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: dayCtrl,
                          itemExtent: 34,
                          onSelectedItemChanged: (i) {
                            final val = i + 1;
                            setM(() => ngay = val < minNgay ? minNgay : val);
                          },
                          children: List.generate(maxNgay, (i) {
                            final val = i + 1;
                            return Center(
                              child: Text(
                                'ngày $val',
                                style: const TextStyle(
                                  color: mauTextTrang,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: monthCtrl,
                          itemExtent: 34,
                          onSelectedItemChanged: (i) {
                            final val = i + 1;
                            setM(() => thang = val < minThang ? minThang : (val > maxThang ? maxThang : val));
                          },
                          children: List.generate(maxThang, (i) {
                            final val = i + 1;
                            return Center(
                              child: Text(
                                'tháng $val',
                                style: const TextStyle(
                                  color: mauTextTrang,
                                  fontSize: 18,
                                ),
                              ),
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
                              if (nam < minNam) nam = minNam;
                              if (nam > maxNam) nam = maxNam;
                            });
                          },
                          children: List.generate(maxNam - minNam + 1, (i) {
                            final y = minNam + i;
                            return Center(
                              child: Text(
                                'năm $y',
                                style: const TextStyle(
                                  color: mauTextTrang,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  dayCtrl.dispose();
  monthCtrl.dispose();
  yearCtrl.dispose();
  return ketQua;
}
