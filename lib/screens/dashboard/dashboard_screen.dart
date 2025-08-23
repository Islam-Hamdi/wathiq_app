import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../widgets/stat_card.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/loan_service.dart';
import '../../services/guarantor_service.dart';
import '../../models/loan_model.dart';
import '../../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = UserService.instance;
    final currentUserId = authService.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('Please log in to view your dashboard.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Stats Grid
          StreamBuilder<Map<String, dynamic>>(
            stream: userService.getUserStatsStream(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final userStats = snapshot.data ?? {};

              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Financial Overview',
                      style: AppTheme.title,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        StatCard(
                          title: 'Trust Score',
                          value: '${userStats['trustScore']?.toStringAsFixed(0) ?? '0'}%',
                          icon: Icons.star,
                          color: AppTheme.successGreen,
                        ),
                        StatCard(
                          title: 'Borrowed',
                          value: '${userStats['totalBorrowed']?.toStringAsFixed(0) ?? '0'} QAR',
                          icon: Icons.trending_down,
                          color: AppTheme.warningAmber,
                        ),
                        StatCard(
                          title: 'Lent',
                          value: '${userStats['totalLent']?.toStringAsFixed(0) ?? '0'} QAR',
                          icon: Icons.trending_up,
                          color: AppTheme.primaryBlue,
                        ),
                        StatCard(
                          title: 'Guarantees',
                          value: '${userStats['guaranteeCount']?.toString() ?? '0'}/${userStats['totalGuarantees']?.toString() ?? '0'}' ,
                          icon: Icons.verified_user,
                          color: AppTheme.purpleShield,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Borrowed'),
                Tab(text: 'Lent'),
                Tab(text: 'Guarantor'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BorrowedTab(userId: currentUserId),
                _LentTab(userId: currentUserId),
                _GuarantorTab(userId: currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowedTab extends StatelessWidget {
  final String userId;
  const _BorrowedTab({required this.userId});

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final loanService = LoanService();
    final userService = UserService.instance;

    return StreamBuilder<List<LoanModel>>(
      stream: loanService.getUserLoansStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final borrowedLoans = snapshot.data ?? [];

        if (borrowedLoans.isEmpty) {
          return _EmptyState(
            icon: Icons.trending_down,
            title: 'No borrowed loans',
            subtitle: 'Your borrowing history will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: borrowedLoans.length,
          itemBuilder: (context, index) {
            final loan = borrowedLoans[index];
            return FutureBuilder<UserModel?>(
              future: userService.getUserOnce(loan.lenderId ?? ''), // Fetch lender info
              builder: (context, lenderSnapshot) {
                final lenderUsername = lenderSnapshot.data?.username ?? 'N/A';
                return _LoanCard(
                  title: 'From @$lenderUsername',
                  subtitle: loan.reason,
                  amount: loan.amount,
                  currency: loan.currency,
                  repaidAmount: 0, // TODO: Implement actual repaid amount tracking
                  status: loan.status,
                  dueDate: loan.dueDate != null ? '${loan.dueDate!.day}/${loan.dueDate!.month}/${loan.dueDate!.year}' : 'N/A',
                  reason: loan.reason,
                  guarantors: loan.guarantorIds,
                  isLender: false,
                  timeAgo: _timeAgo(loan.requestedAt),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LentTab extends StatelessWidget {
  final String userId;
  const _LentTab({required this.userId});

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final loanService = LoanService();
    final userService = UserService.instance;

    return StreamBuilder<List<LoanModel>>(
      stream: loanService.getLentLoansStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final lentLoans = snapshot.data ?? [];

        if (lentLoans.isEmpty) {
          return _EmptyState(
            icon: Icons.trending_up,
            title: 'No lent loans',
            subtitle: 'Your lending history will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lentLoans.length,
          itemBuilder: (context, index) {
            final loan = lentLoans[index];
            return FutureBuilder<UserModel?>(
              future: userService.getUserOnce(loan.borrowerId),
              builder: (context, borrowerSnapshot) {
                final borrowerUsername = borrowerSnapshot.data?.username ?? 'N/A';
                return _LoanCard(
                  title: 'To @$borrowerUsername',
                  subtitle: loan.reason,
                  amount: loan.amount,
                  currency: loan.currency,
                  repaidAmount: 0, // TODO: Implement actual repaid amount tracking
                  status: loan.status,
                  dueDate: loan.dueDate != null ? '${loan.dueDate!.day}/${loan.dueDate!.month}/${loan.dueDate!.year}' : 'N/A',
                  reason: loan.reason,
                  guarantors: loan.guarantorIds,
                  isLender: true,
                  timeAgo: _timeAgo(loan.requestedAt),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GuarantorTab extends StatelessWidget {
  final String userId;
  const _GuarantorTab({required this.userId});

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final guarantorService = GuarantorService();
    final loanService = LoanService();
    final userService = UserService.instance;

    return StreamBuilder<List<GuarantorRequest>>(
      stream: guarantorService.getUserGuarantorRequestsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final guarantorRoles = snapshot.data ?? [];

        if (guarantorRoles.isEmpty) {
          return _EmptyState(
            icon: Icons.verified_user,
            title: 'No guarantor roles',
            subtitle: 'Loans you\'ve guaranteed will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: guarantorRoles.length,
          itemBuilder: (context, index) {
            final request = guarantorRoles[index];
            return FutureBuilder<LoanModel?>(
              future: loanService.getLoanStream(request.loanId).first,
              builder: (context, loanSnapshot) {
                if (loanSnapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (loanSnapshot.hasError || !loanSnapshot.hasData || loanSnapshot.data == null) {
                  return const Text('Error loading loan details');
                }
                final loan = loanSnapshot.data!;
                return FutureBuilder<UserModel?>(
                  future: userService.getUserOnce(loan.lenderId ?? ''),
                  builder: (context, lenderSnapshot) {
                    final lenderUsername = lenderSnapshot.data?.username ?? 'N/A';
                    return _GuarantorCard(
                      borrowerName: loan.borrowerUsername,
                      borrowerUsername: '@${loan.borrowerUsername}',
                      lenderName: '@$lenderUsername',
                      amount: loan.amount,
                      currency: loan.currency,
                      status: loan.status,
                      confirmedDate: _timeAgo(request.updatedAt ?? request.requestedAt),
                      reason: loan.reason,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LoanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final double repaidAmount;
  final String status;
  final String dueDate;
  final String reason;
  final List<String> guarantors;
  final bool isLender;
  final String timeAgo;

  const _LoanCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.repaidAmount,
    required this.status,
    required this.dueDate,
    required this.reason,
    required this.guarantors,
    required this.isLender,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    final progressPercentage = repaidAmount / amount;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLender 
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : AppTheme.warningAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLender ? Icons.trending_up : Icons.trending_down,
                    color: isLender ? AppTheme.primaryBlue : AppTheme.warningAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.title,
                      ),
                      Text(
                        subtitle,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount and Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${amount.toStringAsFixed(0)} $currency',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                if (!isCompleted) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: $dueDate',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ],
              ],
            ),
            
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              // Progress Bar
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: AppTheme.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Repaid: ${repaidAmount.toStringAsFixed(0)} / ${amount.toStringAsFixed(0)} $currency',
                style: AppTheme.caption,
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Guarantors
            if (guarantors.isNotEmpty) ...[
              const Text(
                'Guarantors:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: guarantors.map((guarantorId) {
                  return FutureBuilder<UserModel?>(
                    future: UserService.instance.getUserOnce(guarantorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }
                      final guarantor = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.purpleShield.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '@${guarantor.username}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.purpleShield,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuarantorCard extends StatelessWidget {
  final String borrowerName;
  final String borrowerUsername;
  final String lenderName;
  final double amount;
  final String currency;
  final String status;
  final String confirmedDate;
  final String reason;

  const _GuarantorCard({
    required this.borrowerName,
    required this.borrowerUsername,
    required this.lenderName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.confirmedDate,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    borrowerName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrowerName,
                        style: AppTheme.title,
                      ),
                      Text(
                        borrowerUsername,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount and Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${amount.toStringAsFixed(0)} $currency',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confirmed $confirmedDate',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                // For simplicity, assuming repaidAmount is 0 if not completed, or full amount if completed
                // This needs actual implementation in LoanModel and LoanService
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCompleted ? '100%' : '0%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Repaid: ${isCompleted ? amount.toStringAsFixed(0) : '0'}',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              // Progress Bar
              const LinearProgressIndicator(
                value: 0, // Needs actual progress tracking
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.successGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


