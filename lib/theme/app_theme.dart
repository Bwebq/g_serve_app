import 'package:flutter/material.dart';
import '../utils/animations.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0F3A7A);
  static const Color secondaryBlue = Color(0xFF15488F);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color buttonRed = Color(0xFFDC2626);
  static const Color backgroundGrey = Color(0xFFF3F6FA);
  static const Color heroDarkBlue = Color(0xFF0A2246);
  static const Color heroBlue = Color(0xFF0F3A7A);
  static const Color heroAccentBlue = Color(0xFF1A52A5);
  static const Color landingBg = Color(0xFFF3F7FA);
  static const Color lightBlueCard = Color(0xFFEDF4FF);
  static const Color textDarkBlue = Color(0xFF0F3A7A);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color badgeRedBg = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFEF4444);
  static const Color badgeBlueBg = Color(0xFFE0F2FE);
  static const Color badgeBlueText = Color(0xFF0284C7);

  static PageTransitionsTheme get _transitions => const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _SmoothFadeSlidePageTransition(),
      TargetPlatform.iOS: _SmoothFadeSlidePageTransition(),
      TargetPlatform.windows: _SmoothFadeSlidePageTransition(),
      TargetPlatform.macOS: _SmoothFadeSlidePageTransition(),
      TargetPlatform.linux: _SmoothFadeSlidePageTransition(),
    },
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGrey,
      pageTransitionsTheme: _transitions,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        error: accentRed,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentRed, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStatePropertyAll(
            primaryBlue.withValues(alpha: 0.08),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          animationDuration: AppMotion.fast,
          enableFeedback: true,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: borderGrey)),
          overlayColor: WidgetStatePropertyAll(
            primaryBlue.withValues(alpha: 0.06),
          ),
          animationDuration: AppMotion.fast,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          overlayColor: WidgetStatePropertyAll(
            primaryBlue.withValues(alpha: 0.06),
          ),
          animationDuration: AppMotion.fast,
        ),
      ),
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(fontSize: 14, color: textDark),
        bodyMedium: TextStyle(fontSize: 12, color: textGrey),
      ),
    );
  }
}

class _SmoothFadeSlidePageTransition extends PageTransitionsBuilder {
  const _SmoothFadeSlidePageTransition();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.curveGentle,
    );
    final secCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.curveIn,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.96).animate(secCurved),
          child: child,
        ),
      ),
    );
  }
}
