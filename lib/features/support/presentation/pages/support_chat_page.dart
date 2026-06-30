import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/support/data/datasources/support_mock_datasource.dart';
import 'package:bazzone_driver/features/support/domain/entities/chat_message.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_chat_app_bar.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_message_bubble.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_message_input.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

@RoutePage(name: 'SupportChatRoute')
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({
    super.key,
    required this.chatId,
    required this.title,
  });

  final String chatId;
  final String title;

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final SupportMockDataSource _dataSource = SupportMockDataSource();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messageController.text = LocaleKeys.support_page_greeting.tr();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await _dataSource.fetchMessages();

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages = [
        ..._messages,
        ChatMessage(
          id: _uuid.v4(),
          text: text,
          sentAt: DateTime.now(),
          isFromUser: true,
        ),
      ];
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            SupportChatAppBar(
              title: widget.title,
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessages(),
            ),
            SupportMessageInput(
              controller: _messageController,
              hintText: LocaleKeys.support_page_message_hint.tr(),
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return SupportMessageBubble(message: _messages[index]);
      },
    );
  }
}
