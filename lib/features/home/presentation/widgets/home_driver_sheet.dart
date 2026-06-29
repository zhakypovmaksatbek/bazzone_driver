import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:flutter/material.dart';

typedef HomeSheetSizes = ({double minChildSize, double maxChildSize});

class HomeDriverSheet extends StatefulWidget {
  const HomeDriverSheet({
    super.key,
    required this.controller,
    required this.phase,
    this.stateKey,
    required this.initialChildSize,
    required this.child,
    required this.measureCollapsed,
    required this.measureExpanded,
    this.onSizeChanged,
    this.onSizesResolved,
  });

  final DraggableScrollableController controller;
  final HomeSheetPhase phase;
  final Object? stateKey;
  final double initialChildSize;
  final Widget child;
  final Widget measureCollapsed;
  final Widget measureExpanded;
  final ValueChanged<double>? onSizeChanged;
  final ValueChanged<HomeSheetSizes>? onSizesResolved;

  static const maxSize = 0.92;
  static const measurementSlop = 12.0;
  static const fallbackCollapsedHeight = 120.0;
  static const fallbackExpandedHeight = 320.0;
  static const collapsedThresholdDelta = 0.02;

  static bool isCollapsedExtent(double extent, double minChildSize) {
    return extent <= minChildSize + collapsedThresholdDelta;
  }

  static bool isSingleSizePhase(HomeSheetPhase phase) {
    return phase == HomeSheetPhase.driverSummary;
  }

  static double contentFitFraction(
    BuildContext context,
    double contentHeight,
  ) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return ((contentHeight + _SheetDragZone.totalHeight + measurementSlop) /
            screenHeight)
        .clamp(0.0, maxSize);
  }

  static double targetSizeFor(
    HomeSheetPhase phase,
    BuildContext context, {
    double? expandedContentHeight,
  }) {
    return contentFitFraction(
      context,
      expandedContentHeight ?? fallbackExpandedHeight,
    );
  }

  static List<double> snapSizesFor({
    required HomeSheetPhase phase,
    required double minChildSize,
    required double maxChildSize,
  }) {
    if (isSingleSizePhase(phase) ||
        (maxChildSize - minChildSize).abs() < 0.01) {
      return [maxChildSize];
    }
    return [minChildSize, maxChildSize];
  }

  @override
  State<HomeDriverSheet> createState() => _HomeDriverSheetState();
}

class _HomeDriverSheetState extends State<HomeDriverSheet> {
  final _SheetSizesNotifier _sizes = _SheetSizesNotifier();
  HomeSheetPhase? _lockedPhase;
  double? _lockedMin;
  double? _lockedMax;
  HomeSheetSizes? _lastReportedSizes;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(HomeDriverSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase || oldWidget.stateKey != widget.stateKey) {
      _lockedPhase = null;
      _lockedMin = null;
      _lockedMax = null;
      _lastReportedSizes = null;
      _sizes.reset();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _sizes.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!widget.controller.isAttached) return;
    widget.onSizeChanged?.call(widget.controller.size);
  }

  void _tryLockSizes(BuildContext context) {
    if (_lockedPhase == widget.phase && _lockedMin != null && _lockedMax != null) {
      return;
    }
    if (!_sizes.isReadyFor(widget.phase)) return;

    final minChildSize = HomeDriverSheet.isSingleSizePhase(widget.phase)
        ? HomeDriverSheet.contentFitFraction(
            context,
            _sizes.expandedHeight,
          )
        : HomeDriverSheet.contentFitFraction(
            context,
            _sizes.collapsedHeight,
          );
    final maxChildSize = HomeDriverSheet.contentFitFraction(
      context,
      _sizes.expandedHeight,
    );
    final resolvedMin = HomeDriverSheet.isSingleSizePhase(widget.phase)
        ? maxChildSize
        : minChildSize.clamp(0.0, maxChildSize);

    _lockedPhase = widget.phase;
    _lockedMin = resolvedMin;
    _lockedMax = maxChildSize;

    final next = (minChildSize: resolvedMin, maxChildSize: maxChildSize);
    if (_lastReportedSizes == null ||
        (_lastReportedSizes!.minChildSize - next.minChildSize).abs() > 0.001 ||
        (_lastReportedSizes!.maxChildSize - next.maxChildSize).abs() > 0.001) {
      _lastReportedSizes = next;
      widget.onSizesResolved?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (_lockedPhase != widget.phase)
              Positioned(
                top: -8000,
                left: 0,
                width: constraints.maxWidth,
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!HomeDriverSheet.isSingleSizePhase(widget.phase))
                        _MeasureSize(
                          onHeight: _sizes.updateCollapsed,
                          child: widget.measureCollapsed,
                        ),
                      _MeasureSize(
                        onHeight: _sizes.updateExpanded,
                        child: widget.measureExpanded,
                      ),
                    ],
                  ),
                ),
              ),
            Builder(
              builder: (context) {
                if (_lockedPhase != widget.phase) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _tryLockSizes(context);
                  });
                }

                final minChildSize = _lockedMin ??
                    HomeDriverSheet.contentFitFraction(
                      context,
                      HomeDriverSheet.fallbackCollapsedHeight,
                    );
                final maxChildSize = _lockedMax ??
                    HomeDriverSheet.contentFitFraction(
                      context,
                      HomeDriverSheet.fallbackExpandedHeight,
                    );
                final snapSizes = HomeDriverSheet.snapSizesFor(
                  phase: widget.phase,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                );
                final initialSize =
                    widget.initialChildSize.clamp(minChildSize, maxChildSize);

                return DraggableScrollableSheet(
                  controller: widget.controller,
                  initialChildSize: initialSize,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                  snap: snapSizes.length > 1,
                  snapSizes: snapSizes,
                  builder: (context, scrollController) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorConst.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorConst.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const _SheetScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: _SheetDragZone()),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.paddingOf(context).bottom,
                              ),
                              child: widget.child,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SheetDragZone extends StatelessWidget {
  const _SheetDragZone();

  static const totalHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resize sheet',
      container: true,
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConst.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetScrollPhysics extends ClampingScrollPhysics {
  const _SheetScrollPhysics({super.parent});

  @override
  _SheetScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SheetScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}

class _SheetSizesNotifier extends ChangeNotifier {
  double collapsedHeight = 0;
  double expandedHeight = 0;

  bool isReadyFor(HomeSheetPhase phase) {
    if (expandedHeight <= 0) return false;
    if (HomeDriverSheet.isSingleSizePhase(phase)) return true;
    return collapsedHeight > 0;
  }

  void reset() {
    collapsedHeight = 0;
    expandedHeight = 0;
    notifyListeners();
  }

  void updateCollapsed(double height) {
    if (height <= 0 || (height - collapsedHeight).abs() < 1) return;
    collapsedHeight = height;
    notifyListeners();
  }

  void updateExpanded(double height) {
    if (height <= 0 || (height - expandedHeight).abs() < 1) return;
    expandedHeight = height;
    notifyListeners();
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({
    required this.onHeight,
    required this.child,
  });

  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(_MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  void _reportSize() {
    final context = _key.currentContext;
    if (context == null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    widget.onHeight(renderBox.size.height);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
