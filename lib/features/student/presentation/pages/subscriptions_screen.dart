import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants.dart';
import 'package:provider/provider.dart';
import '../../data/models/student_models.dart';
import '../viewmodels/student_viewmodels.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionsViewModel>().loadInitialData();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SubscriptionsViewModel>().loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراكاتي'), centerTitle: true),
      body: Consumer<SubscriptionsViewModel>(
        builder: (context, vm, _) {
          if (vm.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.error!),
                  ElevatedButton(
                    onPressed: () => vm.loadInitialData(),
                    child: const Text('إعادة المحاولة'),
                  )
                ],
              ),
            );
          }
          if (vm.items.isEmpty) {
            return const Center(child: Text('لا يوجد اشتراكات حالياً.'));
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(24.0),
            itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              if (index == vm.items.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
              }
              final sub = vm.items[index];
              return _buildSubscriptionCard(
                theme,
                sub: sub,
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(
    ThemeData theme, {
    required SubscriptionModel sub,
    required int index,
  }) {
    Color statusColor = sub.isExpired ? Colors.grey : (sub.isWarning ? Colors.orange : Colors.green);
    
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sub.planName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    sub.status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sub.teacherName,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاريخ الانتهاء', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(sub.expiryDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('الجلسات المتبقية', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${sub.sessionsRemaining} / ${sub.totalSessions}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: sub.totalSessions == 0 ? 0 : sub.sessionsRemaining / sub.totalSessions,
              backgroundColor: statusColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}