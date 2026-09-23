import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AnnouncementsCard extends StatelessWidget {
  final List<Pengumuman> listPengumuman;
  final VoidCallback? onSeeAllPressed;
  final Function(Pengumuman)? onAnnouncementPressed;

  const AnnouncementsCard({
    super.key,
    required this.listPengumuman,
    this.onSeeAllPressed,
    this.onAnnouncementPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAllPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Semua',
                        style: TextStyle(
                          color: AppTheme.secondaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.secondaryBlue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderGrey),

          // Announcements List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listPengumuman.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppTheme.borderGrey,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final item = listPengumuman[index];
              final isPenting = item.tipe == TipePengumuman.penting;

              return InkWell(
                onTap: onAnnouncementPressed != null
                    ? () => onAnnouncementPressed!(item)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPenting
                              ? AppTheme.badgeRedBg
                              : AppTheme.badgeBlueBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPenting
                                ? AppTheme.badgeRedText.withValues(alpha: 0.3)
                                : AppTheme.badgeBlueText.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isPenting ? 'Penting' : 'Info',
                          style: TextStyle(
                            color: isPenting
                                ? AppTheme.badgeRedText
                                : AppTheme.badgeBlueText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.judul,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.deskripsi,
                              style: const TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            if (item.tanggalInfo.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.tanggalInfo,
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
