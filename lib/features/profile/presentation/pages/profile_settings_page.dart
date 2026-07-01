import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_state.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileSettingsRoute')
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  String _getLanguageLabel(BuildContext context) {
    final languageCode = context.locale.languageCode;
    if (languageCode == 'ky') {
      return 'Кыргызча';
    }
    return 'Русский';
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConst.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final currentLanguage = context.locale.languageCode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorConst.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  LocaleKeys.profile_settings_page_languages.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.black,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Русский'),
                trailing: currentLanguage == 'ru'
                    ? const Icon(Icons.check_circle_rounded, color: ColorConst.primary)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1, color: ColorConst.lightGrey),
              ListTile(
                title: const Text('Кыргызча'),
                trailing: currentLanguage == 'ky'
                    ? const Icon(Icons.check_circle_rounded, color: ColorConst.primary)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('ky'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorConst.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            LocaleKeys.profile_settings_page_logout_confirm_title.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(LocaleKeys.profile_settings_page_logout_confirm_desc.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocaleKeys.profile_settings_page_logout_confirm_no.tr(),
                style: const TextStyle(color: ColorConst.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop dialog
                context.router.replaceAll([const OtpRoute()]); // Logout to OTP login screen
              },
              child: Text(
                LocaleKeys.profile_settings_page_logout_confirm_yes.tr(),
                style: const TextStyle(color: ColorConst.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBackAppBar(
              title: LocaleKeys.profile_settings_page_title.tr(),
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConst.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: ProfileState.isSoundNotificationsEnabled,
                            builder: (context, soundEnabled, _) {
                              return _buildSettingsTile(
                                icon: Icons.notifications_active_outlined,
                                title: LocaleKeys.profile_settings_page_sound_notifications.tr(),
                                trailing: Switch(
                                  value: soundEnabled,
                                  onChanged: (value) =>
                                      ProfileState.isSoundNotificationsEnabled.value = value,
                                  activeThumbColor: ColorConst.primary,
                                ),
                                onTap: () {
                                  ProfileState.isSoundNotificationsEnabled.value =
                                      !ProfileState.isSoundNotificationsEnabled.value;
                                },
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 64, color: ColorConst.lightGrey),
                          _buildSettingsTile(
                            icon: Icons.language_rounded,
                            title: LocaleKeys.profile_settings_page_languages.tr(),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getLanguageLabel(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ColorConst.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: ColorConst.grey,
                                ),
                              ],
                            ),
                            onTap: () => _showLanguageSelector(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorConst.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: null,
                            title: LocaleKeys.profile_settings_page_privacy_policy.tr(),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: ColorConst.grey,
                            ),
                            onTap: () {
                              _showMockInfo(context, LocaleKeys.profile_settings_page_privacy_policy.tr());
                            },
                          ),
                          const Divider(height: 1, indent: 20, color: ColorConst.lightGrey),
                          _buildSettingsTile(
                            icon: null,
                            title: LocaleKeys.profile_settings_page_app_permissions.tr(),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: ColorConst.grey,
                            ),
                            onTap: () {
                              _showMockInfo(context, LocaleKeys.profile_settings_page_app_permissions.tr());
                            },
                          ),
                          const Divider(height: 1, indent: 20, color: ColorConst.lightGrey),
                          _buildSettingsTile(
                            icon: null,
                            title: LocaleKeys.profile_settings_page_logout.tr(),
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorConst.error,
                            ),
                            trailing: const SizedBox.shrink(),
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData? icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    TextStyle? titleStyle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F2F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: ColorConst.black,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: titleStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConst.black,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showMockInfo(BuildContext context, String title) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Раздел "$title" находится в разработке.',
          style: const TextStyle(color: ColorConst.white),
        ),
        backgroundColor: ColorConst.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
