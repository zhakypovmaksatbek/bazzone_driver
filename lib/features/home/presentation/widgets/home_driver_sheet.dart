import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Sürücü ana ekranındaki sürüklenebilir alt panel.
///
/// Boyutlandırma mantığı [phase] ve aktif siparişin [activeOrderPhase]'ine
/// göre değişir, böylece her ekran (özet / teklif / aktif sipariş) kendi
/// içeriğine uygun bir yükseklikte açılır.
class HomeDriverSheet extends StatelessWidget {
  const HomeDriverSheet({
    super.key,
    required this.controller,
    required this.phase,
    required this.initialChildSize,
    required this.isCollapsed,
    required this.child,
    this.activeOrderPhase,
    this.onCollapse,
    this.onExpand,
  });

  final DraggableScrollableController controller;
  final HomeSheetPhase phase;
  final ActiveOrderPhase? activeOrderPhase;
  final double initialChildSize;
  final bool isCollapsed;
  final Widget child;
  final VoidCallback? onCollapse;
  final VoidCallback? onExpand;

  static const minSize = 0.15;
  static const maxSize = 0.85;
  static const orderMidSize = 0.5;
  static const driverContentHeight = 210.0;
  static const navContentHeight = 260.0;
  static const collapsedThreshold = minSize + 0.04;

  static bool isCollapsedExtent(double extent) => extent <= collapsedThreshold;

  static bool isNavPhase(ActiveOrderPhase? activeOrderPhase) =>
      activeOrderPhase == ActiveOrderPhase.headingToClient ||
      activeOrderPhase == ActiveOrderPhase.headingToDestination;

  static double _heightRatio(double height, BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return (height / screenHeight).clamp(minSize, maxSize);
  }

  static double driverInitialSize(BuildContext context) =>
      _heightRatio(driverContentHeight, context);

  static double navInitialSize(BuildContext context) =>
      _heightRatio(navContentHeight, context);

  static double targetSizeFor(
    HomeSheetPhase phase,
    BuildContext context, {
    ActiveOrderPhase? activeOrderPhase,
  }) {
    return switch (phase) {
      HomeSheetPhase.driverSummary => driverInitialSize(context),
      HomeSheetPhase.orderOffer => orderMidSize,
      HomeSheetPhase.activeOrder => isNavPhase(activeOrderPhase)
          ? navInitialSize(context)
          : orderMidSize,
    };
  }

  static List<double> snapSizesFor(
    HomeSheetPhase phase,
    BuildContext context, {
    ActiveOrderPhase? activeOrderPhase,
  }) {
    return switch (phase) {
      HomeSheetPhase.driverSummary => [minSize, driverInitialSize(context)],
      HomeSheetPhase.orderOffer => [minSize, orderMidSize, maxSize],
      HomeSheetPhase.activeOrder => isNavPhase(activeOrderPhase)
          ? [minSize, navInitialSize(context), maxSize]
          : [minSize, orderMidSize, maxSize],
    };
  }

  static double maxSizeFor(HomeSheetPhase phase, BuildContext context) {
    return switch (phase) {
      HomeSheetPhase.driverSummary => driverInitialSize(context),
      HomeSheetPhase.orderOffer || HomeSheetPhase.activeOrder => maxSize,
    };
  }

  @override
  Widget build(BuildContext context) {
    final snapSizes = snapSizesFor(
      phase,
      context,
      activeOrderPhase: activeOrderPhase,
    );
    final maxChildSize = maxSizeFor(phase, context);
    // Sürücü her zaman, tek dokunuşla haritaya odaklanabilmek için paneli
    // küçültüp büyütebilmeli — bu yüzden kontrol her fazda görünür.
    final showCollapseButton = !isCollapsed;
    final showExpandButton = isCollapsed;

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialChildSize.clamp(minSize, maxChildSize),
      minChildSize: minSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: ColorConst.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: ColorConst.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _ResizableSheetBody(
            controller: controller,
            snapSizes: snapSizes,
            minSize: minSize,
            maxSize: maxChildSize,
            showCollapseButton: showCollapseButton,
            showExpandButton: showExpandButton,
            onCollapse: onCollapse,
            onExpand: onExpand,
            child: child,
          ),
        );
      },
    );
  }
}

