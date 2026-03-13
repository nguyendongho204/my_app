import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../cau_hinh/hang_so.dart';
import '../du_lieu/co_so_du_lieu.dart';
import '../widget_dung_chung/cac_widget.dart';

class ThanhToan extends StatefulWidget {
  final Map<String, dynamic> chuyen;
  final String diemDi;
  final String diemDen;
  final DateTime ngay;
  final List<int> gheChon;
  final int tongTien;

  const ThanhToan({
    super.key,
    required this.chuyen,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
    required this.gheChon,
    required this.tongTien,
  });

  @override
  State<ThanhToan> createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  final _tenCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _maKMCtrl = TextEditingController();
  int _ptThanhToan = 0;
  bool _dangXuLy = false;
  int _phiDichVu = 0;
  int _giamGia = 0;
  KhuyenMai? _kmApDung;
  bool _dangApKM = false;
  String? _loiKM;
  bool _daApKM = false;

  int get _giaThucTe => widget.tongTien + _phiDichVu - _giamGia;

  @override
  void initState() {
    super.initState();
    final nd = TrangThaiUngDung().nguoiDungHienTai;
    if (nd != null) {
      _tenCtrl.text = nd.ten;
      _sdtCtrl.text = nd.sdt;
    }
    _taiCauHinh();
  }

