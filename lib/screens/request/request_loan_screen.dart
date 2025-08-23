import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/loan_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/loan_model.dart';
import '../../models/user_model.dart';

class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _guarantorController = TextEditingController();
  
  String _selectedCurrency = 'QAR';
  final List<String> _guarantorUsernames = [];
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _guarantorController.dispose();
    super.dispose();
  }

  Future<void> _addGuarantor() async {
    if (_guarantorController.text.trim().isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      final username = _guarantorController.text.trim();
      final userService = UserService.instance;
      final user = await userService.getUserByUsername(username);

      if (user != null) {
        if (!_guarantorUsernames.contains(username)) {
          setState(() {
            _guarantorUsernames.add(username);
            _guarantorController.clear();
          });
        } else {
          _showSnackBar('Guarantor already added', Colors.orange);
        }
      } else {
        _showSnackBar('User @$username not found', Colors.red);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeGuarantor(int index) {
    setState(() {
      _guarantorUsernames.removeAt(index);
    });
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_guarantorUsernames.isEmpty) {
      _showSnackBar('Please add at least one guarantor', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loanService = LoanService();
      final userService = UserService.instance;

      final currentUser = authService.currentUser;
      if (currentUser == null) {
        _showSnackBar('You must be logged in to request a loan', Colors.red);
        return;
      }

      final borrower = await userService.getUserOnce(currentUser.uid);
      if (borrower == null) {
        _showSnackBar('Borrower data not found', Colors.red);
        return;
      }

      final List<String> guarantorIds = [];
      for (String username in _guarantorUsernames) {
        final guarantorUser = await userService.getUserByUsername(username);
        if (guarantorUser != null) {
          guarantorIds.add(guarantorUser.id);
        } else {
          _showSnackBar('Guarantor @$username not found. Please remove and re-add.', Colors.red);
          setState(() => _isLoading = false);
          return;
        }
      }

      final loan = LoanModel(
        id: FirebaseService.instance.generateId(),
        borrowerId: currentUser.uid,
        borrowerUsername: borrower.username,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        reason: _reasonController.text.trim(),
        status: 'pending', // Initial status
        guarantorIds: guarantorIds,
        requestedAt: DateTime.now(),
        dueDate: _dueDate,
      );

      await loanService.createLoanRequest(loan);

      if (mounted) {
        _showSnackBar('Loan request submitted successfully!', AppTheme.successGreen);
        // Clear form
        _formKey.currentState!.reset();
        _amountController.clear();
        _reasonController.clear();
        _guarantorUsernames.clear();
        _dueDate = null;
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to submit loan request: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Loan'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryBlueLight.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add_box_outlined,
                      color: AppTheme.primaryBlue,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Request a Loan',
                      style: AppTheme.h2,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Get funding from your trusted community',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Loan Amount
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Loan Amount',
                        hintText: 'Enter amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter loan amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                      ),
                      items: ['QAR', 'USD', 'EUR'].map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Reason for Loan
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Loan',
                  hintText: 'Explain why you need this loan',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason for the loan';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Due Date
              InkWell(
                onTap: _selectDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date (Optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _dueDate != null
                        ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                        : 'Select due date',
                    style: TextStyle(
                      color: _dueDate != null 
                          ? AppTheme.textPrimary 
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Guarantors Section
              const Text(
                'Guarantors',
                style: AppTheme.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add 1-3 trusted people who can vouch for you',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 12),
              
              // Add Guarantor
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _guarantorController,
                      decoration: const InputDecoration(
                        labelText: 'Guarantor Username',
                        hintText: '@username',
                        prefixIcon: Icon(Icons.person_add_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _addGuarantor,
                          child: const Text('Add'),
                        ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Guarantor List
              if (_guarantorUsernames.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Guarantors (${_guarantorUsernames.length}/3)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_guarantorUsernames.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user,
                                size: 16,
                                color: AppTheme.successGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '@${_guarantorUsernames[index]}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.red,
                                onPressed: () => _removeGuarantor(index),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Request'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


