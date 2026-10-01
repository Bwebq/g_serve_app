import 'package:flutter/material.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'utils/animations.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/bendahara_screen.dart';
import 'screens/sekretaris_screen.dart';
import 'screens/diaken_screen.dart';
import 'screens/multimedia_screen.dart';
import 'screens/pemusik_screen.dart';
import 'services/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G-SERVE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootWrapper(),
    );
  }
}

class RootWrapper extends StatefulWidget {
  const RootWrapper({super.key});

  @override
  State<RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends State<RootWrapper> {
  bool _showSplash = true;
  bool _isLoggedIn = false;
  UserRole _currentRole = UserRole.jemaat;

  void _finishSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  void _login(UserRole role) {
    setState(() {
      _currentRole = role;
      _isLoggedIn = true;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget targetScreen;
    if (_showSplash) {
      targetScreen = SplashScreen(
        key: const ValueKey('splash'),
        onFinish: _finishSplash,
      );
    } else if (!_isLoggedIn) {
      targetScreen = LandingScreen(
        key: const ValueKey('landing'),
        onLoginSuccess: _login,
      );
    } else if (_currentRole == UserRole.bendahara) {
      targetScreen = BendaharaScreen(
        key: const ValueKey('UserRole.bendahara'),
        onLogout: _logout,
      );
    } else if (_currentRole == UserRole.sekretaris) {
      targetScreen = SekretarisScreen(
        key: const ValueKey('UserRole.sekretaris'),
        onLogout: _logout,
      );
    } else if (_currentRole == UserRole.diaken) {
      targetScreen = DiakenScreen(
        key: const ValueKey('UserRole.diaken'),
        onLogout: _logout,
      );
    } else if (_currentRole == UserRole.multimedia) {
      targetScreen = MultimediaScreen(
        key: const ValueKey('UserRole.multimedia'),
        onLogout: _logout,
      );
    } else if (_currentRole == UserRole.pemusik) {
      targetScreen = PemusikScreen(
        key: const ValueKey('UserRole.pemusik'),
        onLogout: _logout,
      );
    } else {
      targetScreen = MainNavigationScreen(
        key: const ValueKey('UserRole.jemaat'),
        onLogout: _logout,
      );
    }

    return AnimatedSwitcherSlide(child: targetScreen);
  }
}