  Future<void> _taiCauHinh() async {
    try {
      final cfg = await CoSoDuLieu().layCauHinh();
      if (!mounted) return;
      setState(() {
        _phiDichVu = (cfg['phi_dich_vu'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _apDungKM() async {
    final ma = _maKMCtrl.text.trim();
    if (ma.isEmpty) return;
    setState(() { _dangApKM = true; _loiKM = null; });
    try {
      final (giam, km) = await CoSoDuLieu().apDungKhuyenMai(ma, widget.tongTien);
      if (!mounted) return;
      if (km == null) {
        setState(() {
          _dangApKM = false;
          _loiKM = 'Mã không hợp lệ hoặc đã hết lượt sử dụng.';
          _giamGia = 0;
          _kmApDung = null;
          _daApKM = false;
        });
      } else {
        setState(() {
          _dangApKM = false;
          _giamGia = giam;
          _kmApDung = km;
          _daApKM = true;
          _loiKM = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _dangApKM = false; _loiKM = 'Lỗi kết nối, thử lại.'; });
    }
  }
  final List<Map<String, dynamic>> _phuongThuc = [
    {'ten': 'Ví điện tử (MoMo)', 'bieu': CupertinoIcons.device_phone_portrait},
    {'ten': 'Chuyển khoản ngân hàng', 'bieu': CupertinoIcons.building_2_fill},
    {'ten': 'Tiền mặt tại xe', 'bieu': CupertinoIcons.money_dollar_circle},
  ];

  String _dinhDang(int tien) {
    final s = tien.toString();
    var kq = '';
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) kq += '.';
      kq += s[i];
    }
    return '${kq}d';
  }

  void _xacNhan() async {
    if (_tenCtrl.text.trim().isEmpty || _sdtCtrl.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Vui lòng nhập đủ thông tin hành khách.'),
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

    // MoMo hoặc chuyển khoản → hiện hướng dẫn thanh toán trước
    if (_ptThanhToan == 0 || _ptThanhToan == 1) {
      final xacNhan = await _hienThiHuongDanThanhToan();
      if (!xacNhan || !mounted) return;
    }

    setState(() => _dangXuLy = true);

    if (TrangThaiUngDung().daDangNhap) {
      try {
        final db = CoSoDuLieu();
        final ghe = (List<int>.from(widget.gheChon)..sort()).join(',');
        final ve = Ve(
          maVe: CoSoDuLieu.taoMaVe(),
          diemDi: widget.diemDi,
          diemDen: widget.diemDen,
          gio: widget.chuyen['gio'] as String,
          ngay: '${widget.ngay.day}/${widget.ngay.month}/${widget.ngay.year}',
          danhSachGhe: ghe,
          tongTien: _giaThucTe,
          trangThai: 'cho',
          loaiXe: widget.chuyen['loai'] as String,
          ngayDat: CoSoDuLieu.dinhDangNgayHienTai(),
          nguoiDungId: TrangThaiUngDung().nguoiDungHienTai!.id!,
        );
        final veDaLuu = await db.datVe(ve);
        TrangThaiUngDung().themVeLocal(veDaLuu);
        if (_kmApDung != null) {
          await db.tangDaSuDungKhuyenMai(_kmApDung!.id!);
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _dangXuLy = false);
    _hienThiThanhCong();
  }

  Future<bool> _hienThiHuongDanThanhToan() async {
    final laMoMo = _ptThanhToan == 0;
    final maGiaoDich = 'BOOKBUS${DateTime.now().millisecondsSinceEpoch % 1000000}';
    const sdtMoMo = '0901234567';
    const stk = '1028824828';
    const maNganHang = 'VCB'; // Vietcombank bank code on VietQR
    const nganHang = 'Vietcombank';
    const chuTk = 'NGUYEN DONG HO';

    // MoMo: encode deeplink thành QR bằng qr_flutter
    final momoQrData = 'momo://transfer?phone=$sdtMoMo&amount=$_giaThucTe&note=$maGiaoDich';
    // Ngân hàng: gọi API VietQR lấy ảnh QR chuẩn Napas (tất cả app ngân hàng VN đều quét được)
    final vietQrUrl = Uri.encodeFull(
      'https://img.vietqr.io/image/$maNganHang-$stk-compact2.png'
      '?amount=$_giaThucTe&addInfo=$maGiaoDich&accountName=$chuTk',
    );

    bool? ketQua;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: mauNenToi2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: mauCardVien,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: laMoMo ? const Color(0xFFD82D8B) : const Color(0xFF1A56DB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      laMoMo ? CupertinoIcons.device_phone_portrait : CupertinoIcons.building_2_fill,
                      color: CupertinoColors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    laMoMo ? 'Quét mã MoMo' : 'Chuyển khoản ngân hàng',
                    style: const TextStyle(
                        color: mauTextTrang,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
                const SizedBox(height: 16),
                // QR code box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (laMoMo)
                        QrImageView(
                          data: momoQrData,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: CupertinoColors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        )
                      else
                        Image.network(
                          vietQrUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : const SizedBox(
                                  width: 200, height: 200,
                                  child: Center(child: CupertinoActivityIndicator()),
                                ),
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 200, height: 200,
                            child: Center(
                              child: Text('Không tải được QR.\nKiểm tra kết nối mạng.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        laMoMo ? 'Mở app MoMo → Quét mã' : 'Mở app ngân hàng → Quét QR',
                        style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Chi tiết
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: mauCardNen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mauCardVien),
                  ),
                  child: Column(
                    children: [
                      if (laMoMo)
                        _DongThanhToan(nhan: 'SĐT MoMo', gia: sdtMoMo, laMauXanh: false)
                      else ...[
                        _DongThanhToan(nhan: 'Ngân hàng', gia: nganHang, laMauXanh: false),
                        const SizedBox(height: 6),
                        _DongThanhToan(nhan: 'Số tài khoản', gia: stk, laMauXanh: false),
                      ],
                      const SizedBox(height: 6),
                      _DongThanhToan(nhan: 'Chủ TK', gia: chuTk, laMauXanh: false),
                      const SizedBox(height: 6),
                      _DongThanhToan(nhan: 'Số tiền', gia: _dinhDang(_giaThucTe), laMauXanh: true),
                      const SizedBox(height: 6),
                      _DongThanhToan(nhan: 'Nội dung', gia: maGiaoDich, laMauXanh: false),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '* Nhập đúng nội dung chuyển khoản để xác nhận vé tự động.',
                  style: TextStyle(color: mauTextXamNhat, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                NutGradient(
                  nhanDe: 'Đã thanh toán xong',
                  bieuTuong: CupertinoIcons.checkmark_shield,
                  chieuRong: double.infinity,
                  onNhan: () {
                    ketQua = true;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    ketQua = false;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Hủy', style: TextStyle(color: mauTextXam)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return ketQua == true;
  }

  void _hienThiThanhCong() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
                color: mauXanhLa, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.checkmark_alt,
                color: CupertinoColors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text('Đặt vé thành công!',
              style: TextStyle(
                  color: mauXanhLa, fontWeight: FontWeight.bold)),
        ]),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(children: [
            Text('${widget.diemDi}  ${widget.diemDen}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Ghế: ${(widget.gheChon..sort()).join(', ')}'),
            Text('Tổng tiền: ${_dinhDang(_giaThucTe)}',
                style: const TextStyle(
                    color: mauXanhLa, fontWeight: FontWeight.bold)),
          ]),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).popUntil((r) => r.isFirst);
              DieuHuongTab.controller?.index = 2;
            },
            child: const Text('Xem vé của tôi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _sdtCtrl.dispose();
    _maKMCtrl.dispose();
    super.dispose();
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
        middle: const Text('Thanh toán',
            style: TextStyle(color: mauTextTrang)),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: gradientNen),
        child: SafeArea(
          child: _dangXuLy
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                          radius: 20, color: mauXanhSang),
                      SizedBox(height: 16),
                      Text('Đang xử lý...',
                          style: TextStyle(color: mauTextXam)),
                    ],
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionCard(
                      tieuDe: 'Thông tin chuyến xe',
                      con: Column(children: [
                        _Dong(nhan: 'Tuyến',
                            gia: '${widget.diemDi}  ${widget.diemDen}'),
                        _Dong(
                            nhan: 'Ngày',
                            gia: '${widget.ngay.day}/${widget.ngay.month}/${widget.ngay.year}'),
                        _Dong(nhan: 'Giờ',
                            gia: widget.chuyen['gio'] as String),
                        _Dong(nhan: 'Loại xe',
                            gia: widget.chuyen['loai'] as String),
                        _Dong(
                            nhan: 'Ghế',
                            gia: (widget.gheChon..sort()).join(', ')),
                        const SizedBox(height: 6),
                        Container(height: 0.5, color: mauCardVien),
                        const SizedBox(height: 6),
                        _DongDiaChi(
                          bieu: CupertinoIcons.location_solid,
                          nhan: 'Điểm đón',
                          ten: widget.diemDi,
                          diaChi: diaChiBenXe[widget.diemDi] ?? widget.diemDi,
                        ),
                        const SizedBox(height: 6),
                        _DongDiaChi(
                          bieu: CupertinoIcons.location,
                          nhan: 'Điểm xuống',
                          ten: widget.diemDen,
                          diaChi: diaChiBenXe[widget.diemDen] ?? widget.diemDen,
                        ),
                        const SizedBox(height: 6),
                        Container(height: 0.5, color: mauCardVien),
                        const SizedBox(height: 6),
                        _Dong(nhan: 'Tiền vé', gia: _dinhDang(widget.tongTien)),
                        if (_phiDichVu > 0)
                          _Dong(nhan: 'Phí dịch vụ', gia: _dinhDang(_phiDichVu)),
                        if (_giamGia > 0)
                          _Dong(nhan: 'Giảm giá (${_kmApDung?.ten ?? ''})', gia: '- ${_dinhDang(_giamGia)}'),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán',
                                style: TextStyle(
                                    color: mauTextTrang,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(_dinhDang(_giaThucTe),
                                style: const TextStyle(
                                    color: mauXanhLa,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      tieuDe: 'Mã khuyến mãi',
                      con: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _maKMCtrl,
                                  placeholder: 'Nhập mã khuyến mãi',
                                  placeholderStyle: const TextStyle(
                                      color: mauTextXam, fontSize: 13),
                                  style: const TextStyle(
                                      color: mauTextTrang, fontSize: 13),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: mauNenToi,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: mauCardVien),
                                  ),
                                  enabled: !_daApKM,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                color: _daApKM
                                    ? mauCardVien
                                    : mauXanhChinh,
                                borderRadius: BorderRadius.circular(10),
                                onPressed: _daApKM
                                    ? () {
                                        setState(() {
                                          _daApKM = false;
                                          _giamGia = 0;
                                          _kmApDung = null;
                                          _loiKM = null;
                                          _maKMCtrl.clear();
                                        });
                                      }
                                    : _dangApKM ? null : _apDungKM,
                                child: _dangApKM
                                    ? const CupertinoActivityIndicator(
                                        radius: 8,
                                        color: CupertinoColors.white)
                                    : Text(
                                        _daApKM ? 'Bỏ' : 'Áp dụng',
                                        style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 13),
                                      ),
                              ),
                            ],
                          ),
                          if (_loiKM != null) ...[
                            const SizedBox(height: 6),
                            Text(_loiKM!,
                                style: const TextStyle(
                                    color: mauDoHong, fontSize: 12)),
                          ],
                          if (_daApKM && _kmApDung != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.ticket_fill,
                                    color: mauXanhLa, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Áp dụng "${_kmApDung!.ten}" – Giảm ${_dinhDang(_giamGia)}',
                                    style: const TextStyle(
                                        color: mauXanhLa, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      tieuDe: 'Thông tin hành khách',
                      con: Column(children: [
                        _OText(
                          ctrl: _tenCtrl,
                          placeholder: 'Họ và tên',
                          bieu: CupertinoIcons.person,
                        ),
                        const SizedBox(height: 10),
                        _OText(
                          ctrl: _sdtCtrl,
                          placeholder: 'Số điện thoại',
                          bieu: CupertinoIcons.phone,
                          loaiBanPhim: TextInputType.phone,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      tieuDe: 'Phương thức thanh toán',
                      con: Column(
                        children: List.generate(_phuongThuc.length, (i) {
                          final pt = _phuongThuc[i];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _ptThanhToan = i),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _ptThanhToan == i
                                    ? mauXanhChinh.withAlpha(51)
                                    : mauNenToi,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _ptThanhToan == i
                                      ? mauXanhChinh
                                      : mauCardVien,
                                  width: _ptThanhToan == i ? 1.5 : 1,
                                ),
                              ),
                              child: Row(children: [
                                Icon(pt['bieu'] as IconData,
                                    color: _ptThanhToan == i
                                        ? mauXanhSang
                                        : mauTextXam,
                                    size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(pt['ten'] as String,
                                      style: TextStyle(
                                          color: _ptThanhToan == i
                                              ? mauTextTrang
                                              : mauTextXam)),
                                ),
                                if (_ptThanhToan == i)
                                  const Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      color: mauXanhSang, size: 18),
                              ]),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    NutGradient(
                      nhanDe: 'Xác nhận đặt vé',
                      bieuTuong: CupertinoIcons.checkmark_shield,
                      chieuRong: double.infinity,
                      onNhan: _xacNhan,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String tieuDe;
  final Widget con;
  const _SectionCard({required this.tieuDe, required this.con});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mauCardNen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mauCardVien),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tieuDe,
              style: const TextStyle(
                  color: mauXanhSang,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 12),
          con,
        ],
      ),
    );
  }
}

class _DongDiaChi extends StatelessWidget {
  final IconData bieu;
  final String nhan;
  final String ten;
  final String diaChi;
  const _DongDiaChi({required this.bieu, required this.nhan, required this.ten, required this.diaChi});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(bieu, color: mauXanhSang, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nhan, style: const TextStyle(color: mauTextXam, fontSize: 11)),
              Text(ten, style: const TextStyle(color: mauTextTrang, fontWeight: FontWeight.w600, fontSize: 13)),
              Text(diaChi, style: const TextStyle(color: mauTextXam, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dong extends StatelessWidget {
  final String nhan;
  final String gia;
  const _Dong({required this.nhan, required this.gia});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nhan,
              style: const TextStyle(color: mauTextXam, fontSize: 13)),
          Text(gia,
              style: const TextStyle(
                  color: mauTextTrang,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _OText extends StatelessWidget {
  final TextEditingController ctrl;
  final String placeholder;
  final IconData bieu;
  final TextInputType loaiBanPhim;
  const _OText({
    required this.ctrl,
    required this.placeholder,
    required this.bieu,
    this.loaiBanPhim = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: ctrl,
      keyboardType: loaiBanPhim,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: mauTextXam),
      style: const TextStyle(color: mauTextTrang),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(bieu, color: mauTextXam, size: 18),
      ),
      decoration: BoxDecoration(
        color: mauNenToi,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mauCardVien),
      ),
      padding: const EdgeInsets.all(12),
    );
  }
}

class _DongThanhToan extends StatelessWidget {
  final String nhan;
  final String gia;
  final bool laMauXanh;

  const _DongThanhToan({
    required this.nhan,
    required this.gia,
    required this.laMauXanh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nhan, style: const TextStyle(color: mauTextXam, fontSize: 13)),
        Text(gia,
            style: TextStyle(
                color: laMauXanh ? mauXanhLa : mauTextTrang,
                fontWeight: laMauXanh ? FontWeight.bold : FontWeight.w500,
                fontSize: 13)),
      ],
    );
  }
}