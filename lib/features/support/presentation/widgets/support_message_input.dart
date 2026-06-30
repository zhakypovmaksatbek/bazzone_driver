import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class SupportMessageInput extends StatelessWidget {
  const SupportMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: ColorConst.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: ColorConst.lightGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: ColorConst.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onSend,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: ColorConst.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
