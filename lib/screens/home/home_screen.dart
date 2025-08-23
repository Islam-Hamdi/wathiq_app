import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../widgets/how_it_works_card.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/loan_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = UserService.instance;
    final loanService = LoanService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryBlueLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authService.currentUser != null
                            ? 'Welcome, ${authService.currentUser!.displayName ?? authService.currentUser!.email!.split('@')[0]}'
                            : 'Welcome to Wathiq',
                        style: AppTheme.h2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Borrow and lend with confidence using your social connections.',
                  style: AppTheme.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Request Loan screen (assuming it's at index 1 in HomeShell)
                    DefaultTabController.of(context).animateTo(1);
                  },
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Request a Loan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Lend screen (assuming it's at index 2 in HomeShell)
                    DefaultTabController.of(context).animateTo(2);
                  },
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Lend to Someone'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Trust highlights
          StreamBuilder<Map<String, dynamic>>(
            stream: loanService.getGlobalLoanStatsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final stats = snapshot.data ?? {};
              final totalLoans = stats['totalLoans']?.toString() ?? '0';
              final repaymentRate = stats['repaymentRate']?.toStringAsFixed(0) ?? '0';
              final totalLent = stats['totalLent']?.toStringAsFixed(0) ?? '0';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.successGreen, Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Community Trust Statistics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(totalLoans, 'Loans Funded'),
                        _StatItem('$repaymentRate%', 'Repayment Rate'),
                        _StatItem('\$$totalLent', 'Total Lent'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // How Wathiq Works
          const Text(
            'How Wathiq Works',
            style: AppTheme.h2,
          ),
          const SizedBox(height: 16),
          const HowItWorksCard(
            step: 1,
            title: 'Request a Loan',
            description: 'Add 1–3 trusted guarantors from your network.',
            icon: Icons.add_box_outlined,
          ),
          const SizedBox(height: 12),
          const HowItWorksCard(
            step: 2,
            title: 'Guarantor Confirmation',
            description: 'They confirm your request; trust builds.',
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 12),
          const HowItWorksCard(
            step: 3,
            title: 'Get Funded',
            description: 'Community lenders review and fund your loan.',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 32),
          
          // Trust & Compliance highlights
          const Text(
            'Why Choose Wathiq?',
            style: AppTheme.h2,
          ),
          const SizedBox(height: 16),
          const _HighlightCard(
            icon: Icons.groups,
            title: 'Community Trust',
            description: 'Leverage your social connections as guarantors.',
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 12),
          const _HighlightCard(
            icon: Icons.mosque,
            title: 'Sharia Compliant',
            description: 'Interest-free lending (Kafala & Qard Hasan).',
            color: AppTheme.successGreen,
          ),
          const SizedBox(height: 12),
          const _HighlightCard(
            icon: Icons.security,
            title: 'Secure & Private',
            description: 'Transactions are kept safe and private.',
            color: AppTheme.purpleShield,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.title,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


