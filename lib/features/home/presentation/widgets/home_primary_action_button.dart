import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class HomePrimaryActionButton extends StatelessWidget {
  const HomePrimaryActionButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
    this.showTrailingIcon = true,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: ColorConst.primary,
          foregroundColor: ColorConst.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorConst.white,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (showTrailingIcon)
                    const Icon(Icons.keyboard_double_arrow_right, size: 22),
                ],
              ),
      ),
    );
  }
}
