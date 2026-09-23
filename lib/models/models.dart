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

enum UserRole { jemaat, bendahara, sekretaris, diaken }

enum JenisTransaksi { pemasukan, pengeluaran }

class TransaksiKeuangan {
  final String id;
  final String tanggal;
  final String keterangan;
  final String kategori;
  final JenisTransaksi jenis;
  final double jumlah;

  TransaksiKeuangan({
    required this.id,
    required this.tanggal,
    required this.keterangan,
    required this.kategori,
    required this.jenis,
    required this.jumlah,
  });
}

class JemaatMember {
  final String id;
  final String noRegister;
  final String namaLengkap;
  final String sektor;
  final String status; // 'Aktif', 'Pindah', 'Meninggal'
  final String tglLahir;
  final bool isBaptis;
  final bool isSidi;
  final bool isNikah;

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
  });
}

class InventarisItem {
  final String id;
  final String kode;
  final String namaAset;
  final String lokasi;
  final int jumlah;
  final String kondisi; // 'Baik', 'Perbaikan', 'Rusak'
  final String status; // 'Tersedia', 'Tidak Tersedia'

  InventarisItem({
    required this.id,
    required this.kode,
    required this.namaAset,
    required this.lokasi,
    required this.jumlah,
    required this.kondisi,
    required this.status,
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
