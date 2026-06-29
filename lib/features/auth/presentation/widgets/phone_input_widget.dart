import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputWidget extends StatelessWidget {
  const PhoneInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _countryCode = '+996';
  static const _placeholder = '700 000 000';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CountryCodeBox(code: _countryCode),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
              _PhoneNumberFormatter(),
            ],
            onChanged: onChanged,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorConst.black,
            ),
            decoration: InputDecoration(
              hintText: _placeholder,

              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorConst.grey.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: ColorConst.lightGrey,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountryCodeBox extends StatelessWidget {
  const _CountryCodeBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇰🇬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            code,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorConst.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
