import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

// ===================== MODELS =====================

class NguoiDung {
  final String? id;
  final String ten;
  final String sdt;
  final String email;
  final String matKhau;
  final String ngayTao;

  const NguoiDung({
    this.id,
    required this.ten,
    required this.sdt,
    required this.email,
    required this.matKhau,
    required this.ngayTao,
  });

  NguoiDung copyWith({String? id}) => NguoiDung(
        id: id ?? this.id,
        ten: ten, sdt: sdt, email: email,
        matKhau: matKhau, ngayTao: ngayTao,
      );

  Map<String, dynamic> toMap() => {
        'ten': ten, 'sdt': sdt, 'email': email,
        'matKhau': matKhau, 'ngayTao': ngayTao,
      };

  factory NguoiDung.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NguoiDung(
      id: doc.id,
      ten: d['ten'] ?? '',
      sdt: d['sdt'] ?? '',
      email: d['email'] ?? '',
      matKhau: d['matKhau'] ?? '',
      ngayTao: d['ngayTao'] ?? '',
    );
  }
}

class Ve {
  final String? id;
  final String maVe;
  final String diemDi;
  final String diemDen;
  final String gio;
  final String ngay;
  final String danhSachGhe;
  final int tongTien;
  final String trangThai;
  final String loaiXe;
  final String ngayDat;
  final String nguoiDungId;
  final int? danhGia; // 1-5 sao

  const Ve({
    this.id,
    required this.maVe,
    required this.diemDi,
    required this.diemDen,
    required this.gio,
    required this.ngay,
    required this.danhSachGhe,
    required this.tongTien,
    required this.trangThai,
    required this.loaiXe,
    required this.ngayDat,
    required this.nguoiDungId,
    this.danhGia,
  });

  List<int> get danhSachGheParsed =>
      danhSachGhe.split(',').map(int.parse).toList();

  Map<String, dynamic> toMap() => {
        'maVe': maVe, 'diemDi': diemDi, 'diemDen': diemDen,
        'gio': gio, 'ngay': ngay, 'danhSachGhe': danhSachGhe,
        'tongTien': tongTien, 'trangThai': trangThai,
        'loaiXe': loaiXe, 'ngayDat': ngayDat, 'nguoiDungId': nguoiDungId,
        if (danhGia != null) 'danhGia': danhGia,
      };

  factory Ve.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Ve(
      id: doc.id,
      maVe: d['maVe'] ?? '',
      diemDi: d['diemDi'] ?? '',
      diemDen: d['diemDen'] ?? '',
      gio: d['gio'] ?? '',
      ngay: d['ngay'] ?? '',
      danhSachGhe: d['danhSachGhe'] ?? '',
      tongTien: (d['tongTien'] as num?)?.toInt() ?? 0,
      trangThai: d['trangThai'] ?? 'cho',
      loaiXe: d['loaiXe'] ?? '',
      ngayDat: d['ngayDat'] ?? '',
      nguoiDungId: d['nguoiDungId'] ?? '',
      danhGia: (d['danhGia'] as num?)?.toInt(),
    );
  }
}

// ===================== DATABASE HELPER =====================

class CoSoDuLieu {
  static final CoSoDuLieu _instance = CoSoDuLieu._internal();
  factory CoSoDuLieu() => _instance;
  CoSoDuLieu._internal();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _nguoiDung => _db.collection('nguoi_dung');
  CollectionReference get _ve => _db.collection('ve');

  // ---------- TIEN ICH ----------
  static String hashMatKhau(String mk) =>
      sha256.convert(utf8.encode(mk)).toString();

  static String taoMaVe() {
    final now = DateTime.now();
    final ms = now.millisecondsSinceEpoch % 100000;
    return 'BK${now.year}${now.month.toString().padLeft(2, '0')}${ms.toString().padLeft(5, '0')}';
  }

  static String dinhDangNgayHienTai() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  /// Parse ngày khởi hành (d/M/yyyy) + giờ (HH:mm) thành DateTime
  static DateTime? parseGioKhoiHanh(String ngay, String gio) {
    try {
      final pn = ngay.split('/');
      final pg = gio.split(':');
      if (pn.length != 3 || pg.length < 2) return null;
      return DateTime(
        int.parse(pn[2]), int.parse(pn[1]), int.parse(pn[0]),
        int.parse(pg[0]), int.parse(pg[1]),
      );
    } catch (_) {
      return null;
    }
  }

  // ---------- NGUOI DUNG ----------

  Future<NguoiDung?> dangKy({
    required String ten,
    required String sdt,
    required String email,
    required String matKhau,
  }) async {
    final existing = await _nguoiDung.where('sdt', isEqualTo: sdt).get();
    if (existing.docs.isNotEmpty) return null;

    final hash = hashMatKhau(matKhau);
    final now = dinhDangNgayHienTai();
    final doc = await _nguoiDung.add({
      'ten': ten, 'sdt': sdt, 'email': email,
      'matKhau': hash, 'ngayTao': now,
    });
    return NguoiDung(
      id: doc.id, ten: ten, sdt: sdt,
      email: email, matKhau: hash, ngayTao: now,
    );
  }

