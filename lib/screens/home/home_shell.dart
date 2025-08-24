import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../request/request_loan_screen.dart';
import '../circles/circles_screen.dart';
import '../guarantor/guarantor_screen.dart';
import '../lend/lend_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 2; // Start with Home (center)
  
  final List<Widget> _pages = const [
    RequestLoanScreen(),
    CirclesScreen(),
    HomeScreen(),
    GuarantorScreen(),
    LendScreen(),
    DashboardScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/wathiq_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Wathiq'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTap(2),
        backgroundColor: _currentIndex == 2 
            ? AppTheme.primaryBlue 
            : AppTheme.textSecondary,
        child: const Icon(Icons.home), // only the icon
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.add_box_outlined,
                label: 'Request',
                selected: _currentIndex == 0,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                icon: Icons.groups_outlined,
                label: 'Circles',
                selected: _currentIndex == 1,
                onTap: () => _onTap(1),
              ),
              const SizedBox(width: 52), // Space for FAB
              _NavItem(
                icon: Icons.verified_user_outlined,
                label: 'Guarantor',
                selected: _currentIndex == 3,
                onTap: () => _onTap(3),
              ),
              _NavItem(
                icon: Icons.attach_money,
                label: 'Lend',
                selected: _currentIndex == 4,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryBlue : AppTheme.textSecondary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

