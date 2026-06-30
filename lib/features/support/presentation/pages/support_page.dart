import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/app/app.dart';
import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/support/data/datasources/support_mock_datasource.dart';
import 'package:bazzone_driver/features/support/domain/entities/support_chat_preview.dart';
import 'package:bazzone_driver/features/support/domain/entities/support_notification.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_contact_card.dart';
import 'package:bazzone_driver/features/support/presentation/widgets/support_notification_card.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

@RoutePage(name: 'SupportRoute')
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final SupportMockDataSource _dataSource = SupportMockDataSource();

  SupportChatPreview? _chatPreview;
  List<SupportNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _dataSource.fetchChatPreview(),
      _dataSource.fetchNotifications(),
    ]);

    if (!mounted) return;

    setState(() {
      _chatPreview = results[0] as SupportChatPreview;
      _notifications = results[1] as List<SupportNotification>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.lightGrey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final chatPreview = _chatPreview!;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ColorConst.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                LocaleKeys.support_page_title.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SupportContactCard(
                chatPreview: chatPreview,
                onChatTap: () {
                  router.push(
                    SupportChatRoute(
                      chatId: chatPreview.id,
                      title: chatPreview.title,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                LocaleKeys.support_page_notifications.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorConst.grey.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          SliverList.separated(
            itemCount: _notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SupportNotificationCard(
                  notification: _notifications[index],
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
