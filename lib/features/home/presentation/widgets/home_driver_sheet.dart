import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class HomeSheetConfig {
  final double minSize;
  final double maxSize;
  final double initialSize;

  const HomeSheetConfig({
    required this.minSize,
    required this.maxSize,
    required this.initialSize,
  });

  List<double> get snapSizes => [minSize, maxSize];
}

// ─────────────────────────────────────────────────────────
// HomeSheetController
// ─────────────────────────────────────────────────────────

/// ChangeNotifier kullanmıyor.
/// Dışarıya [sizeListenable] (`ValueListenable<double>`) expose eder.
/// home_page.dart `ValueListenableBuilder` ile dinler →
/// _HomeView hiç setState yapmaz, sadece ilgili widget'lar rebuild olur.
class HomeSheetController {
  HomeSheetController() : _sizeNotifier = ValueNotifier(0.0);

  final ValueNotifier<double> _sizeNotifier;

  /// Overlay butonlar ve isExpanded hesabı için dışarıdan dinlenir.
  ValueListenable<double> get sizeListenable => _sizeNotifier;

  _HomeDriverSheetState? _state;

  double get size => _sizeNotifier.value;
  bool get isAttached => _state != null;

  void _attach(_HomeDriverSheetState state) => _state = state;
  void _detach() => _state = null;

  /// Sheet boyutunu günceller. ValueNotifier olduğu için build fazındaki
  /// descendant ValueListenableBuilder'ları güvenle tetikler (ancestor setState yok).
  void _pushSize(double size) => _sizeNotifier.value = size;

  Future<void> animateTo(
    double size, {
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOut,
  }) =>
      _state?.animateTo(size, duration: duration, curve: curve) ??
      Future.value();

  void dispose() => _sizeNotifier.dispose();
}

// ─────────────────────────────────────────────────────────
// HomeDriverSheet
// ─────────────────────────────────────────────────────────

class HomeDriverSheet extends StatefulWidget {
  const HomeDriverSheet({
    super.key,
    required this.controller,
    required this.phase,
    this.activePhase,
    required this.child,
  });

  final HomeSheetController controller;
  final HomeSheetPhase phase;
  final ActiveOrderPhase? activePhase;
  final Widget child;

  static HomeSheetConfig getConfig(
    HomeSheetPhase phase,
    ActiveOrderPhase? activePhase,
  ) {
    switch (phase) {
      case HomeSheetPhase.driverSummary:
        return const HomeSheetConfig(
          minSize: 0.22,
          maxSize: 0.22,
          initialSize: 0.22,
        );
      case HomeSheetPhase.orderOffer:
        return const HomeSheetConfig(
          minSize: 0.1,
          maxSize: 0.43,
          initialSize: 0.43,
        );
      case HomeSheetPhase.activeOrder:
        switch (activePhase) {
          case ActiveOrderPhase.headingToClient:
            return const HomeSheetConfig(
              minSize: 0.1,
              maxSize: 0.40,
              initialSize: 0.40,
            );
          case ActiveOrderPhase.waitingForClient:
            return const HomeSheetConfig(
              minSize: 0.1,
              maxSize: 0.48,
              initialSize: 0.48,
            );
          case ActiveOrderPhase.headingToDestination:
            return const HomeSheetConfig(
              minSize: 0.13,
              maxSize: 0.45,
              initialSize: 0.45,
            );
          case ActiveOrderPhase.completed:
          default:
            return const HomeSheetConfig(
              minSize: 0.20,
              maxSize: 0.85,
              initialSize: 0.85,
            );
        }
    }
  }

  @override
  State<HomeDriverSheet> createState() => _HomeDriverSheetState();
}

