import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../features/student/presentation/pages/class_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsViewModel>().loadInitialData();
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
      context.read<BookingsViewModel>().loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي'), centerTitle: true),
      body: Consumer<BookingsViewModel>(
        builder: (context, vm, _) {
          if (vm.isInitialLoading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.items.isEmpty) {
            return _buildError(theme, vm.error!, () => vm.loadInitialData());
          }
          if (vm.items.isEmpty) {
            return _buildEmpty(theme, 'لا توجد حجوزات بعد');
          }
          return RefreshIndicator(
            onRefresh: () => vm.loadInitialData(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return FadeInUp(
                  delay: Duration(milliseconds: 60 * index),
                  child: _buildBookingCard(theme, vm.items[index], vm),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(ThemeData theme, BookingModel booking, BookingsViewModel vm) {
    final clsStatus = booking.classStatus.toLowerCase();
    final isCancelled = clsStatus == 'cancelled';
    final isFinished = clsStatus == 'finished' || clsStatus == 'completed';
    final isUpcoming = booking.isUpcoming && !isCancelled && !isFinished;
    
    final Color statusColor;
    final String statusLabel;
    
    if (isCancelled) {
      statusColor = Colors.red;
      statusLabel = 'ملغاة';
    } else if (isFinished) {
      statusColor = Colors.green;
      statusLabel = 'مكتملة';
    } else if (clsStatus == 'ongoing') {
      statusColor = Colors.orange;
      statusLabel = 'جارية حالياً';
    } else {
      statusColor = Colors.blue;
      statusLabel = 'قادمة';
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context, 
        '/class-details', 
        arguments: {
          'classId': booking.classId,
          'initialData': booking,
        },
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusBadge(statusLabel, statusColor),
              Text(AppDateUtils.formatDate(booking.startTime), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: booking.teacherAvatar != null ? NetworkImage(booking.teacherAvatar!) : null,
                child: booking.teacherAvatar == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.classTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(booking.teacherName, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoTile(theme, LucideIcons.clock, AppDateUtils.formatTime(booking.startTime)),
              const SizedBox(width: 24),
              _infoTile(theme, LucideIcons.video, 'أونلاين'),
            ],
          ),
          if (booking.description != null && booking.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('الوصف:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(booking.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (booking.lessonMaterialUrl != null && booking.lessonMaterialUrl!.isNotEmpty)
                ActionChip(
                  avatar: const Icon(LucideIcons.fileText, size: 14),
                  label: const Text('المادة العلمية', style: TextStyle(fontSize: 10)),
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(booking.lessonMaterialUrl!);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح المادة المطلوبة')));
                    }
                  },
                ),
              ActionChip(
                avatar: const Icon(LucideIcons.clipboardList, size: 14),
                label: const Text('الواجبات (Assignments)', style: TextStyle(fontSize: 10)),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/assignments',
                    arguments: booking.classId,
                  );
                },
              ),
            ],
          ),
          if (booking.canJoin) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final uri = Uri.parse(booking.meetingUrl!);
                try {
                  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!launched) {
                    throw Exception('Could not launch');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكن فتح رابط الاجتماع')),
                    );
                  }
                }
              },
              child: const Text('دخول الحصة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          if (isUpcoming) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('إلغاء الحجز'),
                    content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('تراجع')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          vm.cancelBooking(booking.id);
                        },
                        child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
                child: const Text('إلغاء الحجز'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoTile(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildError(ThemeData theme, String msg, VoidCallback retry) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.wifiOff, size: 48, color: theme.hintColor),
        const SizedBox(height: 16),
        Text(msg, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: retry, child: const Text('إعادة المحاولة')),
      ]),
    );
  }

  Widget _buildEmpty(ThemeData theme, String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.calendarX, size: 64, color: theme.hintColor.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text(msg, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
      ]),
    );
  }
}
