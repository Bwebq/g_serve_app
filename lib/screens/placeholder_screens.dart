import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

// --- Helper: Show Detail Bottom Sheet Card ---
void _showDetailBottomSheet(BuildContext context, {required Widget child}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// --- Jadwal Screen ---
class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listJadwal = [
      JadwalItem(
        kegiatan: 'Ibadah Minggu Pagi',
        tanggal: 'Minggu, 10 Agustus 2025',
        pukul: '09:00 WIB',
        lokasi: 'Gedung Gereja GKPI Cimahi',
        deskripsi:
            'Ibadah Minggu Pagi bersama seluruh jemaat. Mari datang tepat waktu dan mempersiapkan hati untuk beribadah.',
        kategori: 'Ibadah',
      ),
      JadwalItem(
        kegiatan: 'Ibadah Sekolah Minggu',
        tanggal: 'Minggu, 10 Agustus 2025',
        pukul: '07:30 WIB',
        lokasi: 'Ruang Sekolah Minggu',
        deskripsi:
            'Kegiatan ibadah dan belajar Alkitab untuk anak-anak usia sekolah. Ada pemandu dan cerita menarik.',
        kategori: 'Sekolah Minggu',
      ),
      JadwalItem(
        kegiatan: 'PA Sektor 1-5',
        tanggal: 'Jumat, 15 Agustus 2025',
        pukul: '19:00 WIB',
        lokasi: 'Balai Warga Sektor 3',
        deskripsi:
            'Persekutuan Antar Sektor untuk berbagi firman dan doa bersama. Seluruh anggota sektor diundang hadir.',
        kategori: 'Persekutuan',
      ),
      JadwalItem(
        kegiatan: 'Ibadah Kemerdekaan RI',
        tanggal: 'Minggu, 17 Agustus 2025',
        pukul: '09:00 WIB',
        lokasi: 'Gedung Gereja GKPI Cimahi',
        deskripsi:
            'Ibadah syukur HUT Kemerdekaan RI ke-80 bersama jemaat. Mengenakan pakaian nasional.',
        kategori: 'Ibadah Khusus',
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: StaggeredColumn(
          itemCount: listJadwal.length,
          staggerDelay: const Duration(milliseconds: 100),
          itemBuilder: (context, index) {
            final item = listJadwal[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScaleOnTap(
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showJadwalDetail(context, item),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlueCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      title: Text(
                        item.kegiatan,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${item.tanggal} • ${item.pukul}',
                        style: const TextStyle(color: AppTheme.textGrey),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showJadwalDetail(BuildContext context, JadwalItem item) {
  _showDetailBottomSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.lightBlueCard,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.kategori.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          item.kegiatan,
          style: const TextStyle(
            color: AppTheme.textDarkBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _detailRow(Icons.calendar_today_outlined, item.tanggal),
                const SizedBox(height: 10),
                _detailRow(Icons.access_time_outlined, item.pukul),
                const SizedBox(height: 10),
                _detailRow(Icons.location_on_outlined, item.lokasi),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: AppTheme.borderGrey, height: 1),
        const SizedBox(height: 16),
        const Text(
          'DESKRIPSI',
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.deskripsi,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget _detailRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: AppTheme.primaryBlue, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// --- Warta Jemaat Screen ---
class WartaScreen extends StatelessWidget {
  const WartaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listWarta = [
      WartaItem(
        edisi: 'Warta Jemaat 3 Agustus 2025',
        keterangan: 'Edisi Minggu VIII',
        ukuran: '2.4 MB',
        ringkasan:
            'Edisi minggu ini memuat khotbah tentang kasih kristus, laporan kegiatan sepekan, dan jadwal pelayanan.',
        daftarIsi: [
          'Khotbah: Kasih Kristus Yang Menguatkan',
          'Laporan Keuangan Gereja',
          'Jadwal Pelayanan Minggu Depan',
          'Berita Duka & Syukur',
          'Info Kegiatan Sektor',
        ],
      ),
      WartaItem(
        edisi: 'Warta Jemaat 27 Juli 2025',
        keterangan: 'Edisi Minggu VII',
        ukuran: '1.9 MB',
        ringkasan:
            'Edisi ini membahas topik keselamatan dan pembaruan hidup rohani serta info pendaftaran baptisan.',
        daftarIsi: [
          'Khotbah: Jalan Keselamatan',
          'Pengumuman Pendaftaran Baptisan',
          'Jadwal Pekan Immanuel',
          'Data Jemaat Baru',
        ],
      ),
      WartaItem(
        edisi: 'Warta Jemaat 20 Juli 2025',
        keterangan: 'Edisi Minggu VI',
        ukuran: '2.1 MB',
        ringkasan:
            'Edisi pembuka bulan Agustus dengan tema syukur dan persiapan menyongsong HUT RI ke-80.',
        daftarIsi: [
          'Khotbah: Hidup Bersyukur',
          'Rencana HUT Kemerdekaan',
          'Laporan Kunjungan Pendeta',
          'Agenda Gotong Royong',
          'Info Camping Pemuda',
        ],
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: StaggeredColumn(
          itemCount: listWarta.length,
          staggerDelay: const Duration(milliseconds: 100),
          itemBuilder: (context, index) {
            final item = listWarta[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScaleOnTap(
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showWartaDetail(context, item),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: AppTheme.accentRed,
                        ),
                      ),
                      title: Text(
                        item.edisi,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${item.keterangan} • ${item.ukuran}',
                        style: const TextStyle(color: AppTheme.textGrey),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showWartaDetail(BuildContext context, WartaItem item) {
  _showDetailBottomSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'WARTA JEMAAT',
            style: TextStyle(
              color: AppTheme.accentRed,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          item.edisi,
          style: const TextStyle(
            color: AppTheme.textDarkBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.keterangan}  •  ${item.ukuran}',
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Divider(color: AppTheme.borderGrey, height: 1),
        const SizedBox(height: 16),
        const Text(
          'RINGKASAN',
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.ringkasan,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DAFTAR ISI',
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        ...item.daftarIsi.map(
          (isi) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    isi,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mengunduh ${item.edisi}...')),
              );
            },
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text(
              'Unduh PDF',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );
}

// --- Pengumuman Screen ---
class PengumumanScreen extends StatelessWidget {
  const PengumumanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listPengumuman = [
      Pengumuman(
        judul: 'Ibadah HUT GKPI ke-62',
        deskripsi:
            'Diselenggarakan Minggu, 3 Agustus 2025 pukul 09.00 WIB. Semua jemaat diundang hadir.',
        tipe: TipePengumuman.penting,
        tanggalInfo: 'Diposting 29 Juli 2025',
      ),
      Pengumuman(
        judul: 'Pendaftaran Baptisan & Sidi',
        deskripsi:
            'Dibuka hingga 15 Agustus 2025. Formulir pendaftaran dapat diambil melalui sekretariat gereja.',
        tipe: TipePengumuman.info,
        tanggalInfo: 'Diposting 25 Juli 2025',
      ),
      Pengumuman(
        judul: 'Gotong Royong Kebersihan Gereja',
        deskripsi:
            'Diadakan pada hari Sabtu, 9 Agustus 2025 mulai pukul 08.00 WIB. Harap membawa alat kebersihan.',
        tipe: TipePengumuman.info,
        tanggalInfo: 'Diposting 1 Agustus 2025',
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: StaggeredColumn(
          itemCount: listPengumuman.length,
          staggerDelay: const Duration(milliseconds: 100),
          itemBuilder: (context, index) {
            final item = listPengumuman[index];
            final isPenting = item.tipe == TipePengumuman.penting;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScaleOnTap(
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showPengumumanDetail(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPenting
                                      ? AppTheme.badgeRedBg
                                      : AppTheme.badgeBlueBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPenting
                                          ? Icons.priority_high
                                          : Icons.info_outline,
                                      color: isPenting
                                          ? AppTheme.badgeRedText
                                          : AppTheme.badgeBlueText,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPenting ? 'Penting' : 'Info',
                                      style: TextStyle(
                                        color: isPenting
                                            ? AppTheme.badgeRedText
                                            : AppTheme.badgeBlueText,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.tanggalInfo,
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.deskripsi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showPengumumanDetail(BuildContext context, Pengumuman item) {
  final isPenting = item.tipe == TipePengumuman.penting;
  _showDetailBottomSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isPenting ? AppTheme.badgeRedBg : AppTheme.badgeBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPenting ? 'PENTING' : 'INFO',
                style: TextStyle(
                  color: isPenting
                      ? AppTheme.badgeRedText
                      : AppTheme.badgeBlueText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.tanggalInfo,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.judul,
          style: const TextStyle(
            color: AppTheme.textDarkBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: AppTheme.borderGrey, height: 1),
        const SizedBox(height: 16),
        Text(
          item.deskripsi,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}
