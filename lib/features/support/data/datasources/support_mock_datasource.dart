import 'package:bazzone_driver/features/support/domain/entities/chat_message.dart';
import 'package:bazzone_driver/features/support/domain/entities/support_chat_preview.dart';
import 'package:bazzone_driver/features/support/domain/entities/support_notification.dart';

class SupportMockDataSource {
  Future<SupportChatPreview> fetchChatPreview() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return SupportChatPreview(
      id: 'tech_support',
      title: 'Тех поддержка',
      lastMessage: 'Здравствуйте',
      updatedAt: DateTime(2025, 7, 12),
    );
  }

  Future<List<SupportNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    const body =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';

    return [
      SupportNotification(
        id: '1',
        title: 'Получайте максимум выгоды с “BazZone Drivers”',
        body: body,
        date: DateTime(2025, 7, 12),
      ),
      SupportNotification(
        id: '2',
        title: 'Получайте максимум выгоды с “BazZone Drivers”',
        body: body,
        date: DateTime(2025, 7, 12),
      ),
    ];
  }

  Future<List<ChatMessage>> fetchMessages() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [];
  }
}
