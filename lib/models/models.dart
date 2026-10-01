class Jemaat {
  final String nama;
  final String sektor;
  final String inisial;

  Jemaat({required this.nama, required this.sektor, required this.inisial});

  factory Jemaat.fromJson(Map<String, dynamic> json) {
    return Jemaat(
      nama: json['nama'] ?? '',
      sektor: json['sektor'] ?? '',
      inisial: json['inisial'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'sektor': sektor, 'inisial': inisial};
  }
}

class Pelayan {
  final String peran;
  final String nama;
  final String iconKey; // Identifier for selecting icons dynamically

  Pelayan({required this.peran, required this.nama, required this.iconKey});

  factory Pelayan.fromJson(Map<String, dynamic> json) {
    return Pelayan(
      peran: json['peran'] ?? '',
      nama: json['nama'] ?? '',
      iconKey: json['icon_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'peran': peran, 'nama': nama, 'icon_key': iconKey};
  }
}

class Ibadah {
  final String tanggal;
  final String judul;
  final String waktu;
  final String lokasi;
  final String temaKhotbah;
  final String bacaanAlkitab;
  final List<Pelayan> pelayan;

  Ibadah({
    required this.tanggal,
    required this.judul,
    required this.waktu,
    required this.lokasi,
    required this.temaKhotbah,
    required this.bacaanAlkitab,
    required this.pelayan,
  });

  factory Ibadah.fromJson(Map<String, dynamic> json) {
    var list = json['pelayan'] as List?;
    List<Pelayan> pelayanList = list != null
        ? list.map((i) => Pelayan.fromJson(i)).toList()
        : [];

    return Ibadah(
      tanggal: json['tanggal'] ?? '',
      judul: json['judul'] ?? '',
      waktu: json['waktu'] ?? '',
      lokasi: json['lokasi'] ?? '',
      temaKhotbah: json['tema_khotbah'] ?? '',
      bacaanAlkitab: json['bacaan_alkitab'] ?? '',
      pelayan: pelayanList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'judul': judul,
      'waktu': waktu,
      'lokasi': lokasi,
      'tema_khotbah': temaKhotbah,
      'bacaan_alkitab': bacaanAlkitab,
      'pelayan': pelayan.map((p) => p.toJson()).toList(),
    };
  }
}

enum TipePengumuman { penting, info }

class Pengumuman {
  final String judul;
  final String deskripsi;
  final TipePengumuman tipe;
  final String tanggalInfo;

  Pengumuman({
    required this.judul,
    required this.deskripsi,
    required this.tipe,
    required this.tanggalInfo,
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tipe: json['tipe'] == 'penting'
          ? TipePengumuman.penting
          : TipePengumuman.info,
      tanggalInfo: json['tanggal_info'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'tipe': tipe == TipePengumuman.penting ? 'penting' : 'info',
      'tanggal_info': tanggalInfo,
    };
  }
}

class JadwalItem {
  final String kegiatan;
  final String tanggal;
  final String pukul;
  final String lokasi;
  final String deskripsi;
  final String kategori;

  JadwalItem({
    required this.kegiatan,
    required this.tanggal,
    required this.pukul,
    required this.lokasi,
    required this.deskripsi,
    required this.kategori,
  });
}

class WartaItem {
  final String edisi;
  final String keterangan;
  final String ukuran;
  final String ringkasan;
  final List<String> daftarIsi;

  WartaItem({
    required this.edisi,
    required this.keterangan,
    required this.ukuran,
    required this.ringkasan,
    required this.daftarIsi,
  });
}

enum UserRole { jemaat, bendahara, sekretaris, diaken, multimedia, pemusik }

enum JenisTransaksi { pemasukan, pengeluaran }

class CashBook {
  final int id;
  final String code;
  final String name;
  final String? description;
  final double currentBalance;
  final bool isActive;

  CashBook({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.currentBalance,
    this.isActive = true,
  });

  factory CashBook.fromJson(Map<String, dynamic> json) {
    return CashBook(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      currentBalance: (json['current_balance'] is num)
          ? (json['current_balance'] as num).toDouble()
          : double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class TransaksiKeuangan {
  final String id;
  final String tanggal;
  final String keterangan;
  final String kategori;
  final JenisTransaksi jenis;
  final double jumlah;
  final String? reference;
  final String? cashBookCode;
  final String? status;
  final double? runningBalance;

  TransaksiKeuangan({
    required this.id,
    required this.tanggal,
    required this.keterangan,
    required this.kategori,
    required this.jenis,
    required this.jumlah,
    this.reference,
    this.cashBookCode = 'KU',
    this.status = 'POSTED',
    this.runningBalance,
  });

  factory TransaksiKeuangan.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? json['jenis'] ?? 'INCOME').toString().toUpperCase();
    final isPemasukan = rawType == 'INCOME' || rawType == 'PEMASUKAN';
    final amount = (json['amount'] is num)
        ? (json['amount'] as num).toDouble()
        : (json['jumlah'] is num)
            ? (json['jumlah'] as num).toDouble()
            : double.tryParse(json['amount']?.toString() ?? json['jumlah']?.toString() ?? '0') ?? 0.0;

    return TransaksiKeuangan(
      id: json['id']?.toString() ?? '',
      tanggal: json['transaction_date'] ?? json['tanggal'] ?? '',
      keterangan: json['description'] ?? json['keterangan'] ?? '',
      kategori: json['category']?['name'] ?? json['category'] ?? json['kategori'] ?? 'Kas Umum',
      jenis: isPemasukan ? JenisTransaksi.pemasukan : JenisTransaksi.pengeluaran,
      jumlah: amount,
      reference: json['reference']?.toString(),
      cashBookCode: json['cash_book_code'] ?? json['cash_book']?['code'] ?? 'KU',
      status: json['status'] ?? 'POSTED',
      runningBalance: (json['running_balance'] is num)
          ? (json['running_balance'] as num).toDouble()
          : double.tryParse(json['running_balance']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_date': tanggal,
      'description': keterangan,
      'category': kategori,
      'type': jenis == JenisTransaksi.pemasukan ? 'INCOME' : 'EXPENSE',
      'amount': jumlah,
      'reference': reference,
      'cash_book_code': cashBookCode,
      'status': status,
    };
  }
}

class JemaatMember {
  final String id;
  final String noRegister;
  final String namaLengkap;
  final String sektor;
  final String status; // 'Aktif', 'Pindah', 'Meninggal', 'Nonaktif'
  final String tglLahir;
  final bool isBaptis;
  final bool isSidi;
  final bool isNikah;
  final String? noKk;
  final String? namaKeluarga;
  final String hubunganKeluarga; // 'Kepala Keluarga', 'Istri', 'Anak', 'Orang Tua', 'Famili / Lainnya'
  final bool isKepalaKeluarga;
  final String? telepon;
  final String? alamat;
  final String? pekerjaan;
  final String? jenisKelamin; // 'L' | 'P'

  JemaatMember({
    required this.id,
    required this.noRegister,
    required this.namaLengkap,
    required this.sektor,
    required this.status,
    required this.tglLahir,
    this.isBaptis = true,
    this.isSidi = true,
    this.isNikah = false,
    this.noKk,
    this.namaKeluarga,
    this.hubunganKeluarga = 'Kepala Keluarga',
    this.isKepalaKeluarga = false,
    this.telepon,
    this.alamat,
    this.pekerjaan,
    this.jenisKelamin = 'L',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'register_number': noRegister,
      'full_name': namaLengkap,
      'sektor': sektor,
      'status': status == 'Aktif'
          ? 'ACTIVE'
          : status == 'Pindah'
              ? 'MOVED'
              : status == 'Meninggal'
                  ? 'DECEASED'
                  : 'INACTIVE',
      'birth_date': tglLahir,
      'is_baptis': isBaptis,
      'is_sidi': isSidi,
      'is_nikah': isNikah,
      'family_number': noKk,
      'family_name': namaKeluarga,
      'relationship': hubunganKeluarga,
      'phone': telepon,
      'address': alamat,
      'occupation': pekerjaan,
      'gender': jenisKelamin,
    };
  }
}

class KeluargaJemaat {
  final String id;
  final String noKk;
  final String namaKeluarga;
  final String sektor;
  final String kepalaKeluarga;
  final String alamat;
  final String telepon;
  final int jumlahAnggota;
  final List<JemaatMember> anggota;

  KeluargaJemaat({
    required this.id,
    required this.noKk,
    required this.namaKeluarga,
    required this.sektor,
    required this.kepalaKeluarga,
    required this.alamat,
    required this.telepon,
    required this.jumlahAnggota,
    required this.anggota,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_number': noKk,
      'family_name': namaKeluarga,
      'sektor': sektor,
      'head_name': kepalaKeluarga,
      'address': alamat,
      'phone': telepon,
      'members_count': jumlahAnggota,
    };
  }
}

class InventarisItem {
  final String id;
  final String kode;
  final String namaAset;
  final String lokasi;
  final int jumlah;
  final String kondisi; // 'Baik', 'Perbaikan', 'Rusak'
  final String status; // 'Tersedia', 'Tidak Tersedia'
  final String division; // 'umum', 'pemusik', 'multimedia'
  final String? category;

  InventarisItem({
    required this.id,
    required this.kode,
    required this.namaAset,
    required this.lokasi,
    required this.jumlah,
    required this.kondisi,
    required this.status,
    this.division = 'umum',
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': kode,
      'kode': kode,
      'name': namaAset,
      'nama_aset': namaAset,
      'location': lokasi,
      'lokasi': lokasi,
      'quantity': jumlah,
      'jumlah': jumlah,
      'condition': kondisi,
      'kondisi': kondisi,
      'status': status,
      'division': division,
      'category': category,
    };
  }
}

class MinistryMember {
  final String id;
  final String division; // 'pemusik' | 'multimedia'
  final String name;
  final String roleTitle; // e.g. 'Pianist / Keyboard', 'Gitaris', 'Operator PPT'
  final String phone;
  final String? notes;
  final bool isActive;

  MinistryMember({
    required this.id,
    required this.division,
    required this.name,
    required this.roleTitle,
    required this.phone,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'division': division,
      'name': name,
      'role_title': roleTitle,
      'phone': phone,
      'notes': notes,
      'is_active': isActive,
    };
  }
}

class MultimediaDutyOfficer {
  final String id;
  final String serviceId;
  final String dutyTitle; // e.g. 'Operator PPT Layar 1 (EasyWorship)', 'Operator OBS Streaming'
  final String officerName;
  String attendanceStatus; // 'SCHEDULED' | 'PRESENT' | 'REPLACED'
  String? attendanceTime;
  String? replacementOfficerName;
  String? replacementReason;
  String? replacedAt;

  MultimediaDutyOfficer({
    required this.id,
    required this.serviceId,
    required this.dutyTitle,
    required this.officerName,
    this.attendanceStatus = 'SCHEDULED',
    this.attendanceTime,
    this.replacementOfficerName,
    this.replacementReason,
    this.replacedAt,
  });
}

class MultimediaSchedule {
  final String id;
  final String serviceDate;
  final String serviceType;
  final String theme;
  final List<MultimediaDutyOfficer> officers;

  MultimediaSchedule({
    required this.id,
    required this.serviceDate,
    required this.serviceType,
    required this.theme,
    required this.officers,
  });
}

class JadwalPelayanDetail {
  final String id;
  final String tglBadge; // e.g. 'AGU 3'
  final String tglLengkap; // e.g. 'Minggu, 3 Agustus 2025'
  final String jenisIbadah; // e.g. 'Ibadah Minggu Pagi'
  final String temaKhotbah; // e.g. '"Kasih Kristus Yang Menguatkan"'
  final String bacaanAlkitab; // e.g. 'Yohanes 15:9-17'
  final String pengkhotbah;
  final String liturgos;
  final String songsLeader;
  final String multimedia;
  final String musisi;
  final String diaken;

  JadwalPelayanDetail({
    required this.id,
    required this.tglBadge,
    required this.tglLengkap,
    required this.jenisIbadah,
    required this.temaKhotbah,
    required this.bacaanAlkitab,
    required this.pengkhotbah,
    required this.liturgos,
    required this.songsLeader,
    required this.multimedia,
    required this.musisi,
    required this.diaken,
  });
}
