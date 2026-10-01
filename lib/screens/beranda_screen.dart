import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/animations.dart';
import '../utils/date_helper.dart';
import '../widgets/welcome_card.dart';
import '../widgets/service_card.dart';
import '../widgets/announcements_card.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcomingSunday = DateHelper.getNextOrCurrentSunday();
    final nextSunday = DateHelper.getSunday(1);

    // Mock user data matching screenshot
    final jemaatMock = Jemaat(
      nama: 'Ester Simanjorang',
      sektor: 'Sektor 5',
      inisial: 'E',
    );

    // Mock service data matching screenshot
    final ibadahMock = Ibadah(
      tanggal: DateHelper.formatFullDate(upcomingSunday),
      judul: 'Ibadah Minggu Pagi',
      waktu: '09:00 WIB',
      lokasi: 'Gedung Gereja GKPI Cimahi',
      temaKhotbah: 'Kasih Kristus Yang Menguatkan',
      bacaanAlkitab: 'Yohanes 15:9-17',
      pelayan: [
        Pelayan(
          peran: 'Pengkhotbah',
          nama: 'Pdt. Saut Nainggolan',
          iconKey: 'mic',
        ),
        Pelayan(
          peran: 'Liturgis',
          nama: 'Ev. Tiur Simbolon',
          iconKey: 'liturgis',
        ),
        Pelayan(
          peran: 'Songs Leader',
          nama: 'Marlina Tampubolon',
          iconKey: 'music',
        ),
        Pelayan(
          peran: 'Multimedia',
          nama: 'Ruli Manurung',
          iconKey: 'multimedia',
        ),
      ],
    );

    // Mock announcements matching screenshot
    final pengumumanMock = [
      Pengumuman(
        judul: 'Ibadah HUT GKPI ke-62',
        deskripsi:
            'Diselenggarakan ${DateHelper.formatFullDate(upcomingSunday)} pukul 09.00 WIB. Semua jemaat diundang hadir.',
        tipe: TipePengumuman.penting,
        tanggalInfo: '',
      ),
      Pengumuman(
        judul: 'Pendaftaran Baptisan & Sidi',
        deskripsi:
            'Dibuka hingga ${DateHelper.formatFullDate(nextSunday)}. Formulir pendaftaran dapat diambil melalui sekretariat gereja.',
        tipe: TipePengumuman.info,
        tanggalInfo: '',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top:
            false, // Main navigation screen will handle the top safe area / header
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredColumn(
                itemCount: 3,
                staggerDelay: const Duration(milliseconds: 120),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ScaleOnTap(
                          child: WelcomeCard(jemaat: jemaatMock),
                        ),
                      );
                    case 1:
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ScaleOnTap(
                          child: ServiceCard(ibadah: ibadahMock),
                        ),
                      );
                    default:
                      return ScaleOnTap(
                        child: AnnouncementsCard(
                          listPengumuman: pengumumanMock,
                          onSeeAllPressed: () {
                            // Action for seeing all announcements
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Menampilkan semua pengumuman'),
                              ),
                            );
                          },
                          onAnnouncementPressed: (announcement) {
                            // Detail action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Detail: ${announcement.judul}'),
                              ),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
