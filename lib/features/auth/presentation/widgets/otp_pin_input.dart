import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpPinInput extends StatelessWidget {
  const OtpPinInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  static final _pinTheme = PinTheme(
    width: 72,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: ColorConst.black,
    ),
    decoration: BoxDecoration(
      color: ColorConst.lightGrey,
      borderRadius: BorderRadius.circular(14),
    ),
  );

  static final _placeholder = Text(
    '×',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ColorConst.grey.withValues(alpha: 0.4),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 4,
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      keyboardType: TextInputType.number,
      defaultPinTheme: _pinTheme,
      focusedPinTheme: _pinTheme,
      submittedPinTheme: _pinTheme,
      followingPinTheme: _pinTheme,
      separatorBuilder: (index) => const SizedBox(width: 12),
      preFilledWidget: _placeholder,
      showCursor: true,
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
