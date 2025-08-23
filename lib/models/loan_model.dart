class LoanModel {
  final String id;
  final String borrowerId;
  final String? lenderId;
  final double amount;
  final String currency;
  final String category;
  final String reason;
  final String status; // 'pending', 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> guarantorIds;
  final int guarantorsRequired;
  final double repaidAmount;
  final List<RepaymentModel> repayments;

  LoanModel({
    required this.id,
    required this.borrowerId,
    this.lenderId,
    required this.amount,
    this.currency = 'QAR',
    required this.category,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.dueDate,
    this.guarantorIds = const [],
    this.guarantorsRequired = 1,
    this.repaidAmount = 0.0,
    this.repayments = const [],
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      borrowerId: map['borrowerId'] ?? '',
      lenderId: map['lenderId'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'QAR',
      category: map['category'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      guarantorIds: List<String>.from(map['guarantorIds'] ?? []),
      guarantorsRequired: map['guarantorsRequired'] ?? 1,
      repaidAmount: (map['repaidAmount'] ?? 0.0).toDouble(),
      repayments: (map['repayments'] as List<dynamic>?)
          ?.map((e) => RepaymentModel.fromMap(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'borrowerId': borrowerId,
      'lenderId': lenderId,
      'amount': amount,
      'currency': currency,
      'category': category,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'guarantorIds': guarantorIds,
      'guarantorsRequired': guarantorsRequired,
      'repaidAmount': repaidAmount,
      'repayments': repayments.map((e) => e.toMap()).toList(),
    };
  }

  double get progressPercentage {
    if (amount == 0) return 0.0;
    return (repaidAmount / amount).clamp(0.0, 1.0);
  }

  bool get isFullyRepaid => repaidAmount >= amount;
}

class RepaymentModel {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  RepaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  factory RepaymentModel.fromMap(Map<String, dynamic> map) {
    return RepaymentModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }
}

