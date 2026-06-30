import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/support/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';

class SupportMessageBubble extends StatelessWidget {
  const SupportMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? ColorConst.primary : ColorConst.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: ColorConst.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isUser ? ColorConst.white : ColorConst.black,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
