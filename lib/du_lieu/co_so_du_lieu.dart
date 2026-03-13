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
  final bool biKhoa;

  const NguoiDung({
    this.id,
    required this.ten,
    required this.sdt,
    required this.email,
    required this.matKhau,
    required this.ngayTao,
    this.biKhoa = false,
  });

  NguoiDung copyWith({String? id}) => NguoiDung(
        id: id ?? this.id,
        ten: ten, sdt: sdt, email: email,
        matKhau: matKhau, ngayTao: ngayTao, biKhoa: biKhoa,
      );

  Map<String, dynamic> toMap() => {
        'ten': ten, 'sdt': sdt, 'email': email,
        'matKhau': matKhau, 'ngayTao': ngayTao, 'biKhoa': biKhoa,
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
      biKhoa: d['biKhoa'] == true,
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

class NhanVien {
  final String? id;
  final String ten;
  final String maNV;
  final String matKhau;

  const NhanVien({
    this.id,
    required this.ten,
    required this.maNV,
    required this.matKhau,
  });

  factory NhanVien.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NhanVien(
      id: doc.id,
      ten: d['ten'] ?? '',
      maNV: d['maNV'] ?? '',
      matKhau: d['matKhau'] ?? '',
    );
  }
}

class Admin {
  final String? id;
  final String ten;
  final String maTK;
  final String matKhau;

  const Admin({
    this.id,
    required this.ten,
    required this.maTK,
    required this.matKhau,
  });

  factory Admin.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Admin(
      id: doc.id,
      ten: d['ten'] ?? '',
      maTK: d['maTK'] ?? '',
      matKhau: d['matKhau'] ?? '',
    );
  }
}

class TuyenXe {
  final String? id;
  final String diemDi;
  final String diemDen;
  final int khoangCach;
  final int thoiGian;
  final int giaVeCoSo;
  final List<String> danhSachDiemDon;
  final List<String> danhSachDiemTra;
  final bool hoatDong;

  const TuyenXe({
    this.id,
    required this.diemDi,
    required this.diemDen,
    required this.khoangCach,
    required this.thoiGian,
    required this.giaVeCoSo,
    required this.danhSachDiemDon,
    required this.danhSachDiemTra,
    required this.hoatDong,
  });

  Map<String, dynamic> toMap() => {
        'diemDi': diemDi, 'diemDen': diemDen,
        'khoangCach': khoangCach, 'thoiGian': thoiGian,
        'giaVeCoSo': giaVeCoSo,
        'danhSachDiemDon': danhSachDiemDon,
        'danhSachDiemTra': danhSachDiemTra,
        'hoatDong': hoatDong,
      };

  factory TuyenXe.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TuyenXe(
      id: doc.id,
      diemDi: d['diemDi'] ?? '',
      diemDen: d['diemDen'] ?? '',
      khoangCach: (d['khoangCach'] as num?)?.toInt() ?? 0,
      thoiGian: (d['thoiGian'] as num?)?.toInt() ?? 0,
      giaVeCoSo: (d['giaVeCoSo'] as num?)?.toInt() ?? 0,
      danhSachDiemDon: List<String>.from(d['danhSachDiemDon'] ?? []),
      danhSachDiemTra: List<String>.from(d['danhSachDiemTra'] ?? []),
      hoatDong: d['hoatDong'] ?? true,
    );
  }
}

class LichChay {
  final String? id;
  final String tuyenId;
  final String diemDi;
  final String diemDen;
  final String ngay;
  final String gio;
  final String loaiXe;
  final int soGheToiDa;
  final int soGheConLai;
  final String trangThai;
  final String xeId;
  final String taiXeId;
  final String bienSoXe;
  final String tenTaiXe;

  const LichChay({
    this.id,
    required this.tuyenId,
    required this.diemDi,
    required this.diemDen,
    required this.ngay,
    required this.gio,
    required this.loaiXe,
    required this.soGheToiDa,
    required this.soGheConLai,
    required this.trangThai,
    this.xeId = '',
    this.taiXeId = '',
    this.bienSoXe = '',
    this.tenTaiXe = '',
  });

