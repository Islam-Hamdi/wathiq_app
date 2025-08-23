import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/guarantor_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/guarantor_model.dart';
import '../../models/loan_model.dart';
import '../../services/loan_service.dart';

class GuarantorScreen extends StatefulWidget {
  const GuarantorScreen({super.key});

  @override
  State<GuarantorScreen> createState() => _GuarantorScreenState();
}

class _GuarantorScreenState extends State<GuarantorScreen> {
  bool _isLoading = false;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _handleGuarantorRequest(String requestId, String status) async {
    setState(() => _isLoading = true);
    try {
      final guarantorService = GuarantorService();
      await guarantorService.updateGuarantorRequestStatus(requestId, status);
      _showSnackBar(
        'Guarantor request ${status.toLowerCase()} successfully!',
        AppTheme.successGreen,
      );
    } catch (e) {
      _showSnackBar(
        'Failed to ${status.toLowerCase()} request: ${e.toString()}',
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.uid;
    final guarantorService = GuarantorService();

    if (currentUserId == null) {
      return const Center(child: Text('Please log in to view guarantor requests.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guarantor Requests'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Requests Section
            const Text(
              'Pending Confirmation',
              style: AppTheme.h2,
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<GuarantorRequest>>(
              stream: guarantorService.getUserGuarantorRequestsStream(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final pendingRequests = snapshot.data?.where((req) => req.status == 'pending').toList() ?? [];

                if (pendingRequests.isEmpty) {
                  return const Text('No pending guarantor requests.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
                    return FutureBuilder<LoanModel?>(
                      future: LoanService().getLoanStream(request.loanId).first,
                      builder: (context, loanSnapshot) {
                        if (loanSnapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (loanSnapshot.hasError || !loanSnapshot.hasData || loanSnapshot.data == null) {
                          return const Text('Error loading loan details');
                        }
                        final loan = loanSnapshot.data!;
                        return _GuarantorRequestCard(
                          request: request,
                          loan: loan,
                          onConfirm: () => _handleGuarantorRequest(request.id, 'confirmed'),
                          onDecline: () => _handleGuarantorRequest(request.id, 'declined'),
                          isLoading: _isLoading,
                        );
                      },
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Confirmed Guarantees Section
            const Text(
              'Confirmed Guarantees',
              style: AppTheme.h2,
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<GuarantorRequest>>(
              stream: guarantorService.getUserGuarantorRequestsStream(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final confirmedRequests = snapshot.data?.where((req) => req.status == 'confirmed').toList() ?? [];

                if (confirmedRequests.isEmpty) {
                  return const Text('No confirmed guarantees.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: confirmedRequests.length,
                  itemBuilder: (context, index) {
                    final request = confirmedRequests[index];
                    return FutureBuilder<LoanModel?>(
                      future: LoanService().getLoanStream(request.loanId).first,
                      builder: (context, loanSnapshot) {
                        if (loanSnapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (loanSnapshot.hasError || !loanSnapshot.hasData || loanSnapshot.data == null) {
                          return const Text('Error loading loan details');
                        }
                        final loan = loanSnapshot.data!;
                        return _ConfirmedGuaranteeCard(
                          request: request,
                          loan: loan,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GuarantorRequestCard extends StatelessWidget {
  final GuarantorRequest request;
  final LoanModel loan;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final bool isLoading;

  const _GuarantorRequestCard({
    required this.request,
    required this.loan,
    required this.onConfirm,
    required this.onDecline,
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

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        loan.borrowerUsername,
                        style: AppTheme.title,
                      ),
                      Text(
                        '@${loan.borrowerUsername} • ${_timeAgo(request.requestedAt)}',
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
                    color: AppTheme.warningAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.warningAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: AppTheme.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${loan.amount.toStringAsFixed(0)} ${loan.currency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Reason
            const Text(
              'Reason:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loan.reason,
              style: AppTheme.body,
            ),
            const SizedBox(height: 12),
            
            // Other Guarantors (simplified for now, would need to fetch user details)
            if (loan.guarantorIds.isNotEmpty) ...[
              const Text(
                'Other Guarantors:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: loan.guarantorIds.map((guarantorId) {
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '@${guarantor.username}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onDecline,
                    icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.close),
                    label: isLoading ? const Text('Declining...') : const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onConfirm,
                    icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.verified_user),
                    label: isLoading ? const Text('Confirming...') : const Text('Confirm'),
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

class _ConfirmedGuaranteeCard extends StatelessWidget {
  final GuarantorRequest request;
  final LoanModel loan;

  const _ConfirmedGuaranteeCard({
    required this.request,
    required this.loan,
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

  @override
  Widget build(BuildContext context) {
    final isCompleted = loan.status == 'completed';
    // For simplicity, assuming repaidAmount is 0 if not completed, or full amount if completed
    final repaidAmount = isCompleted ? loan.amount : 0.0; 
    final progressPercentage = isCompleted ? 1.0 : 0.0; // Simplified progress
    
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
                      Text(
                        loan.borrowerUsername,
                        style: AppTheme.title,
                      ),
                      Text(
                        '@${loan.borrowerUsername} • Confirmed ${_timeAgo(request.updatedAt ?? request.requestedAt)}',
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
                    color: AppTheme.getStatusColor(loan.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loan.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getStatusColor(loan.status),
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
                        '${loan.amount.toStringAsFixed(0)} ${loan.currency}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Guaranteed Amount',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
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
                      'Repaid: ${repaidAmount.toStringAsFixed(0)}',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
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
            ],
          ],
        ),
      ),
    );
  }
}


