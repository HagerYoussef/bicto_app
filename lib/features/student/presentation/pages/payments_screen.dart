import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsViewModel>().loadInitialData();
      context.read<SubscriptionsViewModel>().loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PaymentsViewModel>().loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('المدفوعات والاشتراكات'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<PaymentsViewModel>().loadInitialData();
          await context.read<SubscriptionsViewModel>().loadInitialData();
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            // Current Subscription Banner
            Consumer<SubscriptionsViewModel>(
              builder: (context, svm, _) {
                final active = svm.items.where((s) => s.status == 'active').toList();
                if (svm.isInitialLoading && svm.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (active.isEmpty) return const SizedBox.shrink();
                final sub = active.first;
                return FadeInDown(child: _buildSubscriptionBanner(theme, sub));
              },
            ),
            const SizedBox(height: 32),
            Text('سجل المعاملات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer<PaymentsViewModel>(
              builder: (context, vm, _) {
                if (vm.isInitialLoading && vm.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.creditCard, size: 48, color: theme.hintColor.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text('لا توجد معاملات بعد', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                      ]),
                    ),
                  );
                }
                return Column(
                  children: [
                    ...vm.items.asMap().entries.map((entry) => FadeInRight(
                      delay: Duration(milliseconds: 80 * entry.key),
                      child: _buildTransactionItem(theme, entry.value),
                    )),
                    if (vm.isFetchingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionBanner(ThemeData theme, SubscriptionModel sub) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الباقة الحالية', style: TextStyle(color: Colors.white, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('نشط', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(sub.planName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(sub.teacherName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            children: [
              _statInfo('المتبقية', '${sub.sessionsRemaining} حِصص'),
              const Spacer(),
              _statInfo('تاريخ التجديد', AppDateUtils.formatDate(sub.expiryDate)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: sub.totalSessions > 0 ? sub.sessionsRemaining / sub.totalSessions : 0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _statInfo(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildTransactionItem(ThemeData theme, PaymentModel payment) {
    final isCredit = payment.status == 'paid' || payment.status == 'completed' || payment.status == 'success';
    final color = isCredit ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isCredit ? Colors.green : Colors.blue).withOpacity(0.1),
            child: Icon(
              isCredit ? LucideIcons.refreshCcw : LucideIcons.checkCircle,
              color: isCredit ? Colors.green : Colors.blue, size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(payment.description, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(AppDateUtils.formatDate(payment.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ]),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${payment.amount} EGP',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
