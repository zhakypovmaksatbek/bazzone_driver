import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class WalletCurrencyText extends StatelessWidget {
  const WalletCurrencyText({
    super.key,
    required this.amount,
    this.fontSize = 48,
    this.fontWeight = FontWeight.w700,
    this.color = ColorConst.black,
  });

  final String amount;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.1,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: amount),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
            text: 'с',
            style: textStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationThickness: 2,
              decorationColor: color,
            ),
          ),
        ],
      ),
    );
  }
}