  Map<String, dynamic> toMap() => {
        'tuyenId': tuyenId, 'diemDi': diemDi, 'diemDen': diemDen,
        'ngay': ngay, 'gio': gio, 'loaiXe': loaiXe,
        'soGheToiDa': soGheToiDa, 'soGheConLai': soGheConLai,
        'trangThai': trangThai,
        if (xeId.isNotEmpty) 'xeId': xeId,
        if (taiXeId.isNotEmpty) 'taiXeId': taiXeId,
        if (bienSoXe.isNotEmpty) 'bienSoXe': bienSoXe,
        if (tenTaiXe.isNotEmpty) 'tenTaiXe': tenTaiXe,
      };

  factory LichChay.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LichChay(
      id: doc.id,
      tuyenId: d['tuyenId'] ?? '',
      diemDi: d['diemDi'] ?? '',
      diemDen: d['diemDen'] ?? '',
      ngay: d['ngay'] ?? '',
      gio: d['gio'] ?? '',
      loaiXe: d['loaiXe'] ?? '',
      soGheToiDa: (d['soGheToiDa'] as num?)?.toInt() ?? 0,
      soGheConLai: (d['soGheConLai'] as num?)?.toInt() ?? 0,
      trangThai: d['trangThai'] ?? 'cho',
      xeId: d['xeId'] ?? '',
      taiXeId: d['taiXeId'] ?? '',
      bienSoXe: d['bienSoXe'] ?? '',
      tenTaiXe: d['tenTaiXe'] ?? '',
    );
  }
}

class Xe {
  final String? id;
  final String bienSo;
  final String loaiXe;
  final int soGhe;
  final String trangThai;

  const Xe({
    this.id,
    required this.bienSo,
    required this.loaiXe,
    required this.soGhe,
    required this.trangThai,
  });

  Map<String, dynamic> toMap() => {
        'bienSo': bienSo, 'loaiXe': loaiXe,
        'soGhe': soGhe, 'trangThai': trangThai,
      };

  factory Xe.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Xe(
      id: doc.id,
      bienSo: d['bienSo'] ?? '',
      loaiXe: d['loaiXe'] ?? '',
      soGhe: (d['soGhe'] as num?)?.toInt() ?? 0,
      trangThai: d['trangThai'] ?? 'san_sang',
    );
  }
}

class TaiXe {
  final String? id;
  final String ten;
  final String sdt;
  final String soGPLX;
  final String ngaySinh;
  final String trangThai;

  const TaiXe({
    this.id,
    required this.ten,
    required this.sdt,
    required this.soGPLX,
    required this.ngaySinh,
    required this.trangThai,
  });

  Map<String, dynamic> toMap() => {
        'ten': ten, 'sdt': sdt,
        'soGPLX': soGPLX, 'ngaySinh': ngaySinh,
        'trangThai': trangThai,
      };

  factory TaiXe.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TaiXe(
      id: doc.id,
      ten: d['ten'] ?? '',
      sdt: d['sdt'] ?? '',
      soGPLX: d['soGPLX'] ?? '',
      ngaySinh: d['ngaySinh'] ?? '',
      trangThai: d['trangThai'] ?? 'san_sang',
    );
  }
}

class KhuyenMai {
  final String? id;
  final String ma;
  final String ten;
  final String loaiGiam;
  final int giaTriGiam;
  final int giaTriToiDa;
  final String ngayBatDau;
  final String ngayKetThuc;
  final int gioiHanSuDung;
  final int daSuDung;
  final String trangThai;

  const KhuyenMai({
    this.id,
    required this.ma,
    required this.ten,
    required this.loaiGiam,
    required this.giaTriGiam,
    required this.giaTriToiDa,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.gioiHanSuDung,
    required this.daSuDung,
    required this.trangThai,
  });

  Map<String, dynamic> toMap() => {
        'ma': ma, 'ten': ten, 'loaiGiam': loaiGiam,
        'giaTriGiam': giaTriGiam, 'giaTriToiDa': giaTriToiDa,
        'ngayBatDau': ngayBatDau, 'ngayKetThuc': ngayKetThuc,
        'gioiHanSuDung': gioiHanSuDung, 'daSuDung': daSuDung,
        'trangThai': trangThai,
      };

  factory KhuyenMai.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KhuyenMai(
      id: doc.id,
      ma: d['ma'] ?? '',
      ten: d['ten'] ?? '',
      loaiGiam: d['loaiGiam'] ?? 'phan_tram',
      giaTriGiam: (d['giaTriGiam'] as num?)?.toInt() ?? 0,
      giaTriToiDa: (d['giaTriToiDa'] as num?)?.toInt() ?? 0,
      ngayBatDau: d['ngayBatDau'] ?? '',
      ngayKetThuc: d['ngayKetThuc'] ?? '',
      gioiHanSuDung: (d['gioiHanSuDung'] as num?)?.toInt() ?? 0,
      daSuDung: (d['daSuDung'] as num?)?.toInt() ?? 0,
      trangThai: d['trangThai'] ?? 'hoat_dong',
    );
  }
}