  Future<NguoiDung?> dangNhap({
    required String sdt,
    required String matKhau,
  }) async {
    final hash = hashMatKhau(matKhau);
    final q = await _nguoiDung.where('sdt', isEqualTo: sdt).get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    if (data['matKhau'] != hash) return null;
    return NguoiDung.fromDoc(doc);
  }

  Future<NguoiDung?> layNguoiDungTheoId(String id) async {
    final doc = await _nguoiDung.doc(id).get();
    if (!doc.exists) return null;
    return NguoiDung.fromDoc(doc);
  }

  // ---------- VE ----------

  Future<Ve> datVe(Ve ve) async {
    final doc = await _ve.add(ve.toMap());
    return Ve(
      id: doc.id, maVe: ve.maVe, diemDi: ve.diemDi, diemDen: ve.diemDen,
      gio: ve.gio, ngay: ve.ngay, danhSachGhe: ve.danhSachGhe,
      tongTien: ve.tongTien, trangThai: ve.trangThai, loaiXe: ve.loaiXe,
      ngayDat: ve.ngayDat, nguoiDungId: ve.nguoiDungId,
    );
  }

  Future<List<Ve>> layDanhSachVe(String nguoiDungId) async {
    final q = await _ve.where('nguoiDungId', isEqualTo: nguoiDungId).get();
    final list = q.docs.map((d) => Ve.fromDoc(d)).toList();
    list.sort((a, b) => b.ngayDat.compareTo(a.ngayDat));
    return list;
  }

  Future<void> huyVe(String veId) async {
    await _ve.doc(veId).update({'trangThai': 'huy'});
  }

  Future<void> boLoVe(String veId) async {
    await _ve.doc(veId).update({'trangThai': 'bo_lo'});
  }

  Future<void> lenXe(String veId) async {
    await _ve.doc(veId).update({'trangThai': 'hoan_thanh'});
  }

  Future<void> capNhatThongTin(String id,
      {required String ten, required String email}) async {
    await _nguoiDung.doc(id).update({'ten': ten, 'email': email});
  }

  Future<bool> doiMatKhau(String id, {
    required String matKhauCu,
    required String matKhauMoi,
  }) async {
    final doc = await _nguoiDung.doc(id).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    if (data['matKhau'] != hashMatKhau(matKhauCu)) return false;
    await _nguoiDung.doc(id).update({'matKhau': hashMatKhau(matKhauMoi)});
    return true;
  }

  /// Kiểm tra SĐT + email có khớp không (dùng cho quên mật khẩu)
  Future<bool> kiemTraSdtEmail({required String sdt, required String email}) async {
    final q = await _nguoiDung.where('sdt', isEqualTo: sdt).get();
    if (q.docs.isEmpty) return false;
    final data = q.docs.first.data() as Map<String, dynamic>;
    final emailLuu = (data['email'] as String? ?? '').toLowerCase().trim();
    return emailLuu.isNotEmpty && emailLuu == email.toLowerCase().trim();
  }

  /// Xóa tài khoản mới tạo nếu xác thực OTP thất bại
  Future<void> xoaTaiKhoanMoi(String id) async {
    try {
      await _nguoiDung.doc(id).delete();
    } catch (_) {}
  }

  /// Quên mật khẩu: xác minh SĐT + email → đặt mật khẩu mới
  Future<bool> quenMatKhau({
    required String sdt,
    required String email,
    required String matKhauMoi,
  }) async {
    final q = await _nguoiDung.where('sdt', isEqualTo: sdt).get();
    if (q.docs.isEmpty) return false;
    final doc = q.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    final emailLuu = (data['email'] as String? ?? '').toLowerCase().trim();
    if (emailLuu.isEmpty || emailLuu != email.toLowerCase().trim()) return false;
    await _nguoiDung.doc(doc.id).update({'matKhau': hashMatKhau(matKhauMoi)});
    return true;
  }

  Future<void> luuDanhGia(String veId, int sao) async {
    await _ve.doc(veId).update({'danhGia': sao});
  }
}

// ===================== SESSION =====================

class TrangThaiUngDung extends ChangeNotifier {
  static final TrangThaiUngDung _instance = TrangThaiUngDung._internal();
  factory TrangThaiUngDung() => _instance;
  TrangThaiUngDung._internal();

  NguoiDung? _nguoiDung;
  List<Ve> _danhSachVe = [];
  String? _sdtGanDay;
  String? _tenGanDay;

  NguoiDung? get nguoiDungHienTai => _nguoiDung;
  List<Ve> get danhSachVe => List.unmodifiable(_danhSachVe);
  bool get daDangNhap => _nguoiDung != null;
  String? get sdtGanDay => _sdtGanDay;
  String? get tenGanDay => _tenGanDay;

