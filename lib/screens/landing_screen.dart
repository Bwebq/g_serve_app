import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../widgets/server_config_dialog.dart';

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
  bool _isConnecting = false;
  bool _backendOnline = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
    _userFocusNode.addListener(
      () => setState(() => _userFocus = _userFocusNode.hasFocus),
    );
    _passFocusNode.addListener(
      () => setState(() => _passFocus = _passFocusNode.hasFocus),
    );
  }

  Future<void> _checkBackendStatus() async {
    final online = await ApiService.instance.checkConnection();
    if (mounted) {
      setState(() => _backendOnline = online);
    }
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

  void _showLoginBlockedDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.block, color: AppTheme.buttonRed, size: 24),
            SizedBox(width: 8),
            Text('Akses Ditolak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppTheme.textDark),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin([UserRole? directRole]) async {
    if (directRole != null) {
      widget.onLoginSuccess(directRole);
      return;
    }

    final user = _usernameController.text.trim();
    final pass = _passwordController.text;

    if (user.isEmpty) {
      setState(() => _loginShake = true);
      return;
    }

    setState(() => _isConnecting = true);

    // Call Laravel Backend REST API
    final res = await ApiService.instance.login(user, pass.isEmpty ? 'op123' : pass);

    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil! Selamat datang, ${res['user']?['name'] ?? user}.'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onLoginSuccess(res['role'] as UserRole);
      return;
    }

    // Handle status-based restrictions from backend
    final statusCode = res['statusCode']?.toString() ?? '';
    if (statusCode == 'MEMBER_DECEASED') {
      _showLoginBlockedDialog(
        'Status Jemaat Berpulang',
        res['message'] ?? 'Akses ditolak: Data anggota jemaat tercatat telah Berpulang / Meninggal Dunia. Akun ini tidak aktif.',
      );
      return;
    } else if (statusCode == 'MEMBER_MOVED') {
      _showLoginBlockedDialog(
        'Status Jemaat Pindah',
        res['message'] ?? 'Akses ditolak: Status keanggotaan jemaat tercatat telah Pindah (Mutasi ke gereja lain). Akun telah dinonaktifkan.',
      );
      return;
    } else if (statusCode == 'MEMBER_INACTIVE') {
      _showLoginBlockedDialog(
        'Status Jemaat Nonaktif',
        res['message'] ?? 'Akses ditolak: Status keanggotaan jemaat sedang Non-Aktif di GKPI Cimahi. Silakan hubungi Sekretariat / PHJ Gereja.',
      );
      return;
    } else if (statusCode == 'ACCOUNT_INACTIVE') {
      _showLoginBlockedDialog(
        'Akun Dinonaktifkan',
        res['message'] ?? 'Akun pengguna ini dinonaktifkan oleh administrator.',
      );
      return;
    }

    // If server is not reachable, gracefully fallback to local demo mode with notification
    if (res['isOffline'] == true) {
      final userLower = user.toLowerCase();
      if (userLower == 'jemaat-pindah') {
        _showLoginBlockedDialog(
          'Status Jemaat Pindah',
          'Akses Ditolak: Status keanggotaan jemaat tercatat telah Pindah (Mutasi ke gereja lain). Akun telah dinonaktifkan.',
        );
        return;
      } else if (userLower == 'jemaat-wafat') {
        _showLoginBlockedDialog(
          'Status Jemaat Berpulang',
          'Akses Ditolak: Data anggota jemaat tercatat telah Berpulang / Meninggal Dunia. Akun ini tidak aktif.',
        );
        return;
      } else if (userLower == 'jemaat-nonaktif') {
        _showLoginBlockedDialog(
          'Status Jemaat Nonaktif',
          'Akses Ditolak: Status keanggotaan jemaat sedang Non-Aktif di GKPI Cimahi. Silakan hubungi Sekretariat / PHJ Gereja.',
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server backend belum aktif (${ApiConfig.baseUrl}). Masuk via sesi demo offline.'),
          backgroundColor: AppTheme.warningAmber,
          duration: const Duration(seconds: 3),
        ),
      );

      if (userLower.contains('bendahara')) {
        widget.onLoginSuccess(UserRole.bendahara);
      } else if (userLower.contains('sekretaris') || userLower.contains('admin')) {
        widget.onLoginSuccess(UserRole.sekretaris);
      } else if (userLower.contains('diaken')) {
        widget.onLoginSuccess(UserRole.diaken);
      } else if (userLower.contains('multimedia')) {
        widget.onLoginSuccess(UserRole.multimedia);
      } else if (userLower.contains('pemusik') || userLower.contains('musik')) {
        widget.onLoginSuccess(UserRole.pemusik);
      } else {
        widget.onLoginSuccess(UserRole.jemaat);
      }
      return;
    }

    // Authentication failed (wrong credentials)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Username atau password salah.'),
        backgroundColor: AppTheme.buttonRed,
      ),
    );
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
                      _buildStatsSection(context),
                      _buildFeaturesSection(context),
                      _buildHowItWorksSection(context),
                      _buildMissionFocusSection(context),
                      _buildTestimonialsSection(context),
                      _buildBottomCtaSection(context),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet, color: AppTheme.primaryBlue),
            tooltip: 'Atur IP Server',
            onPressed: () => showServerConfigDialog(context, onConfigSaved: _checkBackendStatus),
          ),
          const SizedBox(width: 8),
        ],
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
  // HEADER BAR (Matches Screenshot 1)
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      color: AppTheme.heroDarkerBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 18,
        right: 18,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Logo in white container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.church,
                color: AppTheme.primaryLight,
                size: 24,
              ),
            ),
          ),
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
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'GKPI Cimahi',
                style: TextStyle(
                  color: AppTheme.slate300,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Hamburger Menu Icon
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            tooltip: 'Menu',
            onPressed: () => _openDrawerMenu(context),
          ),
        ],
      ),
    );
  }

  void _openDrawerMenu(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dark Blue Top Bar (Photo 1)
                Container(
                  color: AppTheme.heroDarkerBlue,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(ctx).padding.top + 8,
                    left: 18,
                    right: 18,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.church,
                            color: AppTheme.primaryLight,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'G-SERVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // White Menu Content (Photo 1)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDrawerNavLink(
                        label: 'Beranda',
                        onTap: () {
                          Navigator.pop(ctx);
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      _buildDrawerNavLink(
                        label: 'Fitur',
                        onTap: () {
                          Navigator.pop(ctx);
                          _scrollController.animateTo(
                            560,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      _buildDrawerNavLink(
                        label: 'Tentang',
                        onTap: () {
                          Navigator.pop(ctx);
                          _scrollController.animateTo(
                            2100,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      _buildDrawerNavLink(
                        label: 'Kontak',
                        onTap: () {
                          Navigator.pop(ctx);
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Red Button "Masuk Aplikasi" (Photo 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openLoginForm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Masuk Aplikasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Discreet IP Config link
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            showServerConfigDialog(context, onConfigSaved: _checkBackendStatus);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Server: ${ApiConfig.baseUrl}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate300,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildDrawerNavLink({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN HERO SECTION (Matches Screenshot 1 & 2)
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GridBackgroundPainter(),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.heroDarkerBlue.withValues(alpha: 0.88),
                AppTheme.heroGradientEnd.withValues(alpha: 0.96),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
          child: Column(
            children: [
              // Logo GKPI in white square card
              ScaleInAnimation(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
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
                      color: AppTheme.primaryLight,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Pill Badge: "• Sistem Manajemen Gereja Digital — GKPI Jemaat Cimahi"
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.textDark.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Sistem Manajemen Gereja Digital — GKPI Jemaat Cimahi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Headline: "G-SERVE"
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 400),
                child: const Text(
                  'G-SERVE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle: "Pelayanan Gereja Digital"
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'Pelayanan Gereja Digital',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.blue300,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Description
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 600),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: AppTheme.slate200,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Platform digital terpadu untuk manajemen operasional GKPI — mulai dari data jemaat, keuangan gereja, inventaris aset, hingga warta dan jadwal pelayanan. ',
                        ),
                        TextSpan(
                          text: 'Satu sistem, semua terkelola.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Primary Red Button: Masuk ke Dashboard ->
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 700),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openLoginForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Masuk ke Dashboard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Dark Glass Button: Lihat Fitur v
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 780),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        560,
                        duration: const Duration(milliseconds: 550),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                      backgroundColor: AppTheme.darkSurface.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Lihat Fitur',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Scroll Indicator: "Gulir ke bawah v"
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 880),
                child: Column(
                  children: [
                    Text(
                      'Gulir ke bawah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STATS COUNTER SECTION (Matches Screenshot 2)
  // ---------------------------------------------------------------------------
  Widget _buildStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryLight,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('250+', 'Anggota Jemaat'),
              ),
              Expanded(
                child: _buildStatItem('5 Sektor', 'Wilayah Pelayanan'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('98%', 'Tingkat Akurasi Data'),
              ),
              Expanded(
                child: _buildStatItem('12 Modul', 'Fitur Terintegrasi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURE SECTION (Matches Screenshots 2, 3, 4, 5)
  // ---------------------------------------------------------------------------
  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      const _FeatureItem(
        icon: Icons.grid_view_rounded,
        iconColor: AppTheme.primaryLight,
        title: 'Dashboard Terpadu',
        badge: 'OVERVIEW',
        description:
            'Pantau semua aktivitas gereja dalam satu tampilan — statistik jemaat, ringkasan keuangan, aset, dan jadwal ibadah terdekat secara real-time.',
      ),
      const _FeatureItem(
        icon: Icons.people_alt_rounded,
        iconColor: AppTheme.featurePurple,
        title: 'Manajemen Jemaat',
        badge: 'DATA',
        description:
            'Database lengkap seluruh jemaat dengan nomor register unik, status keanggotaan, sektor, dan riwayat sakramen (Baptis, Sidi, Pernikahan).',
      ),
      const _FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        iconColor: AppTheme.featureGreen,
        title: 'Keuangan Digital',
        badge: 'FINANCE',
        description:
            'Catat pemasukan persembahan, iuran jemaat, dan seluruh pengeluaran operasional gereja. Laporan keuangan siap export ke Excel & PDF.',
      ),
      const _FeatureItem(
        icon: Icons.inventory_2_rounded,
        iconColor: AppTheme.warningAmber,
        title: 'Inventaris & Aset',
        badge: 'ASSETS',
        description:
            'Kelola seluruh aset gereja dengan kode barang unik, pantau kondisi (Baik/Rusak/Perbaikan), dan status ketersediaan untuk kegiatan ibadah.',
      ),
      const _FeatureItem(
        icon: Icons.menu_book_rounded,
        iconColor: AppTheme.buttonRed,
        title: 'Warta & Jadwal',
        badge: 'WORSHIP',
        description:
            'Susun jadwal pelayan ibadah (musisi, songs leader, diaken, multimedia) dan hasilkan warta jemaat siap cetak dalam format PDF/Word.',
      ),
      const _FeatureItem(
        icon: Icons.language_rounded,
        iconColor: AppTheme.featureSky,
        title: 'Laporan & Arsip',
        badge: 'REPORTS',
        description:
            'Semua data tersimpan aman dan bisa diakses kapan saja. Buat laporan bulanan/tahunan untuk Majelis dan laporan ke Sinode GKPI.',
      ),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // Section Header (White)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 20),
            child: Column(
              children: const [
                Text(
                  'FITUR UNGGULAN',
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Semua yang Dibutuhkan Gereja, Dalam Satu Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.darkSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'G-SERVE dirancang khusus untuk kebutuhan operasional Gereja Kristen Protestan Indonesia — intuitif, cepat, dan dapat digunakan oleh siapa saja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          // Cards Container (Off-white / Slate)
          Container(
            width: double.infinity,
            color: AppTheme.surfaceSlate50,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(
              children: [
                for (final item in features) _buildFeatureCard(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rounded icon box with solid color
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),

          // Title & Badge
          Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: AppTheme.darkSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSlate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.badge,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            item.description,
            style: const TextStyle(
              color: AppTheme.slate700,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HOW IT WORKS SECTION (Matches Screenshots 5 & 6)
  // ---------------------------------------------------------------------------
  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'CARA KERJA',
              style: TextStyle(
                color: AppTheme.darkRed,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Mudah Digunakan oleh Siapa Saja',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkSurface,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Dirancang untuk staf gereja, sekretaris jemaat, bendahara, maupun majelis — tanpa perlu keahlian teknis khusus.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Step 1 (Photo 6)
          _buildStepItem(
            stepNumber: '01',
            title: 'Masuk ke Sistem',
            desc:
                'Login dengan akun yang diberikan oleh Admin Gereja. Tidak perlu instalasi — akses langsung dari browser.',
          ),

          // Step 2 (Photo 6)
          _buildStepItem(
            stepNumber: '02',
            title: 'Input Data Gereja',
            desc:
                'Masukkan data jemaat, catat transaksi keuangan, daftarkan aset gereja, dan susun jadwal pelayan ibadah.',
          ),

          // Step 3 (Photo 6)
          _buildStepItem(
            stepNumber: '03',
            title: 'Kelola & Pantau',
            desc:
                'Pantau semua aktivitas gereja melalui dashboard. Buat laporan dan export data kapan saja sesuai kebutuhan.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: 14,
                  top: -2,
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.surfaceSlate100,
                      height: 1.0,
                    ),
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryLight.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MISSION FOCUS CARD (Matches Screenshots 6 bottom, 7, 8 top)
  // ---------------------------------------------------------------------------
  Widget _buildMissionFocusSection(BuildContext context) {
    final benefits = [
      'Data jemaat terpusat dan selalu up-to-date',
      'Laporan keuangan transparan dan akuntabel',
      'Jadwal pelayanan tersusun rapi dan mudah dibagikan',
      'Tidak perlu keahlian IT khusus untuk mengoperasikan',
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.missionCardBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.missionCardBlue.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Digitalisasi Pelayanan,\nFokus pada Misi Gereja',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              'G-SERVE hadir agar energi pelayan gereja bisa difokuskan pada hal yang paling penting — penggembalaan jemaat dan pemberitaan Injil — bukan pada pekerjaan administratif yang menyita waktu.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // 4 Bullet Checkpoints
            Column(
              children: [
                for (final item in benefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.lightBlueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // White Logo Box (Centered)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.church,
                        color: AppTheme.primaryLight,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtext under logo
                  Text(
                    'GKPI JK Cimahi \u2022 Indonesia',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pelayanan Gereja Digital',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Red Button "Coba Sekarang ->"
                  ElevatedButton(
                    onPressed: _openLoginForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Coba Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TESTIMONIALS SECTION (Matches Screenshots 8 & 9)
  // ---------------------------------------------------------------------------
  Widget _buildTestimonialsSection(BuildContext context) {
    final testimonials = [
      const _TestimonialItem(
        stars: 5,
        quote:
            'G-SERVE sangat membantu dalam pengelolaan administrasi gereja. Data jemaat kini lebih tertata dan laporan keuangan mudah dibuat untuk Majelis.',
        initial: 'P',
        name: 'Pdt. Saut Nainggolan',
        role: 'Pendeta Jemaat GKPI Cimahi',
      ),
      const _TestimonialItem(
        stars: 5,
        quote:
            'Jadwal pelayan ibadah yang dulu dibuat manual di kertas sekarang tersusun rapi di sistem. Warta jemaat pun bisa langsung dicetak dari aplikasi.',
        initial: 'E',
        name: 'Ev. Tiur Simbolon',
        role: 'Sekretaris Jemaat',
      ),
      const _TestimonialItem(
        stars: 5,
        quote:
            'Pencatatan keuangan gereja kini jauh lebih transparan. Setiap transaksi tercatat rapi dan laporan bisa di-export kapan saja.',
        initial: 'B',
        name: 'Bapak Martua Sirait',
        role: 'Bendahara Gereja',
      ),
    ];

    return Container(
      width: double.infinity,
      color: AppTheme.surfaceSlate50,
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 48),
      child: Column(
        children: [
          const Text(
            'KATA MEREKA',
            style: TextStyle(
              color: AppTheme.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dipercaya Pelayan Gereja',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.darkSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 28),
          for (final item in testimonials) _buildTestimonialCard(item),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(_TestimonialItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5 Stars
          Row(
            children: List.generate(
              item.stars,
              (index) => const Icon(
                Icons.star_rounded,
                color: AppTheme.amber500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quote
          Text(
            '"${item.quote}"',
            style: const TextStyle(
              color: AppTheme.slate700,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),

          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  item.initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppTheme.darkSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.role,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CTA SECTION (Matches Screenshot 10)
  // ---------------------------------------------------------------------------
  Widget _buildBottomCtaSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.heroDarkerBlue,
      padding: const EdgeInsets.fromLTRB(22, 52, 22, 44),
      child: Column(
        children: [
          // Logo in white box
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.church,
                color: AppTheme.primaryLight,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Mulai Digitalisasi Gereja\nAnda Sekarang',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            'Bergabunglah dalam transformasi digital pelayanan GKPI. Kelola gereja Anda dengan lebih efisien, transparan, dan modern.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          // Primary Red Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openLoginForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Masuk ke G-SERVE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Outlined Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mengunduh panduan penggunaan G-SERVE...'),
                    backgroundColor: AppTheme.primaryLight,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                backgroundColor: AppTheme.textDark.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.download_rounded, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Unduh Panduan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3 Perks (Row 1: 2 items, Row 2: 1 item)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCtaCheckPill('Gratis untuk Jemaat GKPI'),
              const SizedBox(width: 16),
              _buildCtaCheckPill('Tanpa instalasi'),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: _buildCtaCheckPill('Support tersedia'),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaCheckPill(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF2DD4BF),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.slate200,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        const SizedBox(height: 8),
        InkWell(
          onTap: () => showServerConfigDialog(context, onConfigSaved: _checkBackendStatus),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _backendOnline ? AppTheme.green50 : AppTheme.amber50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _backendOnline ? AppTheme.green300 : AppTheme.amber200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _backendOnline ? AppTheme.successGreen : AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _backendOnline ? 'Backend Terhubung (API Live)' : 'Demo Mode (Offline Fallback)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _backendOnline ? AppTheme.green700 : AppTheme.amber700,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.edit_outlined,
                  size: 11,
                  color: _backendOnline ? AppTheme.green700 : AppTheme.amber700,
                ),
              ],
            ),
          ),
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
                    color: AppTheme.badgeBlueBg,
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
                  onTap: _isConnecting ? () {} : () => _handleLogin(),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isConnecting ? null : () => _handleLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isConnecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login, size: 18),
                      label: Text(
                        _isConnecting ? 'Menghubungkan ke Server...' : 'Masuk ke Sistem',
                        style: const TextStyle(
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
                color: AppTheme.featureGreen,
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
                color: AppTheme.warningAmber,
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
            color: AppTheme.textDark, // Dark slate navy
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
                  color: AppTheme.textGrey,
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
                targetRole: UserRole.multimedia,
              ),
              _buildDemoAccountRow(
                username: 'pemusik',
                password: 'op123',
                roleLabel: 'Operator Pemusik',
                targetRole: UserRole.pemusik,
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Divider(color: AppTheme.slate700, height: 1),
              ),
              const Text(
                '# uji validasi status jemaat',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _buildDemoAccountRow(
                username: 'jemaat-pindah',
                password: 'op123',
                roleLabel: 'Status Pindah (Ditolak)',
                targetRole: UserRole.jemaat,
              ),
              _buildDemoAccountRow(
                username: 'jemaat-wafat',
                password: 'op123',
                roleLabel: 'Status Meninggal (Ditolak)',
                targetRole: UserRole.jemaat,
              ),
              _buildDemoAccountRow(
                username: 'jemaat-nonaktif',
                password: 'op123',
                roleLabel: 'Status Nonaktif (Ditolak)',
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
            Flexible(
              child: Text(
                username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  color: AppTheme.green300,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' / $password ',
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
                  color: AppTheme.slate300,
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
  // FOOTER (Matches Photo 2)
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: AppTheme.heroDarkerBlue,
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title (Photo 2)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.church,
                    color: AppTheme.primaryLight,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'G-SERVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'GKPI JK Cimahi',
                    style: TextStyle(
                      color: AppTheme.slate300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Tagline / Description (Photo 2)
          const Text(
            'GKPI Smart & Effective Resources for Village and Ecclesia \u2014 Platform digital untuk pelayanan gereja yang lebih baik.',
            style: TextStyle(
              color: AppTheme.slate300,
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),

          // "Menu" Heading & Links (Photo 2)
          const Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildFooterLink('Dashboard', _openLoginForm),
          _buildFooterLink('Data Jemaat', _openLoginForm),
          _buildFooterLink('Keuangan', _openLoginForm),
          _buildFooterLink('Inventaris', _openLoginForm),
          _buildFooterLink('Warta & Jadwal', _openLoginForm),

          const SizedBox(height: 20),

          // "Kontak" Heading & Items (Photo 2)
          const Text(
            'Kontak',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFooterContactItem(
            icon: Icons.location_on_outlined,
            text: 'Jl. Ibu Sangki No.1, Cimahi, Jawa Barat',
          ),
          _buildFooterContactItem(
            icon: Icons.phone_outlined,
            text: '+62 22 6644 xxx',
          ),
          _buildFooterContactItem(
            icon: Icons.mail_outline_rounded,
            text: 'gkpi.cimahi@gmail.com',
          ),
          _buildFooterContactItem(
            icon: Icons.language_rounded,
            text: 'gkpi-cimahi.org',
          ),

          const SizedBox(height: 28),

          // Subtle Divider (Photo 2)
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
          const SizedBox(height: 22),

          // Copyright Line (Photo 2)
          const Center(
            child: Text(
              '\u00a9 2025 G-SERVE \u2014 GKPI Jemaat Cimahi. Hak Cipta Dilindungi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Data Aman & Terlindungi Badge (Photo 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.shield_outlined,
                color: AppTheme.successGreen,
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Data aman & terlindungi',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.slate300,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterContactItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.badgeRedText,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.slate300,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.description,
  });
}

class _TestimonialItem {
  final int stars;
  final String quote;
  final String initial;
  final String name;
  final String role;

  const _TestimonialItem({
    required this.stars,
    required this.quote,
    required this.initial,
    required this.name,
    required this.role,
  });
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.overlayDark.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
