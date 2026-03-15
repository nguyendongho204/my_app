import 'package:flutter/cupertino.dart';
import '../../../../cau_hinh/hang_so.dart';
import '../../../../widget_dung_chung/cac_widget.dart';
import '../../../../widget_dung_chung/chon_ngay_kieu_bao_cao.dart';
import '../../../chon_ghe/giao_dien/man_hinh/ket_qua_tuyen.dart';

class TimTuyenXe extends StatefulWidget {
  const TimTuyenXe({super.key});

  @override
  State<TimTuyenXe> createState() => _TimTuyenXeState();
}

class _TimTuyenXeState extends State<TimTuyenXe> {
  // 3 input chính để tìm chuyến: điểm đi, điểm đến, ngày đi.
  String? _diemDi;
  String? _diemDen;
  DateTime _ngay = DateTime.now();

  final List<String> _danhSachDiem = [
    'BX Cái Răng',
    'BX Ninh Kiều',
    'BX Bình Thủy',
    'BX Ô Môn',
    'BX Thốt Nốt',
    'BX Vĩnh Thạnh',
    'BX Cờ Đỏ',
    'BX Thới Lai',
    'BX Phong Điền',
  ];

  String _dinhDangNgay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // Mở popup chọn điểm đi/điểm đến và cập nhật state theo lựa chọn của người dùng.
  void _chonDiem(bool laDiemDi) {
    showCupertinoModalPopup(
      context: context,
      builder: (popupCtx) => Container(
        height: 340,
        color: mauCardNen,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(laDiemDi ? 'Chọn điểm đi' : 'Chọn điểm đến',
                        style: const TextStyle(
                            color: mauTextTrang,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(popupCtx).pop(),
                      child: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: mauTextXam),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _danhSachDiem.length,
                  separatorBuilder: (_, index) => Container(
                    height: 0.5, margin: const EdgeInsets.only(left: 16),
                    color: mauCardVien,
                  ),
                  itemBuilder: (_, i) {
                    final diem = _danhSachDiem[i];
                    final duocChon = laDiemDi
                        ? _diemDi == diem
                        : _diemDen == diem;
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      onPressed: () {
                        setState(() {
                          // Tránh trạng thái điểm đi trùng điểm đến.
                          if (laDiemDi) {
                            _diemDi = diem;
                            if (_diemDen == diem) _diemDen = null;
                          } else {
                            _diemDen = diem;
                            if (_diemDi == diem) _diemDi = null;
                          }
                        });
                        Navigator.of(popupCtx).pop();
                      },
                      child: Row(children: [
                        const Icon(CupertinoIcons.location_solid,
                            color: mauXanhSang, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(diem,
                              style: TextStyle(
                                  color: duocChon ? mauXanhSang : mauTextTrang,
                                  fontWeight: duocChon
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                        if (duocChon)
                          const Icon(CupertinoIcons.checkmark,
                              color: mauXanhSang, size: 16),
                      ]),
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

  // Chỉ cho phép chọn từ hôm nay đến tối đa 30 ngày tiếp theo.
  void _chonNgay() {
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day);
    chonNgayKieuBaoCao(
      context: context,
      ngayBanDau: _ngay,
      ngayToiThieu: minDate,
      ngayToiDa: minDate.add(const Duration(days: 30)),
      tieuDe: 'Chọn ngày đi',
      nutApDung: 'Xong',
    ).then((d) {
      if (d == null || !mounted) return;
      setState(() => _ngay = d);
    });
  }

  // Validate input trước khi điều hướng sang màn hình kết quả tìm chuyến.
  void _timKiem() {
    if (_diemDi == null || _diemDen == null) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng chọn điểm đi và điểm đến.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Chuyển sang màn kết quả và truyền bộ điều kiện tìm kiếm hiện tại.
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => KetQuaTuyen(
          diemDi: _diemDi!,
          diemDen: _diemDen!,
          ngay: _ngay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: mauNenToi,
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: mauNenToi2.withAlpha(230),
              border: null,
              largeTitle: const Text('Tìm tuyến xe',
                  style: TextStyle(color: mauTextTrang)),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Cụm chọn điểm đi/điểm đến + nút hoán đổi nhanh.
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: mauCardNen,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: mauCardVien),
                          ),
                          child: Column(
                            children: [
                              _OChonDiemIOS(
                                nhan: 'Điểm đi',
                                giaTri: _diemDi,
                                bieu: CupertinoIcons.circle,
                                mauIcon: mauXanhSang,
                                onNhan: () => _chonDiem(true),
                              ),
                              Container(
                                height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16),
                                color: mauCardVien,
                              ),
                              _OChonDiemIOS(
                                nhan: 'Điểm đến',
                                giaTri: _diemDen,
                                bieu: CupertinoIcons.location_solid,
                                mauIcon: mauDoHong,
                                onNhan: () => _chonDiem(false),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 16,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              // Đổi nhanh vị trí điểm đi và điểm đến.
                              final tmp = _diemDi;
                              _diemDi = _diemDen;
                              _diemDen = tmp;
                            }),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: mauXanhChinh,
                                shape: BoxShape.circle,
                                border: Border.all(color: mauCardNen, width: 2.5),
                              ),
                              child: const Icon(
                                CupertinoIcons.arrow_up_arrow_down,
                                color: CupertinoColors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Ô chọn ngày đi.
                    GestureDetector(
                      onTap: _chonNgay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: mauCardNen,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: mauCardVien),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.calendar,
                                color: mauXanhSang, size: 20),
                            const SizedBox(width: 12),
                            const Text('Ngày đi',
                                style: TextStyle(
                                    color: mauTextXam, fontSize: 13)),
                            const Spacer(),
                            Text(_dinhDangNgay(_ngay),
                                style: const TextStyle(
                                    color: mauTextTrang,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            const Icon(CupertinoIcons.chevron_right,
                                color: mauTextXam, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Gợi ý tuyến phổ biến để chọn nhanh.
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tuyến phổ biến',
                          style: TextStyle(
                              color: mauTextXam,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _nhanTuyen('BX Cần Thơ → BX Ninh Kiều',
                            () => setState(() {
                              _diemDi = 'BX Cần Thơ';
                              _diemDen = 'BX Ninh Kiều';
                            })),
                        _nhanTuyen('BX Ninh Kiều → BX Ô Môn',
                            () => setState(() {
                              _diemDi = 'BX Ninh Kiều';
                              _diemDen = 'BX Ô Môn';
                            })),
                        _nhanTuyen('BX Cần Thơ → BX Cái Răng',
                            () => setState(() {
                              _diemDi = 'BX Cần Thơ';
                              _diemDen = 'BX Cái Răng';
                            })),
                      ],
                    ),
                    const Spacer(),
                    // Nút thực hiện tìm chuyến theo điều kiện đang chọn.
                    NutGradient(
                      nhanDe: 'Tìm chuyến xe',
                      bieuTuong: CupertinoIcons.search,
                      chieuRong: double.infinity,
                      onNhan: _timKiem,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OChonDiemIOS extends StatelessWidget {
  final String nhan;
  final String? giaTri;
  final IconData bieu;
  final Color mauIcon;
  final VoidCallback onNhan;

  const _OChonDiemIOS({
    required this.nhan,
    required this.giaTri,
    required this.bieu,
    required this.mauIcon,
    required this.onNhan,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onPressed: onNhan,
      child: Row(
        children: [
          Icon(bieu, color: mauIcon, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nhan,
                    style:
                        const TextStyle(color: mauTextXam, fontSize: 11)),
                const SizedBox(height: 3),
                Text(
                  giaTri ?? 'Chọn ${nhan.toLowerCase()}...',
                  style: TextStyle(
                    color: giaTri != null ? mauTextTrang : mauTextXamNhat,
                    fontWeight: giaTri != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right,
              color: mauTextXam, size: 14),
        ],
      ),
    );
  }
}

Widget _nhanTuyen(String ten, VoidCallback onNhan) {
  return GestureDetector(
    onTap: onNhan,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: mauXanhChinh.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mauXanhChinh.withAlpha(80)),
      ),
      child: Text(ten,
          style: const TextStyle(color: mauXanhSang, fontSize: 12)),
    ),
  );
}