  void dangNhap(NguoiDung nd) {
    _nguoiDung = nd;
    _sdtGanDay = nd.sdt;
    _tenGanDay = nd.ten;
    _danhSachVe = [];
    notifyListeners();
    // Tu dong tai danh sach ve sau khi dang nhap
    CoSoDuLieu().layDanhSachVe(nd.id!).then((list) {
      _danhSachVe = List.from(list);
      notifyListeners();
    });
  }

  void dangXuat() {
    _nguoiDung = null;
    _danhSachVe = [];
    notifyListeners();
  }

  void capNhatNguoiDung(NguoiDung nd) {
    _nguoiDung = nd;
    notifyListeners();
  }

  Future<void> taiLaiDanhSachVe() async {
    if (_nguoiDung == null) return;
    final list = await CoSoDuLieu().layDanhSachVe(_nguoiDung!.id!);
    _danhSachVe = List.from(list);
    notifyListeners();
  }

  void themVeLocal(Ve ve) {
    _danhSachVe = [ve, ..._danhSachVe];
    notifyListeners();
  }

  void huyVeLocal(String veId) {
    _danhSachVe = _danhSachVe.map((v) => v.id == veId
        ? Ve(
            id: v.id, maVe: v.maVe, diemDi: v.diemDi, diemDen: v.diemDen,
            gio: v.gio, ngay: v.ngay, danhSachGhe: v.danhSachGhe,
            tongTien: v.tongTien, trangThai: 'huy', loaiXe: v.loaiXe,
            ngayDat: v.ngayDat, nguoiDungId: v.nguoiDungId,
            danhGia: v.danhGia,
          )
        : v).toList();
    notifyListeners();
  }

  void boLoVeLocal(String veId) {
    _danhSachVe = _danhSachVe.map((v) => v.id == veId
        ? Ve(
            id: v.id, maVe: v.maVe, diemDi: v.diemDi, diemDen: v.diemDen,
            gio: v.gio, ngay: v.ngay, danhSachGhe: v.danhSachGhe,
            tongTien: v.tongTien, trangThai: 'bo_lo', loaiXe: v.loaiXe,
            ngayDat: v.ngayDat, nguoiDungId: v.nguoiDungId,
            danhGia: v.danhGia,
          )
        : v).toList();
    notifyListeners();
  }

  void lenXeLocal(String veId) {
    _danhSachVe = _danhSachVe.map((v) => v.id == veId
        ? Ve(
            id: v.id, maVe: v.maVe, diemDi: v.diemDi, diemDen: v.diemDen,
            gio: v.gio, ngay: v.ngay, danhSachGhe: v.danhSachGhe,
            tongTien: v.tongTien, trangThai: 'hoan_thanh', loaiXe: v.loaiXe,
            ngayDat: v.ngayDat, nguoiDungId: v.nguoiDungId,
            danhGia: v.danhGia,
          )
        : v).toList();
    notifyListeners();
  }

  /// Tự động kiểm tra và đánh dấu vé bỏ lỡ (quá 4 giờ sau khởi hành, chưa lên xe)
  Future<void> kiemTraBoLo() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 4));
    final veBoLo = _danhSachVe.where((v) {
      if (v.trangThai != 'cho') return false;
      final kh = CoSoDuLieu.parseGioKhoiHanh(v.ngay, v.gio);
      return kh != null && kh.isBefore(cutoff);
    }).toList();
    for (final ve in veBoLo) {
      boLoVeLocal(ve.id!);
      await CoSoDuLieu().boLoVe(ve.id!);
    }
  }

  void danhGiaVeLocal(String veId, int sao) {
    _danhSachVe = _danhSachVe.map((v) => v.id == veId
        ? Ve(
            id: v.id, maVe: v.maVe, diemDi: v.diemDi, diemDen: v.diemDen,
            gio: v.gio, ngay: v.ngay, danhSachGhe: v.danhSachGhe,
            tongTien: v.tongTien, trangThai: v.trangThai, loaiXe: v.loaiXe,
            ngayDat: v.ngayDat, nguoiDungId: v.nguoiDungId,
            danhGia: sao,
          )
        : v).toList();
    notifyListeners();
  }

  // -------- OTP (simulated - dùng trong bộ nhớ) --------
  String? _otpPending;
  DateTime? _otpExpiry;

  String taoOTP() {
    final rng = DateTime.now().millisecondsSinceEpoch;
    _otpPending = ((rng % 900000) + 100000).toString().substring(0, 6);
    _otpExpiry = DateTime.now().add(const Duration(minutes: 5));
    return _otpPending!;
  }

  bool xacThucOTP(String nhapVao) {
    if (_otpPending == null) return false;
    if (DateTime.now().isAfter(_otpExpiry!)) {
      _otpPending = null;
      return false;
    }
    if (nhapVao.trim() == _otpPending) {
      _otpPending = null;
      return true;
    }
    return false;
  }
}