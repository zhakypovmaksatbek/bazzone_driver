import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/auth/presentation/widgets/phone_input_widget.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/buttons/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'OtpRoute')
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _phoneController = TextEditingController();

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 9;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetCode() {
    if (!_isPhoneValid) return;
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneNumber =
        '+996 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    context.router.push(VerifyRoute(phoneNumber: phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    LocaleKeys.otp_page_title.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.otp_page_description.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: ColorConst.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PhoneInputWidget(
                    controller: _phoneController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: LocaleKeys.button_get_code.tr(),
                    isEnabled: _isPhoneValid,
                    onPressed: _onGetCode,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.otp_page_terms_of_use.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConst.grey.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
