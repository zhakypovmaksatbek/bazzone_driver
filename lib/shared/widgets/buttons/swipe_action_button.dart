import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Kaydırarak onayla" tarzı eylem butonu (örn. "Vardım", "Siparişi bitir").
///
/// Tutamaç eşik mesafesinin ötesine sürüklendiğinde [onConfirmed] tetiklenir.
/// Eşiğe ulaşmadan bırakılırsa tutamaç başlangıç konumuna geri döner.
class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.isLoading = false,
    this.confirmThreshold = 0.72,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool isLoading;

  /// Onay tetiklenmesi için tutamacın izlemesi gereken yol oranı (0-1).
  final double confirmThreshold;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton> {
  static const _trackHeight = 60.0;
  static const _thumbSize = 52.0;
  static const _thumbInset = 4.0;

  double _dragExtent = 0;
  bool _dragging = false;
  bool _confirmed = false;

  @override
  void didUpdateWidget(SwipeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      setState(() {
        _confirmed = false;
        _dragExtent = 0;
      });
    }
  }

  double _maxDrag(double trackWidth) =>
      trackWidth - _thumbSize - _thumbInset * 2;

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (widget.isLoading || _confirmed) return;
    final maxDrag = _maxDrag(trackWidth);
    setState(() {
      _dragging = true;
      _dragExtent = (_dragExtent + details.delta.dx).clamp(0, maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details, double trackWidth) {
    if (widget.isLoading || _confirmed) return;
    final maxDrag = _maxDrag(trackWidth);
    final reachedThreshold =
        maxDrag > 0 && _dragExtent / maxDrag >= widget.confirmThreshold;

    if (reachedThreshold) {
      HapticFeedback.mediumImpact();
      setState(() {
        _dragging = false;
        _confirmed = true;
        _dragExtent = maxDrag;
      });
      widget.onConfirmed();
    } else {
      setState(() {
        _dragging = false;
        _dragExtent = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _trackHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final maxDrag = _maxDrag(trackWidth);
          final progress =
              maxDrag > 0 ? (_dragExtent / maxDrag).clamp(0, 1) : 0.0;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: ColorConst.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(_trackHeight / 2),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Opacity(
                    opacity: (1 - progress * 1.4).clamp(0, 1).toDouble(),
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primary,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: _thumbInset + _dragExtent,
                  top: _thumbInset,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) =>
                        _onDragUpdate(d, trackWidth),
                    onHorizontalDragEnd: (d) => _onDragEnd(d, trackWidth),
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: ColorConst.primary,
                        shape: BoxShape.circle,
                      ),
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorConst.white,
                              ),
                            )
                          : const Icon(
                              Icons.keyboard_double_arrow_right,
                              color: ColorConst.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