class _HomeDriverSheetState extends State<HomeDriverSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  /// setState YOK. ValueNotifier güncellenir →
  /// yalnızca ValueListenableBuilder rebuild olur.
  late final ValueNotifier<double> _sizeNotifier;

  HomeSheetConfig get _config =>
      HomeDriverSheet.getConfig(widget.phase, widget.activePhase);

  double get _size => _sizeNotifier.value;

  // ── Lifecycle ───────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _sizeNotifier = ValueNotifier(_config.initialSize);
    _anim = AnimationController.unbounded(vsync: this)
      ..addListener(_onAnimTick);
    widget.controller._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller._pushSize(_size);
      }
    });
  }

  @override
  void didUpdateWidget(HomeDriverSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach();
      widget.controller._attach(this);
    }
    if (oldWidget.phase != widget.phase ||
        oldWidget.activePhase != widget.activePhase) {
      final clamped = _size.clamp(_config.minSize, _config.maxSize);
      if (clamped != _size) {
        _sizeNotifier.value = clamped; // setState yok
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.controller._pushSize(clamped);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    widget.controller._detach();
    _anim
      ..removeListener(_onAnimTick)
      ..dispose();
    _sizeNotifier.dispose();
    super.dispose();
  }

  // ── Animation ───────────────────────────────────────────

  void _onAnimTick() {
    final clamped = _anim.value.clamp(_config.minSize, _config.maxSize);
    if ((clamped - _size).abs() < 0.00005) return;
    _sizeNotifier.value = clamped;
    widget.controller._pushSize(clamped);
  }

  Future<void> animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOut,
  }) async {
    final clamped = target.clamp(_config.minSize, _config.maxSize);
    _anim.value = _size;
    await _anim.animateTo(clamped, duration: duration, curve: curve);
  }

  // ── Drag callbacks (called by _SheetSurface) ────────────

  void onSheetDragStart() => _anim.stop(canceled: true);

  void onSheetDragUpdate(double dy) {
    final screenH = MediaQuery.of(context).size.height;
    final delta = -dy / screenH;
    final next = (_size + delta).clamp(_config.minSize, _config.maxSize);
    if ((next - _size).abs() < 0.00005) return;
    _sizeNotifier.value = next;
    widget.controller._pushSize(next);
  }

  void onSheetDragEnd(double velocityPx) {
    final screenH = MediaQuery.of(context).size.height;
    final velocity = -velocityPx / screenH;
    final target = _snapTarget(velocity);
    _anim.value = _size;
    _anim.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1.0, stiffness: 600.0, damping: 38.0),
        _size,
        target,
        velocity,
      ),
    );
  }

  double _snapTarget(double velocity) {
    const kVelocityThreshold = 1.2;
    if (velocity > kVelocityThreshold) return _config.maxSize;
    if (velocity < -kVelocityThreshold) return _config.minSize;
    final mid = (_config.minSize + _config.maxSize) / 2.0;
    return _size >= mid ? _config.maxSize : _config.minSize;
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        // Bu builder yalnızca boyut değişince çalışır.
        final screenH = MediaQuery.of(context).size.height;
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            height: size * screenH,
            child: child, // _SheetSurface hiç rebuild olmaz
          ),
        );
      },
      // child: build edilir, builder'a geçirilir, boyut değişiminde rebuild'e katılmaz.
      child: _SheetSurface(
        sizeNotifier: _sizeNotifier,
        config: _config,
        onSheetDragStart: onSheetDragStart,
        onSheetDragUpdate: onSheetDragUpdate,
        onSheetDragEnd: onSheetDragEnd,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// _SheetSurface
// ─────────────────────────────────────────────────────────

enum _DragMode { undecided, sheet, scroll }

class _SheetSurface extends StatefulWidget {
  const _SheetSurface({
    required this.sizeNotifier,
    required this.config,
    required this.onSheetDragStart,
    required this.onSheetDragUpdate,
    required this.onSheetDragEnd,
    required this.child,
  });

  final ValueNotifier<double> sizeNotifier;
  final HomeSheetConfig config;
  final VoidCallback onSheetDragStart;
  final ValueChanged<double> onSheetDragUpdate;
  final ValueChanged<double> onSheetDragEnd;
  final Widget child;

  @override
  State<_SheetSurface> createState() => _SheetSurfaceState();
}

class _SheetSurfaceState extends State<_SheetSurface> {
  final ScrollController _scroll = ScrollController();
  _DragMode _mode = _DragMode.undecided;

  static const double _kDecisionThreshold = 6.0;
  double _accumulated = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double get _scrollOffset => _scroll.hasClients ? _scroll.offset : 0;
  double get _scrollMax =>
      _scroll.hasClients ? _scroll.position.maxScrollExtent : 0;

  /// Rebuild yok — ValueNotifier'dan doğrudan okunur.
  bool get _isAtMax =>
      (widget.sizeNotifier.value - widget.config.maxSize).abs() < 0.01;

  // ── Gesture ─────────────────────────────────────────────

  void _onDragStart(DragStartDetails _) {
    _mode = _DragMode.undecided;
    _accumulated = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final dy = details.primaryDelta ?? 0;
    _accumulated += dy;

    if (_mode == _DragMode.undecided) {
      if (_accumulated.abs() < _kDecisionThreshold) return;

      final isDraggingDown = _accumulated > 0;

      if (!_isAtMax) {
        _mode = _DragMode.sheet;
        widget.onSheetDragStart();
      } else if (isDraggingDown && _scrollOffset <= 0) {
        _mode = _DragMode.sheet;
        widget.onSheetDragStart();
      } else {
        _mode = _DragMode.scroll;
      }
    }

    switch (_mode) {
      case _DragMode.sheet:
        widget.onSheetDragUpdate(dy);
      case _DragMode.scroll:
        if (_scroll.hasClients) {
          _scroll.jumpTo((_scrollOffset - dy).clamp(0.0, _scrollMax));
        }
      case _DragMode.undecided:
        break;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    switch (_mode) {
      case _DragMode.sheet:
        widget.onSheetDragEnd(velocity);
      case _DragMode.scroll:
        if (_scroll.hasClients) {
          _scroll.animateTo(
            (_scrollOffset - velocity * 0.25).clamp(0.0, _scrollMax),
            duration: const Duration(milliseconds: 350),
            curve: Curves.decelerate,
          );
        }
      case _DragMode.undecided:
        break;
    }

    _mode = _DragMode.undecided;
    _accumulated = 0;
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: ColorConst.black.withValues(alpha: 0.12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Column(
          children: [
            const _DragHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 16,
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// _DragHandle
// ─────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resize sheet',
      container: true,
      child: SizedBox(
        height: 36,
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorConst.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