/// Panelin tamamı (başlık + içerik) için tek elden boyutlandırma/kaydırma.
///
/// [DraggableScrollableSheet]'in varsayılan davranışı, boyutlandırmayı
/// içerideki [ScrollController] üzerinden yönetir: kaydırılabilir içerik en
/// üstte (offset 0) değilse aşağı sürükleme paneli küçültmek yerine içeriği
/// kaydırır. Bu da yalnızca panelin en üstünden (tutamaçtan) sürüklemenin
/// güvenilir çalışması, panelin herhangi bir yerinden sürüklemenin ise
/// tutarsız olması gibi görünür.
///
/// Burada tek bir [GestureDetector] panelin tüm yüzeyini (başlık + içerik)
/// kaplar ve dikey sürüklemeyi doğrudan [controller] üzerinden uygular.
/// Bu sayede kullanıcı parmağını panelin herhangi bir noktasına koyabilir;
/// içerideki [Scrollable] tabanlı bir widget'a bağlı kalınmadığı için
/// gesture arenasında rekabet/belirsizlik oluşmaz. Bu ekrandaki kartların
/// hiçbiri panel maksimum yükseklikte (`maxSize`) taşacak kadar uzun
/// olmadığından içerik için ayrı bir kaydırma mekanizmasına gerek yoktur.
class _ResizableSheetBody extends StatefulWidget {
  const _ResizableSheetBody({
    required this.controller,
    required this.snapSizes,
    required this.minSize,
    required this.maxSize,
    required this.showCollapseButton,
    required this.showExpandButton,
    required this.child,
    this.onCollapse,
    this.onExpand,
  });

  final DraggableScrollableController controller;
  final List<double> snapSizes;
  final double minSize;
  final double maxSize;
  final bool showCollapseButton;
  final bool showExpandButton;
  final Widget child;
  final VoidCallback? onCollapse;
  final VoidCallback? onExpand;

  @override
  State<_ResizableSheetBody> createState() => _ResizableSheetBodyState();
}

class _ResizableSheetBodyState extends State<_ResizableSheetBody> {
  static const _flingVelocityThreshold = 300.0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.controller.isAttached) return;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) return;

    final size = widget.controller.size;
    final next = (size - delta / screenHeight).clamp(
      widget.minSize,
      widget.maxSize,
    );
    if (next == size) return;
    widget.controller.jumpTo(next);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.controller.isAttached) return;
    final velocity = details.primaryVelocity ?? 0;
    final target = _nearestSnap(widget.controller.size, velocity);
    widget.controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  double _nearestSnap(double size, double velocity) {
    final sorted = [...widget.snapSizes]..sort();
    if (velocity.abs() > _flingVelocityThreshold) {
      if (velocity < 0) {
        return sorted.firstWhere((s) => s > size, orElse: () => sorted.last);
      }
      return sorted.lastWhere((s) => s < size, orElse: () => sorted.first);
    }
    return sorted.reduce(
      (a, b) => (a - size).abs() <= (b - size).abs() ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            showCollapseButton: widget.showCollapseButton,
            showExpandButton: widget.showExpandButton,
            onCollapse: widget.onCollapse,
            onExpand: widget.onExpand,
          ),
          Expanded(
            child: ClipRect(child: widget.child),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.showCollapseButton,
    required this.showExpandButton,
    this.onCollapse,
    this.onExpand,
  });

  final bool showCollapseButton;
  final bool showExpandButton;
  final VoidCallback? onCollapse;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final showControl = showCollapseButton || showExpandButton;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Expanded(
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
          if (showControl)
            _SheetControlButton(
              icon: showExpandButton
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              onPressed: showExpandButton ? onExpand : onCollapse,
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _SheetControlButton extends StatelessWidget {
  const _SheetControlButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.lightGrey,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 22, color: ColorConst.black),
        ),
      ),
    );
  }
}
