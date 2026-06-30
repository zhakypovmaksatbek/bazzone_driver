import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.isLoading = false,
    this.color,
    this.height = 60.0,
    this.backgroundColor,
    this.textColor,
    this.thumbColor,
    this.thumbIconColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool isLoading;
  final Color? color;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? thumbColor;
  final Color? thumbIconColor;
  final Color? borderColor;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  static const _thumbDiameter = 52.0;
  static const _horizontalPadding = 4.0;
  static const _confirmThreshold = 0.80;

  double _dragOffset = 0;
  double _maxDragWidth = 0;
  bool _confirmed = false;

  late AnimationController _returnController;
  Animation<double>? _returnAnimation;

  Color get _color => widget.color ?? ColorConst.primary;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(_onReturnTick);
  }

  @override
  void didUpdateWidget(SwipeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isLoading && !widget.isLoading) ||
        (oldWidget.label != widget.label)) {
      setState(() {
        _confirmed = false;
        _dragOffset = 0;
      });
    }
  }

  void _onReturnTick() {
    final animation = _returnAnimation;
    if (animation == null) return;
    setState(() => _dragOffset = animation.value);
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  double get _progress =>
      _maxDragWidth <= 0 ? 0 : (_dragOffset / _maxDragWidth).clamp(0.0, 1.0);

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.isLoading || _confirmed) return;
    _returnController.stop();
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, _maxDragWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.isLoading || _confirmed) return;

    if (_progress >= _confirmThreshold) {
      setState(() {
        _dragOffset = _maxDragWidth;
        _confirmed = true;
      });
      HapticFeedback.mediumImpact();
      widget.onConfirmed();
      return;
    }

    _returnAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.elasticOut),
    );
    _returnController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _maxDragWidth = constraints.maxWidth -
              _thumbDiameter -
              (_horizontalPadding * 2);

          final backgroundOpacity = 0.08 + 0.12 * _progress;
          final labelOpacity = (1 - _progress * 1.5).clamp(0.0, 1.0);

          final bg = widget.backgroundColor ?? _color.withValues(alpha: backgroundOpacity);
          final borderCol = widget.borderColor ?? _color;
          final textCol = widget.textColor ?? _color;

          return GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(color: borderCol),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                     opacity: labelOpacity,
                     child: Text(
                       widget.label,
                       style: TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.w700,
                         color: textCol,
                       ),
                     ),
                  ),
                  Positioned(
                    left: _horizontalPadding + _dragOffset,
                    child: _buildThumb(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumb() {
    final tColor = widget.thumbColor ?? _color;
    final tIconColor = widget.thumbIconColor ?? ColorConst.white;
    return Container(
      width: _thumbDiameter,
      height: _thumbDiameter,
      decoration: BoxDecoration(
        color: tColor,
        shape: BoxShape.circle,
      ),
      child: widget.isLoading
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tIconColor,
              ),
            )
          : Icon(
              Icons.arrow_forward,
              color: tIconColor,
              size: 24,
            ),
    );
  }
}
