import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'student_home.dart';
import 'teachers_list_screen.dart';
import 'packages_screen.dart';
import 'subscriptions_screen.dart';
import 'student_dashboard.dart';

class StudentMainNav extends StatefulWidget {
  const StudentMainNav({super.key});

  @override
  State<StudentMainNav> createState() => _StudentMainNavState();
}

class _StudentMainNavState extends State<StudentMainNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentHomeScreen(),
    const TeachersListScreen(),
    const PackagesScreen(),
    const SubscriptionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Platform'),
        actions: [
          _buildProfileMenu(context, theme),
          const SizedBox(width: 16),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: theme.hintColor.withOpacity(0.5),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: 'المدرسين'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.package), label: 'الباقات'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.calendarCheck), label: 'الاشتراكات'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        child: Icon(LucideIcons.user, size: 20, color: theme.primaryColor),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          Navigator.pushNamed(context, '/$value');
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem(context, 'لوحة التحكم', 'student-dashboard', LucideIcons.layoutDashboard),
        _buildPopupItem(context, 'اشتراكاتي', 'subscriptions', LucideIcons.calendarCheck),
        _buildPopupItem(context, 'حجوزاتي', 'bookings', LucideIcons.bookOpen),
        _buildPopupItem(context, 'ملخصات الجلسات', 'summaries', LucideIcons.fileText),
        _buildPopupItem(context, 'المدفوعات', 'payments', LucideIcons.creditCard),
        _buildPopupItem(context, 'الملف الشخصي', 'profile', LucideIcons.userCircle),
        const PopupMenuDivider(),
        _buildPopupItem(context, 'تسجيل الخروج', 'logout', LucideIcons.logOut, isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    {bool isDestructive = false}
  ) {
    final theme = Theme.of(context);
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? Colors.red : theme.primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDestructive ? Colors.red : theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
