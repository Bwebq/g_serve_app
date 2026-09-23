import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

class LandingScreen extends StatefulWidget {
  final void Function(UserRole role) onLoginSuccess;

  const LandingScreen({super.key, required this.onLoginSuccess});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  bool _isPasswordObscured = true;
  bool _showLoginForm = false;
  bool _userFocus = false;
  bool _passFocus = false;
  bool _loginShake = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userFocusNode.addListener(
      () => setState(() => _userFocus = _userFocusNode.hasFocus),
    );
    _passFocusNode.addListener(
      () => setState(() => _passFocus = _passFocusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  void _openLoginForm() {
    setState(() {
      _showLoginForm = true;
    });
  }

  void _closeLoginForm() {
    setState(() {
      _showLoginForm = false;
    });
  }

  void _handleLogin([UserRole? role]) {
    if (role != null) {
      widget.onLoginSuccess(role);
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      setState(() => _loginShake = true);
      return;
    }
    final user = _usernameController.text.trim().toLowerCase();
    if (user.contains('bendahara')) {
      widget.onLoginSuccess(UserRole.bendahara);
    } else if (user.contains('sekretaris')) {
      widget.onLoginSuccess(UserRole.sekretaris);
    } else if (user.contains('diaken')) {
      widget.onLoginSuccess(UserRole.diaken);
    } else {
      widget.onLoginSuccess(UserRole.jemaat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcherSlide(
      child: _showLoginForm
          ? _buildDedicatedLoginScreen(context)
          : Scaffold(
              key: const ValueKey('landing-main'),
              backgroundColor: AppTheme.heroDarkBlue,
              body: SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildHeaderBar(context),
                      _buildHeroSection(context),
                      _buildFeaturesSection(context),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEDICATED LOGIN SCREEN
  // ---------------------------------------------------------------------------
  Widget _buildDedicatedLoginScreen(BuildContext context) {
    return Scaffold(
      key: const ValueKey('login-screen'),
      backgroundColor: AppTheme.landingBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ScaleOnTap(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
            tooltip: 'Kembali ke Beranda',
            onPressed: _closeLoginForm,
          ),
        ),
        title: BouncyPress(
          onTap: _closeLoginForm,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 18, color: AppTheme.primaryBlue),
              SizedBox(width: 6),
              Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: FadeSlideAnimation(
                delay: const Duration(milliseconds: 80),
                duration: AppMotion.slow,
                child: _buildLoginCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER BAR
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      color: AppTheme.heroDarkBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Logo Square
          const ProfessionalLogo(size: 38, padding: 3.0, borderRadius: 8),
          const SizedBox(width: 10),

          // Logo Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'G-SERVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'GKPI Cimahi',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Desktop/Tablet Menu Links
          if (!isMobile) ...[
            _buildNavButton(
              'Beranda',
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
            ),
            const SizedBox(width: 16),
            _buildNavButton(
              'Fitur',
              onTap: () {
                _scrollController.animateTo(
                  600,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            const SizedBox(width: 16),
            _buildNavButton('Tentang', onTap: _openLoginForm),
            const SizedBox(width: 16),
            _buildNavButton('Kontak', onTap: _openLoginForm),
            const SizedBox(width: 24),
          ],

          // Primary Red Action Button
          ScaleOnTap(
            child: ElevatedButton(
              onPressed: _openLoginForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Masuk Aplikasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN HERO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.heroDarkBlue,
            AppTheme.heroBlue,
            AppTheme.heroDarkBlue,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Central Large Logo Badge with Pulse
          ScaleInAnimation(
            delay: const Duration(milliseconds: 200),
            beginScale: 0.5,
            child: PulseAnimation(
              minScale: 0.97,
              maxScale: 1.03,
              duration: const Duration(milliseconds: 3000),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.church,
                    color: AppTheme.primaryBlue,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // System Badge Pill
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 400),
            slideBegin: const Offset(0, 0.3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  SizedBox(width: 8),
                  Text(
                    'Sistem Manajemen Gereja Digital',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '  \u2014  GKPI Jemaat Cimahi',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Main Headline "G-SERVE"
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 550),
            child: const Text(
              'G-SERVE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 650),
            child: const Text(
              'Pelayanan Gereja Digital',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Paragraph Description
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 750),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const Text(
                'Platform digital terpadu untuk manajemen operasional GKPI \u2014 mulai dari data jemaat, keuangan gereja, inventaris aset, hingga warta dan jadwal pelayanan. Satu sistem, semua terkelola.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 900),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ScaleOnTap(
                  child: ElevatedButton.icon(
                    onPressed: _openLoginForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.buttonRed.withValues(alpha: 0.5),
                    ),
                    icon: const Text(
                      'Masuk ke Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    label: const Icon(Icons.arrow_forward, size: 18),
                  ),
                ),

                ScaleOnTap(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _scrollController.animateTo(
                        600,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Text(
                      'Lihat Fitur',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    label: const Icon(Icons.keyboard_arrow_down, size: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURES HIGHLIGHT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.people_alt_outlined,
        'title': 'Data Jemaat',
        'desc':
            'Pengelolaan database jemaat, sektor, dan keluarga secara terstruktur & terpusat.',
      },
      {
        'icon': Icons.calendar_month_outlined,
        'title': 'Jadwal Pelayanan',
        'desc':
            'Manajemen jadwal ibadah minggu, pelayan liturgi, pengkhotbah, dan petugas multimedia.',
      },
      {
        'icon': Icons.newspaper_outlined,
        'title': 'Warta & Pengumuman',
        'desc':
            'Publikasi warta jemaat digital dan pengumuman kegiatan gereja secara realtime.',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Keuangan & Aset',
        'desc':
            'Laporan persembahan, anggaran kas gereja, serta inventarisasi barang secara transparan.',
      },
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Column(
        children: [
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Fitur Unggulan G-SERVE',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDarkBlue,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Kemudahan pelayanan gereja dalam satu genggaman',
              style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
            ),
          ),
          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 800
                  ? 4
                  : (constraints.maxWidth > 500 ? 2 : 1);
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(features.length, (i) {
                  final f = features[i];
                  final width =
                      (constraints.maxWidth - (crossCount - 1) * 16) /
                      crossCount;
                  return FadeSlideAnimation(
                    delay: Duration(milliseconds: 300 + i * 120),
                    slideBegin: const Offset(0, 0.15),
                    child: ScaleOnTap(
                      child: SizedBox(
                        width: width,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.borderGrey),
                          ),
                          color: AppTheme.backgroundGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    f['icon'] as IconData,
                                    color: AppTheme.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  f['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  f['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 12.5,
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
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIN FORM CARD
  // ---------------------------------------------------------------------------
  Widget _buildLoginCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Center Circular Logo
        ScaleInAnimation(
          delay: const Duration(milliseconds: 100),
          child: const ProfessionalLogo(size: 72, padding: 8, borderRadius: 36),
        ),

        const SizedBox(height: 16),

        // Title
        const Text(
          'Masuk ke G-SERVE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sistem Manajemen GKPI Jemaat Cimahi',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),

        const SizedBox(height: 24),

        // White Form Card Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notice Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC7DCFA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppTheme.primaryBlue,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Akses terbatas \u2014 hanya untuk personel gereja yang berwenang',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // USERNAME
                const Text(
                  'USERNAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ShakeAnimation(
                  shake: _loginShake,
                  onFinish: () => setState(() => _loginShake = false),
                  child: AnimatedInput(
                    hasFocus: _userFocus,
                    child: TextFormField(
                      controller: _usernameController,
                      focusNode: _userFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Username Anda',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedInput(
                  hasFocus: _passFocus,
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passFocusNode,
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'Password Anda',
                      suffixIcon: ScaleOnTap(
                        child: IconButton(
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordObscured = !_isPasswordObscured,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                BouncyPress(
                  onTap: () => _handleLogin(),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text(
                        'Masuk ke Sistem',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Role Explanation Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'AKSES BERDASARKAN PERAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 14),

              _buildRoleRow(
                color: const Color(0xFF059669),
                role: 'Bendahara Gereja',
                description:
                    'Akses laporan keuangan, kas, & pencatatan transaksi',
              ),
              const SizedBox(height: 10),

              _buildRoleRow(
                color: AppTheme.primaryBlue,
                role: 'Admin',
                description: 'Akses penuh ke seluruh modul sistem',
              ),
              const SizedBox(height: 10),

              _buildRoleRow(
                color: AppTheme.secondaryBlue,
                role: 'Operator',
                description:
                    'Akses terbatas sesuai divisi (Multimedia, Pemusik, Diaken, dll)',
              ),
              const SizedBox(height: 10),

              _buildRoleRow(
                color: Colors.green.shade600,
                role: 'Jemaat',
                description:
                    'Lihat jadwal ibadah, warta, dan pengumuman gereja',
              ),
              const SizedBox(height: 10),

              _buildRoleRow(
                color: const Color(0xFFD97706),
                role: 'Bendahara',
                description: 'Kelola keuangan gereja & laporan kas periode',
              ),

              const SizedBox(height: 18),

              const Divider(color: AppTheme.borderGrey, height: 1),

              const SizedBox(height: 14),

              Text(
                'Tidak punya akun? Hubungi sekretariat GKPI Cimahi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Akun Demo Header Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_outlined, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Akun Demo (Development)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Dark Terminal-Style Demo Accounts Box (Matching User's Screenshot)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark slate navy
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terminal Header
              const Text(
                '# username / password',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              _buildDemoAccountRow(
                username: 'admin',
                password: 'admin123',
                roleLabel: 'Administrator',
                targetRole: UserRole.jemaat,
              ),
              _buildDemoAccountRow(
                username: 'multimedia',
                password: 'op123',
                roleLabel: 'Operator Multimedia',
                targetRole: UserRole.jemaat,
              ),
              _buildDemoAccountRow(
                username: 'musik',
                password: 'op123',
                roleLabel: 'Operator Pemusik',
                targetRole: UserRole.jemaat,
              ),
              _buildDemoAccountRow(
                username: 'diaken',
                password: 'op123',
                roleLabel: 'Operator Diaken',
                targetRole: UserRole.diaken,
              ),
              _buildDemoAccountRow(
                username: 'bendahara',
                password: 'op123',
                roleLabel: 'Operator Bendahara',
                targetRole: UserRole.bendahara,
              ),
              _buildDemoAccountRow(
                username: 'sekretaris',
                password: 'op123',
                roleLabel: 'Operator Sekretaris',
                targetRole: UserRole.sekretaris,
              ),
              _buildDemoAccountRow(
                username: 'jemaat',
                password: 'jemaat123',
                roleLabel: 'Jemaat',
                targetRole: UserRole.jemaat,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoAccountRow({
    required String username,
    required String password,
    required String roleLabel,
    required UserRole targetRole,
  }) {
    return InkWell(
      onTap: () {
        _usernameController.text = username;
        _passwordController.text = password;
        _handleLogin(targetRole);
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 2.0),
        child: Row(
          children: [
            Text(
              username,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: Color(0xFF34D399), // Emerald cyan
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              '  /  $password ',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: Text(
                '($roleLabel)',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRow({
    required Color color,
    required String role,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              children: [
                TextSpan(
                  text: '$role \u2014 ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(
                  text: description,
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: AppTheme.heroDarkBlue,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: const [
          Text(
            'GKPI Jemaat Cimahi \u00a9 2025 G-SERVE System',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            'Satu Sistem, Semua Terkelola',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
