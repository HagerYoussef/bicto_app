import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class SummariesScreen extends StatefulWidget {
  const SummariesScreen({super.key});

  @override
  State<SummariesScreen> createState() => _SummariesScreenState();
}

class _SummariesScreenState extends State<SummariesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SummariesViewModel>().loadInitialData();
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
      context.read<SummariesViewModel>().loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ملخصات الجلسات'), centerTitle: true),
      body: Consumer<SummariesViewModel>(
        builder: (context, vm, _) {
          if (vm.isInitialLoading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.items.isEmpty) {
            return _buildError(theme, vm.error!, () => vm.loadInitialData());
          }
          if (vm.items.isEmpty) {
            return _buildEmpty(theme, 'لا توجد ملخصات بعد');
          }
          return RefreshIndicator(
            onRefresh: () => vm.loadInitialData(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.items.length) {
                  return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                }
                return FadeInUp(
                  delay: Duration(milliseconds: 60 * index),
                  child: _buildSummaryCard(theme, vm.items[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, SummaryModel summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.fileText, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.classTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(summary.teacherName, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                Text(AppDateUtils.formatDate(summary.sessionDate), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          if (summary.fileUrls.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.download, size: 20),
              onPressed: () async {
                try {
                  final uri = Uri.parse(summary.fileUrls.first);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الملف')));
                  }
                }
              },
              color: theme.primaryColor,
              tooltip: 'تحميل',
            ),
          IconButton(
            icon: const Icon(LucideIcons.eye, size: 20),
            onPressed: () => _showSummaryDetails(context, theme, summary),
            color: Colors.grey,
            tooltip: 'معاينة',
          ),
        ],
      ),
    );
  }

  void _showSummaryDetails(BuildContext context, ThemeData theme, SummaryModel summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(summary.classTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(summary.teacherName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 16),
              if (summary.content != null) ...[
                Text('المحتوى', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(summary.content!, style: theme.textTheme.bodyMedium),
              ],
              if (summary.fileUrls.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('الملفات المرفقة', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...summary.fileUrls.map((url) => ListTile(
                  leading: const Icon(LucideIcons.fileText),
                  title: Text('ملف ${summary.fileUrls.indexOf(url) + 1}', style: const TextStyle(fontSize: 14)),
                  trailing: const Icon(LucideIcons.externalLink, size: 16),
                  onTap: () async {
                    try {
                      final uri = Uri.parse(url);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الملف')));
                    }
                  },
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String msg, VoidCallback retry) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.wifiOff, size: 48, color: theme.hintColor),
      const SizedBox(height: 16),
      Text(msg, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: retry, child: const Text('إعادة المحاولة')),
    ]));
  }

  Widget _buildEmpty(ThemeData theme, String msg) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.fileText, size: 64, color: theme.hintColor.withOpacity(0.4)),
      const SizedBox(height: 16),
      Text(msg, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
    ]));
  }
}