class KhieuNai {
  final String? id;
  final String userId;
  final String tenKhachHang;
  final String tieuDe;
  final String noiDung;
  final String maVe;
  final String trangThai;
  final String ngayTao;
  final String phanHoi;
  final String ngayPhanHoi;

  const KhieuNai({
    this.id,
    required this.userId,
    required this.tenKhachHang,
    required this.tieuDe,
    required this.noiDung,
    required this.maVe,
    required this.trangThai,
    required this.ngayTao,
    required this.phanHoi,
    required this.ngayPhanHoi,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId, 'tenKhachHang': tenKhachHang,
        'tieuDe': tieuDe, 'noiDung': noiDung, 'maVe': maVe,
        'trangThai': trangThai, 'ngayTao': ngayTao,
        'phanHoi': phanHoi, 'ngayPhanHoi': ngayPhanHoi,
      };

  factory KhieuNai.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KhieuNai(
      id: doc.id,
      userId: d['userId'] ?? '',
      tenKhachHang: d['tenKhachHang'] ?? '',
      tieuDe: d['tieuDe'] ?? '',
      noiDung: d['noiDung'] ?? '',
      maVe: d['maVe'] ?? '',
      trangThai: d['trangThai'] ?? 'cho_xu_ly',
      ngayTao: d['ngayTao'] ?? '',
      phanHoi: d['phanHoi'] ?? '',
      ngayPhanHoi: d['ngayPhanHoi'] ?? '',
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
  CollectionReference get _nhanVien => _db.collection('nhan_vien');
  CollectionReference get _lichSuSoat => _db.collection('lich_su_soat');
  CollectionReference get _admin => _db.collection('admin');
  CollectionReference get _tuyenXe => _db.collection('tuyen_xe');
  CollectionReference get _lichChay => _db.collection('lich_chay');
  CollectionReference get _xe => _db.collection('xe');
  CollectionReference get _taiXe => _db.collection('tai_xe');
  CollectionReference get _khuyenMai => _db.collection('khuyen_mai');
  CollectionReference get _khieuNai => _db.collection('khieu_nai');
  CollectionReference get _cauHinh => _db.collection('cau_hinh');

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

  // ---------- NHAN VIEN ----------

  Future<NhanVien?> dangNhapNhanVien({
    required String maNV,
    required String matKhau,
  }) async {
    final hash = hashMatKhau(matKhau);
    final q = await _nhanVien.where('maNV', isEqualTo: maNV).get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    if (data['matKhau'] != hash) return null;
    return NhanVien.fromDoc(doc);
  }

  Future<void> taoNhanVien({
    required String ten,
    required String maNV,
    required String matKhau,
  }) async {
    final q = await _nhanVien.where('maNV', isEqualTo: maNV).get();
    if (q.docs.isNotEmpty) return;
    await _nhanVien.add({
      'ten': ten,
      'maNV': maNV,
      'matKhau': hashMatKhau(matKhau),
    });
  }

  Future<Ve?> timVeTheoMaVe(String maVe) async {
    final q = await _ve.where('maVe', isEqualTo: maVe).get();
    if (q.docs.isEmpty) return null;
    return Ve.fromDoc(q.docs.first);
  }

  Future<void> luuLichSuSoat(String maNV, Ve ve, String ghiChu) async {
    await _lichSuSoat.add({
      'maNV': maNV,
      'maVe': ve.maVe,
      'diemDi': ve.diemDi,
      'diemDen': ve.diemDen,
      'ngay': ve.ngay,
      'gio': ve.gio,
      'danhSachGhe': ve.danhSachGhe,
      'loaiXe': ve.loaiXe,
      'ghiChu': ghiChu,
      'thoiGian': DateTime.now().toIso8601String(),
      'ngayLuu': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    });
  }

  Future<List<Map<String, dynamic>>> layLichSuSoat(String maNV) async {
    final n = DateTime.now();
    final today = '${n.day}/${n.month}/${n.year}';
    final q = await _lichSuSoat.where('maNV', isEqualTo: maNV).get();
    final list = q.docs
        .map((d) => d.data() as Map<String, dynamic>)
        .where((d) => d['ngayLuu'] == today)
        .toList();
    list.sort((a, b) {
      final ta = (a['thoiGian'] ?? '').toString();
      final tb = (b['thoiGian'] ?? '').toString();
      return tb.compareTo(ta);
    });
    return list;
  }

  // ---------- ADMIN ----------

  Future<Admin?> dangNhapAdmin({
    required String maTK,
    required String matKhau,
  }) async {
    final hash = hashMatKhau(matKhau);
    final q = await _admin.where('maTK', isEqualTo: maTK).get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    if (data['matKhau'] != hash) return null;
    return Admin.fromDoc(doc);
  }

  Future<void> taoAdmin({
    required String ten,
    required String maTK,
    required String matKhau,
  }) async {
    final q = await _admin.where('maTK', isEqualTo: maTK).get();
    if (q.docs.isNotEmpty) return;
    await _admin.add({
      'ten': ten,
      'maTK': maTK,
      'matKhau': hashMatKhau(matKhau),
    });
  }

  Future<List<Admin>> layTatCaAdmin() async {
    final q = await _admin.get();
    return q.docs.map((d) => Admin.fromDoc(d)).toList();
  }

  Future<List<Ve>> layTatCaVe({String? ngay}) async {
    Query q = _ve;
    if (ngay != null) q = q.where('ngay', isEqualTo: ngay);
    final snap = await q.get();
    final list = snap.docs.map((d) => Ve.fromDoc(d)).toList();
    list.sort((a, b) => b.ngayDat.compareTo(a.ngayDat));
    return list;
  }

  Future<List<NhanVien>> layTatCaNhanVien() async {
    final q = await _nhanVien.get();
    return q.docs.map((d) => NhanVien.fromDoc(d)).toList();
  }

  Future<void> xoaNhanVien(String id) async {
    await _nhanVien.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> layLichSuSoatTatCa(
      {String? ngay, bool tatCa = false}) async {
    Query q = _lichSuSoat;
    if (!tatCa) {
      final n = DateTime.now();
      final today = ngay ?? '${n.day}/${n.month}/${n.year}';
      q = q.where('ngayLuu', isEqualTo: today);
    }
    final snap = await q.get();
    final list =
        snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
    list.sort((a, b) {
      final ta = (a['thoiGian'] ?? '').toString();
      final tb = (b['thoiGian'] ?? '').toString();
      return tb.compareTo(ta);
    });
    return list;
  }

  // ---------- TUYEN XE ----------

  Future<List<TuyenXe>> layTatCaTuyen() async {
    final q = await _tuyenXe.get();
    return q.docs.map((d) => TuyenXe.fromDoc(d)).toList();
  }

  Future<void> taoTuyen(TuyenXe tuyen) async =>
      _tuyenXe.add(tuyen.toMap());

  Future<void> capNhatTuyen(String id, TuyenXe tuyen) async =>
      _tuyenXe.doc(id).update(tuyen.toMap());

  Future<void> xoaTuyen(String id) async =>
      _tuyenXe.doc(id).delete();

  // ---------- LICH CHAY ----------

  Future<List<LichChay>> layLichChay(
      {String? tuyenId, String? ngay}) async {
    Query q = _lichChay;
    if (tuyenId != null) q = q.where('tuyenId', isEqualTo: tuyenId);
    if (ngay != null) q = q.where('ngay', isEqualTo: ngay);
    final snap = await q.get();
    return snap.docs.map((d) => LichChay.fromDoc(d)).toList();
  }

  Future<void> taoLichChay(LichChay lich) async =>
      _lichChay.add(lich.toMap());

  Future<void> capNhatLichChay(String id, Map<String, dynamic> data) async =>
      _lichChay.doc(id).update(data);

  Future<void> xoaLichChay(String id) async =>
      _lichChay.doc(id).delete();

  // ---------- XE ----------

  Future<List<Xe>> layTatCaXe() async {
    final q = await _xe.get();
    return q.docs.map((d) => Xe.fromDoc(d)).toList();
  }

  Future<void> taoXe(Xe xe) async => _xe.add(xe.toMap());

  Future<void> capNhatXe(String id, Map<String, dynamic> data) async =>
      _xe.doc(id).update(data);

  Future<void> xoaXe(String id) async => _xe.doc(id).delete();

  // ---------- TAI XE ----------

  Future<List<TaiXe>> layTatCaTaiXe() async {
    final q = await _taiXe.get();
    return q.docs.map((d) => TaiXe.fromDoc(d)).toList();
  }

  Future<void> taoTaiXe(TaiXe tx) async => _taiXe.add(tx.toMap());

  Future<void> capNhatTaiXe(String id, Map<String, dynamic> data) async =>
      _taiXe.doc(id).update(data);

  Future<void> xoaTaiXe(String id) async => _taiXe.doc(id).delete();

  // ---------- KHUYEN MAI ----------

  Future<List<KhuyenMai>> layTatCaKhuyenMai() async {
    final q = await _khuyenMai.get();
    return q.docs.map((d) => KhuyenMai.fromDoc(d)).toList();
  }

  Future<void> taoKhuyenMai(KhuyenMai km) async =>
      _khuyenMai.add(km.toMap());

  Future<void> capNhatKhuyenMai(String id, KhuyenMai km) async =>
      _khuyenMai.doc(id).update(km.toMap());

  Future<void> tangDaSuDungKhuyenMai(String id) async =>
      _khuyenMai.doc(id).update({'daSuDung': FieldValue.increment(1)});

  /// Kiểm tra và áp dụng mã khuyến mãi.
  /// Trả về (giảm giá VNĐ, KhuyenMai) hoặc (0, null) nếu không hợp lệ.
  Future<(int, KhuyenMai?)> apDungKhuyenMai(String ma, int giaGoc) async {
    if (ma.isEmpty) return (0, null);
    final q = await _khuyenMai
        .where('ma', isEqualTo: ma.toUpperCase())
        .get();
    if (q.docs.isEmpty) return (0, null);

    final km = KhuyenMai.fromDoc(q.docs.first);
    if (km.trangThai != 'hoat_dong') return (0, null);
    if (km.gioiHanSuDung > 0 && km.daSuDung >= km.gioiHanSuDung) {
      return (0, null);
    }

    int giam;
    if (km.loaiGiam == 'phan_tram') {
      giam = (giaGoc * km.giaTriGiam / 100).round();
      if (km.giaTriToiDa > 0 && giam > km.giaTriToiDa) {
        giam = km.giaTriToiDa;
      }
    } else {
      giam = km.giaTriGiam;
    }
    if (giam > giaGoc) giam = giaGoc;
    if (giam < 0) giam = 0;
    return (giam, km);
  }

  Future<void> capNhatTrangThaiKhuyenMai(
          String id, String trangThai) async =>
      _khuyenMai.doc(id).update({'trangThai': trangThai});

  Future<void> xoaKhuyenMai(String id) async =>
      _khuyenMai.doc(id).delete();

  // ---------- KHIEU NAI ----------

  Future<List<KhieuNai>> layTatCaKhieuNai() async {
    final q = await _khieuNai.get();
    final list = q.docs.map((d) => KhieuNai.fromDoc(d)).toList();
    list.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
    return list;
  }

  Future<void> guiKhieuNai(KhieuNai kn) async =>
      _khieuNai.add(kn.toMap());

  Future<void> phanHoiKhieuNai(String id, String phanHoi) async {
    final now = DateTime.now();
    await _khieuNai.doc(id).update({
      'phanHoi': phanHoi,
      'trangThai': 'da_xu_ly',
      'ngayPhanHoi': '${now.day}/${now.month}/${now.year}',
    });
  }

  Future<void> capNhatTrangThaiKhieuNai(
          String id, String trangThai) async =>
      _khieuNai.doc(id).update({'trangThai': trangThai});

  // ---------- NGUOI DUNG ADMIN ----------

  Future<List<NguoiDung>> layTatCaNguoiDung() async {
    final q = await _nguoiDung.get();
    return q.docs.map((d) => NguoiDung.fromDoc(d)).toList();
  }

  Future<void> khoaTaiKhoan(String id, bool khoa) async =>
      _nguoiDung.doc(id).update({'biKhoa': khoa});

  // ---------- VE ADMIN ----------

  Future<void> capNhatTrangThaiVe(String id, String trangThai) async =>
      _ve.doc(id).update({'trangThai': trangThai});

  // ---------- CAU HINH ----------

  Future<Map<String, dynamic>> layCauHinh() async {
    final doc = await _cauHinh.doc('cai_dat').get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> capNhatCauHinh(Map<String, dynamic> data) async =>
      _cauHinh.doc('cai_dat').set(data, SetOptions(merge: true));
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