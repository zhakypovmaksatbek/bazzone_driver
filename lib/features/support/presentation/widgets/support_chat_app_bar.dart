import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_avatar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportChatAppBar extends StatelessWidget {
  const SupportChatAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.phoneNumber = '+996555555555',
  });

  final String title;
  final VoidCallback onBack;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      color: ColorConst.white,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: ColorConst.black,
            ),
          ),
          const SupportAvatar(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
          ),
          Material(
            color: ColorConst.lightGrey,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => _callSupport(context),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.phone_rounded,
                  size: 20,
                  color: ColorConst.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callSupport(BuildContext context) async {
    final uri = Uri.parse('tel:$phoneNumber');
    await launchUrl(uri);
  }
}
