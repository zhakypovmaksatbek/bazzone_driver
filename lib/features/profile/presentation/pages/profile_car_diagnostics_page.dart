import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/presentation/pages/custom_camera_page.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/profile_back_app_bar.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_state.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ProfileCarDiagnosticsRoute')
class ProfileCarDiagnosticsPage extends StatefulWidget {
  const ProfileCarDiagnosticsPage({super.key});

  @override
  State<ProfileCarDiagnosticsPage> createState() =>
      _ProfileCarDiagnosticsPageState();
}

class _ProfileCarDiagnosticsPageState extends State<ProfileCarDiagnosticsPage> {
  final Map<String, File?> _photos = {};

  final List<String> _slots = [
    LocaleKeys.car_diagnostics_page_back_seat,
    LocaleKeys.car_diagnostics_page_front_seat,
    LocaleKeys.car_diagnostics_page_left_side,
    LocaleKeys.car_diagnostics_page_right_side,
    LocaleKeys.car_diagnostics_page_front_part,
    LocaleKeys.car_diagnostics_page_back_part,
    LocaleKeys.car_diagnostics_page_open_trunk,
    LocaleKeys.car_diagnostics_page_license_front,
    LocaleKeys.car_diagnostics_page_license_back,
  ];

  bool _isSubmitting = false;

  StencilType _getStencilTypeForSlot(String slotKey) {
    if (slotKey == LocaleKeys.car_diagnostics_page_back_seat ||
        slotKey == LocaleKeys.car_diagnostics_page_front_seat) {
      return StencilType.seat;
    } else if (slotKey == LocaleKeys.car_diagnostics_page_left_side ||
        slotKey == LocaleKeys.car_diagnostics_page_right_side) {
      return StencilType.carSide;
    } else if (slotKey == LocaleKeys.car_diagnostics_page_open_trunk) {
      return StencilType.carTrunk;
    } else if (slotKey == LocaleKeys.car_diagnostics_page_license_front ||
        slotKey == LocaleKeys.car_diagnostics_page_license_back) {
      return StencilType.license;
    } else {
      return StencilType.carFrontBack;
    }
  }

  Future<void> _pickImageAndContinue(int index) async {
    final slotKey = _slots[index];
    try {
      final String? resultPath = await context.router.push<String?>(
        CustomCameraRoute(
          title: slotKey.tr(),
          stencilType: _getStencilTypeForSlot(slotKey),
        ),
      );

      if (resultPath != null) {
        setState(() {
          _photos[slotKey] = File(resultPath);
        });

        // Find the next empty slot to auto-prompt
        int nextIndex = index + 1;
        while (nextIndex < _slots.length &&
            _photos[_slots[nextIndex]] != null) {
          nextIndex++;
        }

        if (nextIndex < _slots.length) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Отлично! Следующий шаг: ${_slots[nextIndex].tr()}',
                ),
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Future.delayed(const Duration(milliseconds: 2200), () {
              if (mounted) {
                _pickImageAndContinue(nextIndex);
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при съемке фото: $e'),
            backgroundColor: ColorConst.error,
          ),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context, int index) {
    final slotKey = _slots[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConst.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: ColorConst.primary,
                ),
                title: const Text('Сделать фото заново'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndContinue(index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: ColorConst.error,
                ),
                title: const Text(
                  'Удалить фото',
                  style: TextStyle(color: ColorConst.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photos[slotKey] = null;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitDiagnostics() async {
    final missingSlots = _slots.where((slot) => _photos[slot] == null).toList();

    if (missingSlots.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Пожалуйста, добавьте все фотографии для диагностики авто.',
          ),
          backgroundColor: ColorConst.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate upload/save API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ProfileState.isDiagnosticsCompleted.value = true;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConst.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: ColorConst.success,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Успешно!'),
          ],
        ),
        content: const Text(
          'Фотографии диагностики автомобиля отправлены на проверку.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.router.maybePop(); // go back
            },
            child: const Text(
              'ОК',
              style: TextStyle(
                color: ColorConst.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileBackAppBar(
                  title: LocaleKeys.car_diagnostics_page_title.tr(),
                  onBack: () => context.router.maybePop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ColorConst.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < _slots.length; i += 2)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildSlotItem(_slots[i]),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: (i + 1 < _slots.length)
                                              ? _buildSlotItem(_slots[i + 1])
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _isSubmitting
                                ? null
                                : _submitDiagnostics,
                            style: FilledButton.styleFrom(
                              backgroundColor: ColorConst.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              LocaleKeys.car_diagnostics_page_next.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColorConst.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSubmitting)
              Container(
                color: ColorConst.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: ColorConst.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotItem(String slotKey) {
    final file = _photos[slotKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            final index = _slots.indexOf(slotKey);
            if (_photos[slotKey] == null) {
              _pickImageAndContinue(index);
            } else {
              _showPhotoOptions(context, index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: file == null ? const Color(0xFFF1F2F9) : Colors.black12,
              borderRadius: BorderRadius.circular(20),
              image: file != null
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : null,
            ),
            child: file == null
                ? const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Color(0xFF9E9E9E),
                      size: 28,
                    ),
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slotKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorConst.grey,
          ),
        ),
      ],
    );
  }
}
