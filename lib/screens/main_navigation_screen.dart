import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import 'beranda_screen.dart';
import 'placeholder_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainNavigationScreen({super.key, this.onLogout});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.heroDarkBlue, AppTheme.primaryBlue],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Row: Logo, Title, and Action Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // White square card for GKPI Logo
                        const ProfessionalLogo(
                          size: 42,
                          padding: 4.0,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 12),
                        // Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'G-SERVE Jemaat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'GKPI Cimahi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout / Exit button
                        ScaleOnTap(
                          child: IconButton(
                            onPressed: () {
                              if (widget.onLogout != null) {
                                widget.onLogout!();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Keluar dari aplikasi'),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Keluar',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bottom TabBar Row
                  TabBar(
                    indicatorColor: AppTheme.accentRed,
                    indicatorWeight: 3.5,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 1),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.menu_book, size: 16),
                            SizedBox(height: 3),
                            Text(
                              'Beranda',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_month_outlined, size: 16),
                            SizedBox(height: 3),
                            Text(
                              'Jadwal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.notifications_none_outlined, size: 16),
                            SizedBox(height: 3),
                            Text(
                              'Warta',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.campaign_outlined, size: 16),
                            SizedBox(height: 3),
                            Text(
                              'Pengumuman',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            FadeSlideAnimation(
              duration: AppMotion.medium,
              child: const BerandaScreen(),
            ),
            FadeSlideAnimation(
              duration: AppMotion.medium,
              slideBegin: const Offset(0, 0.05),
              child: const JadwalScreen(),
            ),
            FadeSlideAnimation(
              duration: AppMotion.medium,
              slideBegin: const Offset(0, 0.05),
              child: const WartaScreen(),
            ),
            FadeSlideAnimation(
              duration: AppMotion.medium,
              slideBegin: const Offset(0, 0.05),
              child: const PengumumanScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
