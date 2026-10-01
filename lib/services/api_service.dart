import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isBackendOnline = false;

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isBackendOnline => _isBackendOnline;

  // Local caching for real church database fallback
  List<JemaatMember>? _cachedMembers;
  List<KeluargaJemaat>? _cachedFamilies;
  List<TransaksiKeuangan>? _cachedTransactions;
  final List<TransaksiKeuangan> _localAddedTransactions = [];

  void setToken(String? token) {
    _token = token;
  }

  // ---------------------------------------------------------------------------
  // HEALTH CHECK
  // ---------------------------------------------------------------------------
  Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/stats');
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(
        const Duration(seconds: 4),
      );
      _isBackendOnline = res.statusCode >= 200 && res.statusCode < 500;
      return _isBackendOnline;
    } catch (_) {
      _isBackendOnline = false;
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final res = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeoutDuration);

      final Map<String, dynamic> data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        _token = data['data']?['token'];
        _currentUser = data['data']?['user'];
        _isBackendOnline = true;
        return {
          'success': true,
          'token': _token,
          'user': _currentUser,
          'role': _mapBackendRoleToUserRole(
            _currentUser?['role']?.toString() ?? '',
            _currentUser?['division']?.toString(),
          ),
        };
      } else {
        return {
          'success': false,
          'statusCode': data['status_code'] ?? 'AUTH_FAILED',
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } on SocketException catch (_) {
      _isBackendOnline = false;
      return {
        'success': false,
        'isOffline': true,
        'message': 'Tidak dapat terhubung ke server Laravel (${ApiConfig.baseUrl}).',
      };
    } on TimeoutException catch (_) {
      _isBackendOnline = false;
      return {
        'success': false,
        'isOffline': true,
        'message': 'Koneksi ke backend timeout.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
        await http.post(uri, headers: ApiConfig.headers(token: _token)).timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {}
    }
    _token = null;
    _currentUser = null;
  }

  UserRole _mapBackendRoleToUserRole(String role, String? division) {
    final r = role.toUpperCase();
    final d = (division ?? '').toLowerCase();

    if (r == 'BENDAHARA') return UserRole.bendahara;
    if (r == 'SEKRETARIS' || r == 'ADMIN') return UserRole.sekretaris;
    if (r == 'DIAKEN') return UserRole.diaken;
    if (r == 'OPERATOR') {
      if (d == 'pemusik') return UserRole.pemusik;
      return UserRole.multimedia;
    }
    return UserRole.jemaat;
  }

  // ---------------------------------------------------------------------------
  // MEMBERS & DATA JEMAAT
  // ---------------------------------------------------------------------------
  Future<List<JemaatMember>> fetchMembers({
    String? search,
    String? status,
    int? sectorId,
  }) async {
    try {
      final queryParams = <String, String>{'per_page': '100'};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty && status != 'Semua Status') {
        queryParams['status'] = status.toUpperCase();
      }
      if (sectorId != null) queryParams['sector_id'] = sectorId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/members').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data']?['data'] ?? body['data']) as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          _isBackendOnline = true;
          return list.map((json) => _parseJemaatMember(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchMembers error: $e');
    }

    // Fallback: Real imported 624 members
    return _loadFallbackMembers(search: search, status: status, sectorId: sectorId);
  }

  Future<bool> createMember(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/members');
      final res = await http
          .post(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMember(String id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/members/$id');
      final res = await http
          .put(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMember(String id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/members/$id');
      final res = await http
          .delete(uri, headers: ApiConfig.headers(token: _token))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // DIGITAL KARTU KELUARGA (KK)
  // ---------------------------------------------------------------------------
  Future<List<KeluargaJemaat>> fetchFamilies({String? search, int? sectorId}) async {
    try {
      final queryParams = <String, String>{'per_page': '50'};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sectorId != null) queryParams['sector_id'] = sectorId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/families').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data']?['data'] ?? body['data']) as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          _isBackendOnline = true;
          return list.map((json) => _parseKeluargaJemaat(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchFamilies error: $e');
    }

    // Fallback: Real imported families
    return _loadFallbackFamilies(search: search, sectorId: sectorId);
  }

  // ---------------------------------------------------------------------------
  // INVENTARIS & ASET
  // ---------------------------------------------------------------------------
  Future<List<InventarisItem>> fetchAssets({String? division}) async {
    try {
      final queryParams = <String, String>{};
      if (division != null && division.isNotEmpty && division != 'Semua Divisi' && division != 'all') {
        queryParams['division'] = division.toLowerCase();
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/assets').replace(queryParameters: queryParams);
      final res = await http
          .get(uri, headers: ApiConfig.headers(token: _token, division: division?.toLowerCase()))
          .timeout(ApiConfig.timeoutDuration);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data']?['data'] ?? body['data']) as List<dynamic>?;
        if (list != null) {
          _isBackendOnline = true;
          return list.map((json) => _parseInventarisItem(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchAssets error: $e');
    }
    return [];
  }

  Future<bool> createAsset(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/assets');
      final res = await http
          .post(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAsset(String id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/assets/$id');
      final res = await http
          .put(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAsset(String id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/assets/$id');
      final res = await http
          .delete(uri, headers: ApiConfig.headers(token: _token))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // MINISTRY: PEMUSIK & MULTIMEDIA
  // ---------------------------------------------------------------------------
  Future<List<MinistryMember>> fetchMinistryMembers({
    String? division,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (division != null && division.isNotEmpty && division != 'all') {
        queryParams['division'] = division.toLowerCase();
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/members').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data']?['members'] ?? body['data']) as List<dynamic>?;
        if (list != null) {
          _isBackendOnline = true;
          return list.map((json) => _parseMinistryMember(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchMinistryMembers error: $e');
    }
    return [];
  }

  Future<bool> createMinistryMember(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/members');
      final res = await http
          .post(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMinistryMember(String id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/members/$id');
      final res = await http
          .put(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMinistryMember(String id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/members/$id');
      final res = await http
          .delete(uri, headers: ApiConfig.headers(token: _token))
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkInOfficer(String officerId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/officers/$officerId/check-in');
      final res = await http.post(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> substituteOfficer(
    String officerId,
    String substituteName,
    String reason,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ministry/officers/$officerId/substitute');
      final res = await http
          .post(
            uri,
            headers: ApiConfig.headers(token: _token),
            body: jsonEncode({
              'substitute_name': substituteName,
              'reason': reason,
            }),
          )
          .timeout(ApiConfig.timeoutDuration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // FINANCE & BENDAHARA (REALTIME & OFFLINE REAL DATABASE)
  // ---------------------------------------------------------------------------
  Future<List<CashBook>> fetchCashBooks() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/finance/cash-books');
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data']?['cash_books'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          _isBackendOnline = true;
          return list.map((j) => CashBook.fromJson(j)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchCashBooks error: $e');
    }

    // Fallback: Real calculation from imported church transactions
    final allTxs = await fetchTransactions();
    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in allTxs) {
      if (tx.status != 'VOID') {
        if (tx.jenis == JenisTransaksi.pemasukan) {
          totalIncome += tx.jumlah;
        } else {
          totalExpense += tx.jumlah;
        }
      }
    }
    // Opening balance 15jt for Kas Umum
    final runningKU = 15000000.0 + totalIncome - totalExpense;

    return [
      CashBook(
        id: 1,
        code: 'KU',
        name: 'Kas Umum Gereja',
        description: 'Buku Kas Operasional Utama GKPI Cimahi',
        currentBalance: runningKU,
      ),
      CashBook(
        id: 2,
        code: 'KP',
        name: 'Kas Pembangunan',
        description: 'Buku Kas Pembangunan Fisik Gereja',
        currentBalance: 35000000.0,
      ),
    ];
  }

  Future<List<TransaksiKeuangan>> fetchTransactions({
    int? cashBookId,
    String? search,
    String? type,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, String>{'per_page': (perPage ?? 200).toString()};
      if (cashBookId != null) queryParams['cash_book_id'] = cashBookId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (type != null && type.isNotEmpty && type != 'all') queryParams['type'] = type.toUpperCase();

      final uri = Uri.parse('${ApiConfig.baseUrl}/finance/transactions').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token)).timeout(ApiConfig.timeoutDuration);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data']?['data'] ?? body['data']) as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          _isBackendOnline = true;
          return list.map((j) => TransaksiKeuangan.fromJson(j)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchTransactions error: $e');
    }

    // Fallback: Real imported 200 transactions
    return _loadFallbackTransactions(search: search, type: type);
  }

  Future<bool> createTransaction(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/finance/transactions');
      final res = await http
          .post(uri, headers: ApiConfig.headers(token: _token), body: jsonEncode(data))
          .timeout(ApiConfig.timeoutDuration);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendOnline = true;
        return true;
      }
    } catch (_) {}

    // Offline mode: store in local list
    final rawAmount = (data['amount'] is num)
        ? (data['amount'] as num).toDouble()
        : double.tryParse(data['amount'].toString()) ?? 0.0;
    final isIncome = (data['type'] ?? 'INCOME').toString().toUpperCase() == 'INCOME';

    final newTx = TransaksiKeuangan(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      tanggal: data['transaction_date'] ?? DateTime.now().toString().substring(0, 10),
      keterangan: data['description'] ?? 'Transaksi Baru',
      kategori: 'Kas Umum',
      jenis: isIncome ? JenisTransaksi.pemasukan : JenisTransaksi.pengeluaran,
      jumlah: rawAmount,
      reference: data['reference']?.toString(),
      cashBookCode: 'KU',
      status: 'POSTED',
    );
    _localAddedTransactions.insert(0, newTx);
    return true;
  }

  // ---------------------------------------------------------------------------
  // FALLBACK REAL DATABASE LOADERS (FROM BUNDLED ASSETS)
  // ---------------------------------------------------------------------------
  Future<List<JemaatMember>> _loadFallbackMembers({
    String? search,
    String? status,
    int? sectorId,
  }) async {
    if (_cachedMembers == null) {
      try {
        final rawStr = await rootBundle.loadString('assets/data/members_imported.json');
        final List<dynamic> list = jsonDecode(rawStr);
        _cachedMembers = list.map((j) => _parseJemaatMemberFromImported(j)).toList();
      } catch (e) {
        debugPrint('[ApiService] Failed loading members_imported.json: $e');
        _cachedMembers = [];
      }
    }

    var result = List<JemaatMember>.from(_cachedMembers!);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((m) =>
        m.namaLengkap.toLowerCase().contains(q) ||
        m.noRegister.toLowerCase().contains(q) ||
        (m.noKk != null && m.noKk!.toLowerCase().contains(q))
      ).toList();
    }
    if (status != null && status.isNotEmpty && status != 'Semua Status') {
      final st = status.toLowerCase();
      result = result.where((m) => m.status.toLowerCase() == st).toList();
    }
    if (sectorId != null) {
      final sec = 'Sektor $sectorId';
      result = result.where((m) => m.sektor == sec).toList();
    }
    return result;
  }

  Future<List<KeluargaJemaat>> _loadFallbackFamilies({
    String? search,
    int? sectorId,
  }) async {
    if (_cachedFamilies == null) {
      try {
        final rawStr = await rootBundle.loadString('assets/data/families_imported.json');
        final List<dynamic> list = jsonDecode(rawStr);
        _cachedFamilies = list.map((j) => _parseKeluargaJemaatFromImported(j)).toList();
      } catch (e) {
        debugPrint('[ApiService] Failed loading families_imported.json: $e');
        _cachedFamilies = [];
      }
    }

    var result = List<KeluargaJemaat>.from(_cachedFamilies!);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((f) =>
        f.namaKeluarga.toLowerCase().contains(q) ||
        f.noKk.toLowerCase().contains(q) ||
        f.kepalaKeluarga.toLowerCase().contains(q)
      ).toList();
    }
    if (sectorId != null) {
      final sec = 'Sektor $sectorId';
      result = result.where((f) => f.sektor == sec).toList();
    }
    return result;
  }

  Future<List<TransaksiKeuangan>> _loadFallbackTransactions({
    String? search,
    String? type,
  }) async {
    if (_cachedTransactions == null) {
      try {
        final rawStr = await rootBundle.loadString('assets/data/transactions_imported.json');
        final List<dynamic> list = jsonDecode(rawStr);
        _cachedTransactions = list.asMap().entries.map((entry) {
          final idx = entry.key;
          final j = entry.value as Map<String, dynamic>;
          final isIncome = (j['type'] ?? 'INCOME').toString().toUpperCase() == 'INCOME';
          return TransaksiKeuangan(
            id: 'imported_$idx',
            tanggal: j['transaction_date'] ?? '2026-01-04',
            keterangan: j['description'] ?? '',
            kategori: 'Kas Umum',
            jenis: isIncome ? JenisTransaksi.pemasukan : JenisTransaksi.pengeluaran,
            jumlah: (j['amount'] is num)
                ? (j['amount'] as num).toDouble()
                : double.tryParse(j['amount']?.toString() ?? '0') ?? 0.0,
            reference: j['reference']?.toString(),
            cashBookCode: j['cash_book_code'] ?? 'KU',
            status: j['status'] ?? 'POSTED',
          );
        }).toList();
      } catch (e) {
        debugPrint('[ApiService] Failed loading transactions_imported.json: $e');
        _cachedTransactions = [];
      }
    }

    // Merge any locally added items
    var result = [..._localAddedTransactions, ..._cachedTransactions!];

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((t) =>
        t.keterangan.toLowerCase().contains(q) ||
        (t.reference != null && t.reference!.toLowerCase().contains(q))
      ).toList();
    }
    if (type != null && type.isNotEmpty && type != 'all') {
      final isIncomeReq = type.toUpperCase() == 'INCOME';
      result = result.where((t) =>
        (t.jenis == JenisTransaksi.pemasukan) == isIncomeReq
      ).toList();
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // JSON PARSERS & MAPPERS
  // ---------------------------------------------------------------------------
  JemaatMember _parseJemaatMember(Map<String, dynamic> json) {
    String rawStatus = (json['status'] ?? 'ACTIVE').toString().toUpperCase();
    String mappedStatus;
    if (rawStatus == 'ACTIVE') {
      mappedStatus = 'Aktif';
    } else if (rawStatus == 'MOVED') {
      mappedStatus = 'Pindah';
    } else if (rawStatus == 'DECEASED') {
      mappedStatus = 'Meninggal';
    } else {
      mappedStatus = 'Nonaktif';
    }

    final family = json['family'] as Map<String, dynamic>?;
    final familyMember = json['family_member'] as Map<String, dynamic>?;
    final sacraments = (json['sacraments'] as List<dynamic>?) ?? [];

    bool baptis = sacraments.any((s) => s['sacrament_type']?.toString().toUpperCase() == 'BAPTISM');
    bool sidi = sacraments.any((s) => s['sacrament_type']?.toString().toUpperCase() == 'CONFIRMATION');
    bool nikah = sacraments.any((s) => s['sacrament_type']?.toString().toUpperCase() == 'MARRIAGE');

    String rel = familyMember?['relationship']?.toString() ?? 'HEAD';
    String mappedRel;
    if (rel == 'HEAD') {
      mappedRel = 'Kepala Keluarga';
    } else if (rel == 'SPOUSE') {
      mappedRel = 'Istri';
    } else if (rel == 'CHILD') {
      mappedRel = 'Anak';
    } else {
      mappedRel = 'Famili / Lainnya';
    }

    return JemaatMember(
      id: json['id']?.toString() ?? '',
      noRegister: json['register_number'] ?? '',
      namaLengkap: json['full_name'] ?? '',
      sektor: json['sector']?['name'] ?? (json['sector_id'] != null ? 'Sektor ${json['sector_id']}' : 'Sektor 1'),
      status: mappedStatus,
      tglLahir: json['birth_date'] ?? '-',
      isBaptis: baptis,
      isSidi: sidi,
      isNikah: nikah,
      noKk: family?['family_number'],
      namaKeluarga: family?['family_name'],
      hubunganKeluarga: mappedRel,
      isKepalaKeluarga: mappedRel == 'Kepala Keluarga',
      telepon: json['phone'],
      alamat: json['address'] ?? family?['address'],
      pekerjaan: json['occupation'],
      jenisKelamin: json['gender'] ?? 'L',
    );
  }

  JemaatMember _parseJemaatMemberFromImported(Map<String, dynamic> json) {
    String rawStatus = (json['status'] ?? 'ACTIVE').toString().toUpperCase();
    String mappedStatus = 'Aktif';
    if (rawStatus == 'MOVED') mappedStatus = 'Pindah';
    if (rawStatus == 'DECEASED') mappedStatus = 'Meninggal';
    if (rawStatus == 'INACTIVE') mappedStatus = 'Nonaktif';

    String secCode = json['sector_code']?.toString() ?? 'SEKTOR_1';
    String sectorName = secCode.replaceAll('_', ' ').toLowerCase();
    sectorName = sectorName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');

    String rel = (json['relationship'] ?? 'HEAD').toString().toUpperCase();
    String mappedRel = 'Kepala Keluarga';
    if (rel == 'SPOUSE') mappedRel = 'Istri';
    if (rel == 'CHILD') mappedRel = 'Anak';
    if (rel == 'OTHER') mappedRel = 'Famili / Lainnya';

    return JemaatMember(
      id: json['register_number'] ?? '',
      noRegister: json['register_number'] ?? '',
      namaLengkap: json['full_name'] ?? '',
      sektor: sectorName,
      status: mappedStatus,
      tglLahir: json['birth_date'] ?? '-',
      isBaptis: json['baptism_date'] != null,
      isSidi: json['confirmation_date'] != null,
      isNikah: json['marriage_date'] != null,
      noKk: json['family_number'],
      namaKeluarga: json['family_name'],
      hubunganKeluarga: mappedRel,
      isKepalaKeluarga: json['is_head'] == true || rel == 'HEAD',
      telepon: json['phone'],
      alamat: json['address'],
      pekerjaan: json['occupation'],
      jenisKelamin: json['gender'] ?? 'L',
    );
  }

  KeluargaJemaat _parseKeluargaJemaat(Map<String, dynamic> json) {
    final membersList = (json['members'] as List<dynamic>?) ?? [];
    final anggota = membersList.map((m) => _parseJemaatMember(m)).toList();
    final head = anggota.firstWhere(
      (m) => m.isKepalaKeluarga,
      orElse: () => anggota.isNotEmpty ? anggota.first : JemaatMember(
        id: '0',
        noRegister: '',
        namaLengkap: json['family_name'] ?? '-',
        sektor: json['sector']?['name'] ?? 'Sektor 1',
        status: 'Aktif',
        tglLahir: '-',
      ),
    );

    return KeluargaJemaat(
      id: json['id']?.toString() ?? '',
      noKk: json['family_number'] ?? '',
      namaKeluarga: json['family_name'] ?? '',
      sektor: json['sector']?['name'] ?? 'Sektor 1',
      kepalaKeluarga: head.namaLengkap,
      alamat: json['address'] ?? '-',
      telepon: json['phone'] ?? head.telepon ?? '-',
      jumlahAnggota: json['members_count'] ?? anggota.length,
      anggota: anggota,
    );
  }

  KeluargaJemaat _parseKeluargaJemaatFromImported(Map<String, dynamic> json) {
    String secCode = json['sector_code']?.toString() ?? 'SEKTOR_1';
    String sectorName = secCode.replaceAll('_', ' ').toLowerCase();
    sectorName = sectorName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');

    return KeluargaJemaat(
      id: json['family_number'] ?? '',
      noKk: json['family_number'] ?? '',
      namaKeluarga: json['family_name'] ?? '',
      sektor: sectorName,
      kepalaKeluarga: json['family_name']?.toString().replaceFirst('Kel. ', '') ?? '-',
      alamat: json['address'] ?? '-',
      telepon: json['phone'] ?? '-',
      jumlahAnggota: 1,
      anggota: [],
    );
  }

  InventarisItem _parseInventarisItem(Map<String, dynamic> json) {
    return InventarisItem(
      id: json['id']?.toString() ?? '',
      kode: json['code'] ?? json['kode'] ?? '',
      namaAset: json['name'] ?? json['nama_aset'] ?? '',
      lokasi: json['location'] ?? json['lokasi'] ?? '',
      jumlah: json['quantity'] ?? json['jumlah'] ?? 1,
      kondisi: json['condition'] ?? json['kondisi'] ?? 'Baik',
      status: json['status'] ?? 'Tersedia',
      division: (json['division'] ?? 'umum').toString().toLowerCase(),
      category: json['category'],
    );
  }

  MinistryMember _parseMinistryMember(Map<String, dynamic> json) {
    return MinistryMember(
      id: json['id']?.toString() ?? '',
      division: (json['division'] ?? 'pemusik').toString().toLowerCase(),
      name: json['name'] ?? '',
      roleTitle: json['role_title'] ?? '',
      phone: json['phone'] ?? '',
      notes: json['notes'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}
