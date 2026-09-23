import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppMotion {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const page = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 520);
  static const slower = Duration(milliseconds: 700);
  static const stagger = Duration(milliseconds: 70);
  static const pressScale = 0.97;
  static const hoverScale = 1.02;

  static const curve = Curves.easeOutCubic;
  static const curveEmphasized = Curves.easeOutQuart;
  static const curveSpring = Curves.easeOutBack;
  static const curveGentle = Curves.easeOutExpo;
  static const curveIn = Curves.easeInCubic;
  static const curveInOut = Curves.easeInOutCubic;
  static const curveSharp = Curves.easeInOutQuart;

  static const cubicStandard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const cubicDecelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  static const cubicAccelerate = Cubic(0.4, 0.0, 1.0, 1.0);
  static const cubicSpring = Cubic(0.34, 1.56, 0.64, 1.0);
}

class FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideBegin;
  final Curve curve;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.slideBegin = const Offset(0, 0.08),
    this.curve = AppMotion.curveGentle,
  });

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: AppMotion.curveGentle);
    _slide = Tween<Offset>(
      begin: widget.slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class StaggeredColumn extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredColumn({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = AppMotion.stagger,
    this.itemDuration = AppMotion.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return FadeSlideAnimation(
          delay: staggerDelay * index,
          duration: itemDuration,
          slideBegin: const Offset(0, 0.06),
          curve: AppMotion.curveGentle,
          child: itemBuilder(context, index),
        );
      }),
    );
  }
}

class StaggeredList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration staggerDelay;
  final Duration itemDuration;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = AppMotion.stagger,
    this.itemDuration = AppMotion.medium,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) => FadeSlideAnimation(
        delay: staggerDelay * index,
        duration: itemDuration,
        slideBegin: const Offset(0, 0.06),
        curve: AppMotion.curveGentle,
        child: itemBuilder(context, index),
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final Curve curve;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2800),
    this.minScale = 0.98,
    this.maxScale = 1.02,
    this.curve = AppMotion.curveInOut,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final double tapScale;
  final double hoverScale;
  final Duration duration;
  final bool enableHaptic;
  final VoidCallback? onTap;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.tapScale = AppMotion.pressScale,
    this.hoverScale = AppMotion.hoverScale,
    this.duration = AppMotion.fast,
    this.enableHaptic = false,
    this.onTap,
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool v) => setState(() => _pressed = v);
  void _setHovered(bool v) => setState(() => _hovered = v);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? widget.tapScale
        : (_hovered ? widget.hoverScale : 1.0);
    final opacity = _pressed ? 0.94 : 1.0;

    Widget content = AnimatedScale(
      scale: scale,
      duration: widget.duration,
      curve: AppMotion.curveGentle,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: widget.duration,
        curve: AppMotion.curveGentle,
        child: widget.child,
      ),
    );
    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTapDown: (_) {
            _setPressed(true);
            if (widget.enableHaptic) HapticFeedback.lightImpact();
          },
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: content,
        ),
      );
    }
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: content,
      ),
    );
  }
}

class BouncyPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const BouncyPress({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });
  @override
  State<BouncyPress> createState() => _BouncyPressState();
}

class _BouncyPressState extends State<BouncyPress> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.curveSpring,
        child: AnimatedOpacity(
          opacity: _down ? 0.94 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.curveGentle,
          child: widget.child,
        ),
      ),
    );
  }
}

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool shake;
  final VoidCallback? onFinish;
  final Duration duration;
  final double intensity;
  const ShakeAnimation({
    super.key,
    required this.child,
    this.shake = false,
    this.onFinish,
    this.duration = const Duration(milliseconds: 480),
    this.intensity = 8,
  });
  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _a = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _c.forward(from: 0).whenComplete(() => widget.onFinish?.call());
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) {
        final t = _a.value;
        final dx =
            (t < 0.2
                ? t * 5
                : t < 0.4
                ? 1 - (t - 0.2) * 5
                : t < 0.6
                ? -(t - 0.4) * 5
                : t < 0.8
                ? (t - 0.6) * 5
                : -(1 - (t - 0.8) * 5)) *
            widget.intensity;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

class AnimatedInput extends StatefulWidget {
  final Widget child;
  final bool hasFocus;
  final bool hasError;
  const AnimatedInput({
    super.key,
    required this.child,
    this.hasFocus = false,
    this.hasError = false,
  });
  @override
  State<AnimatedInput> createState() => _AnimatedInputState();
}

class _AnimatedInputState extends State<AnimatedInput> {
  bool _shake = false;
  @override
  void didUpdateWidget(covariant AnimatedInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) setState(() => _shake = true);
  }

  @override
  Widget build(BuildContext context) {
    return ShakeAnimation(
      shake: _shake,
      onFinish: () => setState(() => _shake = false),
      duration: const Duration(milliseconds: 400),
      intensity: 6,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curveGentle,
        decoration: BoxDecoration(
          boxShadow: widget.hasFocus
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F3A7A).withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: AnimatedScale(
          scale: widget.hasFocus ? 1.005 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.curveGentle,
          child: widget.child,
        ),
      ),
    );
  }
}

class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;
  final Curve curve;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slower,
    this.beginScale = 0.88,
    this.curve = AppMotion.curveSpring,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration duration;
  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1800),
  });
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => ShaderMask(
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment(-1.2 + _c.value * 2.4, 0),
          end: Alignment(1.2 + _c.value * 2.4, 0),
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.6),
            Colors.white,
            Colors.white.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.3),
          ],
          stops: const [0.1, 0.35, 0.5, 0.65, 0.9],
        ).createShader(rect),
        blendMode: BlendMode.srcATop,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class ProfessionalLogo extends StatelessWidget {
  final double size;
  final double padding;
  final double borderRadius;
  final bool usePulse;

  const ProfessionalLogo({
    super.key,
    this.size = 42,
    this.padding = 4.0,
    this.borderRadius = 10,
    this.usePulse = false,
  });

  Widget _buildLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.church,
            color: const Color(0xFF0F3A7A),
            size: size * 0.55,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (usePulse) {
      return PulseAnimation(
        minScale: 0.97,
        maxScale: 1.03,
        duration: const Duration(milliseconds: 3000),
        child: _buildLogo(),
      );
    }
    return _buildLogo();
  }
}

class AppPageTransitions {
  static Widget fadeSlide(
    BuildContext context,
    Animation<double> anim,
    Animation<double> sec,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: anim, curve: AppMotion.curveGentle);
    final secCurved = CurvedAnimation(parent: sec, curve: AppMotion.curveIn);
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

  static Widget scaleFade(
    BuildContext context,
    Animation<double> anim,
    Animation<double> sec,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: AppMotion.curveGentle),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.98,
          end: 1,
        ).animate(CurvedAnimation(parent: anim, curve: AppMotion.curveGentle)),
        child: child,
      ),
    );
  }

  static Route<T> build<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: name != null ? RouteSettings(name: name) : null,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, anim, sec) => page,
      transitionsBuilder: fadeSlide,
    );
  }
}

class AnimatedSwitcherSlide extends StatelessWidget {
  final Widget child;
  const AnimatedSwitcherSlide({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.page,
      switchInCurve: AppMotion.curveGentle,
      switchOutCurve: AppMotion.curveIn,
      transitionBuilder: (c, a) => FadeTransition(
        opacity: CurvedAnimation(
          parent: a,
          curve: const Interval(0.15, 1, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: AppMotion.curveGentle)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}
