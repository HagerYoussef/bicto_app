import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants.dart';
import 'package:provider/provider.dart';
import '../../data/models/student_models.dart';
import '../viewmodels/student_viewmodels.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansViewModel>().fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Consumer<PlansViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.plans.isEmpty) {
            return const Center(child: Text('لا توجد باقات متاحة حالياً'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختر الباقة المناسبة لك',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'استثمر في مستقبلك اليوم واحصل على خصومات حصرية',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 32),
                  ...vm.plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildPackageCard(
                        theme: theme,
                        plan: plan,
                        color: _getPlanColor(index),
                        index: index,
                        isPopular: index == 1,
                        onTap: () => _handleCheckout(context, plan),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPlanColor(int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    return colors[index % colors.length];
  }

  Future<void> _handleCheckout(BuildContext context, PlanModel plan) async {
    final vm = context.read<PlansViewModel>();
    final response = await vm.checkoutPlan(plan.id);
    
    if (context.mounted) {
      if (response != null && response.url.isNotEmpty) {
        final uri = Uri.parse(response.url);
        
        // Open the payment URL
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // After returning to the app, we can show a dialog or check status
        if (context.mounted) {
          _showPaymentStatusDialog(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل الاشتراك، حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تحقق من حالة الدفع', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل أتممت عملية الدفع؟ سنقوم بالتأكد من حالة العملية الآن.'),
            const SizedBox(height: 24),
            Consumer<PlansViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () async {
                    final result = await vm.checkPaymentStatus();
                    if (context.mounted) {
                      if (result != null && (result['status'] == 'paid' || result['status'] == 'captured' || result['status'] == 'success')) {
                        Navigator.pop(context);
                        _showSuccessDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لم يتم تأكيد الدفع بعد، برجاء المحاولة مرة أخرى إذا كنت قد أتممت العملية')),
                        );
                      }
                    }
                  },
                  child: const Text('التحقق الآن'),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 48),
        title: const Text('تم الاشتراك بنجاح'),
        content: const Text('مبروك! تم تفعيل الباقة الخاصة بك بنجاح.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Refresh subscriptions or navigate back
              context.read<SubscriptionsViewModel>().loadInitialData();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required ThemeData theme,
    required PlanModel plan,
    required Color color,
    bool isPopular = false,
    required int index,
    required VoidCallback onTap,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 * index),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: isPopular ? Border.all(color: theme.primaryColor, width: 2) : Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('الأكثر طلباً', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            Text(
              plan.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.formattedPrice ?? plan.price.toInt().toString(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: plan.formattedPrice != null ? 32 : null,
                  ),
                ),
                if (plan.formattedPrice == null) ...[
                  const SizedBox(width: 4),
                  const Text('جنيه', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
                const Text(' / شهرياً'),
              ],
            ),
            if (plan.classLimit != null) ...[
              const SizedBox(height: 8),
              Text(
                '${plan.classLimit} حصة في الشهر',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ],
            if (plan.description != null && plan.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(plan.description!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: onTap,
                child: const Text('اشترك الآن', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 18, color: Colors.green),
          const SizedBox(width: 12),
          Text(feature, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
