import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/auth/presentation/widgets/otp_pin_input.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/buttons/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'VerifyRoute')
class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  static const _resendDuration = 60;

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _secondsLeft = _resendDuration;

  bool get _isCodeValid => _pinController.text.length == 4;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onConfirm() {
    if (!_isCodeValid) return;
    // TODO: OTP doğrulama işlemi
    context.router.replaceAll([const MainRoute()]);
  }

  void _onResendCode() {
    if (_secondsLeft > 0) return;
    // TODO: OTP yeniden gönderme işlemi
    _pinController.clear();
    _focusNode.requestFocus();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.otp_page_enter_code.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ColorConst.grey,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: LocaleKeys.otp_page_sent_code_to_number.tr(),
                    ),
                    TextSpan(
                      text: ' ${widget.phoneNumber}',
                      style: const TextStyle(
                        color: ColorConst.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              OtpPinInput(
                controller: _pinController,
                focusNode: _focusNode,
                onChanged: (_) => setState(() {}),
                onCompleted: (_) => _onConfirm(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: LocaleKeys.button_confirm.tr(),
                isEnabled: _isCodeValid,
                onPressed: _onConfirm,
              ),
              const SizedBox(height: 16),
              _ResendCodeWidget(
                secondsLeft: _secondsLeft,
                onResend: _onResendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendCodeWidget extends StatelessWidget {
  const _ResendCodeWidget({required this.secondsLeft, required this.onResend});

  final int secondsLeft;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (secondsLeft > 0) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorConst.grey,
            height: 1.4,
          ),
          children: [
            TextSpan(text: LocaleKeys.otp_page_resend_code_again_in.tr()),
            TextSpan(
              text: '$secondsLeft сек',
              style: const TextStyle(
                color: ColorConst.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onResend,
      child: Text(
        LocaleKeys.button_resend_code.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorConst.primary,
        ),
      ),
    );
  }
}
