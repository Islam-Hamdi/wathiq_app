import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/loan_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/loan_model.dart';
import '../../models/user_model.dart';

class LendScreen extends StatefulWidget {
  const LendScreen({super.key});

  @override
  State<LendScreen> createState() => _LendScreenState();
}

class _LendScreenState extends State<LendScreen> {
  String _sortBy = 'Newest';
  String _amountFilter = 'All amounts';
  bool _isLoading = false;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _fundLoan(String loanId) async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loanService = LoanService();

      if (authService.currentUser == null) {
        _showSnackBar('You must be logged in to fund a loan', Colors.red);
        return;
      }

      await loanService.fundLoan(loanId, authService.currentUser!.uid);
      _showSnackBar('Loan funded successfully!', AppTheme.successGreen);
    } catch (e) {
      _showSnackBar('Failed to fund loan: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanService = LoanService();
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Requests'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    label: 'Sort by',
                    value: _sortBy,
                    items: const ['Newest', 'Oldest', 'Amount (High)', 'Amount (Low)', 'Trust Score'],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterDropdown(
                    label: 'Amount',
                    value: _amountFilter,
                    items: const ['All amounts', 'Under 1,000', '1,000 - 5,000', 'Over 5,000'],
                    onChanged: (value) {
                      setState(() {
                        _amountFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Loan Requests List
          Expanded(
            child: StreamBuilder<List<LoanModel>>(
              stream: loanService.getOpenLoanRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _EmptyState();
                }

                List<LoanModel> loans = snapshot.data!;

                // Apply filters and sorting
                if (_amountFilter != 'All amounts') {
                  loans = loans.where((loan) {
                    if (_amountFilter == 'Under 1,000') return loan.amount < 1000;
                    if (_amountFilter == '1,000 - 5,000') return loan.amount >= 1000 && loan.amount <= 5000;
                    if (_amountFilter == 'Over 5,000') return loan.amount > 5000;
                    return true;
                  }).toList();
                }

                loans.sort((a, b) {
                  if (_sortBy == 'Newest') return b.requestedAt.compareTo(a.requestedAt);
                  if (_sortBy == 'Oldest') return a.requestedAt.compareTo(b.requestedAt);
                  if (_sortBy == 'Amount (High)') return b.amount.compareTo(a.amount);
                  if (_sortBy == 'Amount (Low)') return a.amount.compareTo(b.amount);
                  // Trust Score sorting would require fetching borrower's trust score
                  return 0;
                });

                if (loans.isEmpty) {
                  return _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    return _LoanRequestCard(
                      loan: loan,
                      onView: () {
                        _showLoanDetails(context, loan);
                      },
                      onFund: () {
                        _showFundDialog(context, loan);
                      },
                      isLoading: _isLoading,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLoanDetails(BuildContext context, LoanModel loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LoanDetailsSheet(loan: loan),
    );
  }

  void _showFundDialog(BuildContext context, LoanModel loan) {
    showDialog(
      context: context,
      builder: (context) => _FundLoanDialog(loan: loan, onFund: _fundLoan),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LoanRequestCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onView;
  final VoidCallback onFund;
  final bool isLoading;

  const _LoanRequestCard({
    required this.loan,
    required this.onView,
    required this.onFund,
    required this.isLoading,
  });

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return Colors.red;
      case 'business':
        return AppTheme.primaryBlue;
      case 'education':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFullyGuaranteed = loan.guarantorIds.isNotEmpty; // Simplified for now
    
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
                    loan.borrowerUsername.substring(0, 1).toUpperCase(),
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
                      Row(
                        children: [
                          Text(
                            loan.borrowerUsername,
                            style: AppTheme.title,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(loan.reason.split(' ').first).withOpacity(0.1), // Using first word of reason as category
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              loan.reason.split(' ').first, // Using first word of reason as category
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(loan.reason.split(' ').first),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '@${loan.borrowerUsername} • ${_timeAgo(loan.requestedAt)}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                // Trust Score - Placeholder for now
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: AppTheme.successGreen,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '90%', // Placeholder trust score
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: AppTheme.warningAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${loan.amount.toStringAsFixed(0)} ${loan.currency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warningAmber,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '≈ \$${(loan.amount * 0.27).toStringAsFixed(0)} USD', // Assuming 1 QAR = 0.27 USD
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Reason (truncated)
            Text(
              loan.reason,
              style: AppTheme.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Guarantors Status
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: isFullyGuaranteed 
                      ? AppTheme.successGreen 
                      : AppTheme.warningAmber,
                ),
                const SizedBox(width: 4),
                Text(
                  'Guarantors: ${loan.guarantorIds.length} confirmed', // Simplified
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isFullyGuaranteed 
                        ? AppTheme.successGreen 
                        : AppTheme.warningAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onView,
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onFund,
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Fund'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.attach_money,
                size: 48,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No loan requests',
              style: AppTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new lending opportunities',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanDetailsSheet extends StatelessWidget {
  final LoanModel loan;

  const _LoanDetailsSheet({required this.loan});

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return Colors.red;
      case 'business':
        return AppTheme.primaryBlue;
      case 'education':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Borrower Info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                child: Text(
                  loan.borrowerUsername.substring(0, 1).toUpperCase(),
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
                      loan.borrowerUsername,
                      style: AppTheme.title,
                    ),
                    Text(
                      '@${loan.borrowerUsername} • ${_timeAgo(loan.requestedAt)}',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              // Trust Score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: AppTheme.successGreen,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '90%', // Placeholder trust score
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Loan Details
          _DetailRow(
            icon: Icons.attach_money,
            label: 'Amount',
            value: '${loan.amount.toStringAsFixed(0)} ${loan.currency}',
          ),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Due Date',
            value: loan.dueDate != null
                ? '${loan.dueDate!.day}/${loan.dueDate!.month}/${loan.dueDate!.year}'
                : 'Not specified',
          ),
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: loan.reason.split(' ').first, // Using first word of reason as category
          ),
          _DetailRow(
            icon: Icons.description_outlined,
            label: 'Reason',
            value: loan.reason,
          ),
          const SizedBox(height: 24),

          // Guarantors
          const Text(
            'Guarantors',
            style: AppTheme.title,
          ),
          const SizedBox(height: 8),
          if (loan.guarantorIds.isEmpty)
            const Text('No guarantors for this loan yet.')
          else
            Column(
              children: loan.guarantorIds.map((guarantorId) {
                return FutureBuilder<UserModel?>(
                  future: UserService.instance.getUserOnce(guarantorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const Text('Error loading guarantor');
                    }
                    final guarantor = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 20, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text('@${guarantor.username}', style: AppTheme.body),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Action Button (Fund)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => _FundLoanDialog(loan: loan, onFund: (loanId) { 
                    // This is a bit hacky, but passes the fund action back to the parent LendScreen
                    // A better approach for complex apps would be state management (Provider/Bloc)
                    (context as Element).findAncestorStateOfType<_LendScreenState>()?._fundLoan(loanId);
                  }),
                );
              },
              child: const Text('Fund Loan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.body,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FundLoanDialog extends StatelessWidget {
  final LoanModel loan;
  final Function(String) onFund;

  const _FundLoanDialog({
    required this.loan,
    required this.onFund,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Funding'),
      content: Text('Are you sure you want to fund this loan of ${loan.amount.toStringAsFixed(0)} ${loan.currency} for @${loan.borrowerUsername}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onFund(loan.id);
            Navigator.pop(context);
          },
          child: const Text('Confirm Fund'),
        ),
      ],
    );
  }
}


