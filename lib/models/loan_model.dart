class LoanModel {
  final String id;
  final String borrowerId;
  final String borrowerUsername; // <-- Add this
  final String? lenderId;
  final double amount;
  final String currency;
  final String category;
  final String reason;
  final String status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? fundedAt; // <- add this
  final List<String> guarantorIds;
  final int guarantorsRequired;
  final double repaidAmount;
  final List<RepaymentModel> repayments;

  LoanModel({
    required this.id,
    required this.borrowerId,
    required this.borrowerUsername, // <-- Add this
    this.lenderId,
    required this.amount,
    this.currency = 'QAR',
    required this.category,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.dueDate,
    this.fundedAt, // <- add this
    this.guarantorIds = const [],
    this.guarantorsRequired = 1,
    this.repaidAmount = 0.0,
    this.repayments = const [],
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      borrowerId: map['borrowerId'] ?? '',
      borrowerUsername: map['borrowerUsername'] ?? '', // <-- Add this
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
      fundedAt: map['fundedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fundedAt'])
          : null, // <- add this
      guarantorIds: List<String>.from(map['guarantorIds'] ?? []),
      guarantorsRequired: map['guarantorsRequired'] ?? 1,
      repaidAmount: (map['repaidAmount'] ?? 0.0).toDouble(),
      repayments: (map['repayments'] as List<dynamic>?)
              ?.map((e) => RepaymentModel.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'borrowerId': borrowerId,
      'borrowerUsername': borrowerUsername, // <-- Add this
      'lenderId': lenderId,
      'amount': amount,
      'currency': currency,
      'category': category,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'fundedAt': fundedAt?.millisecondsSinceEpoch, // <- add this
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

extension LoanModelCopy on LoanModel {
  LoanModel copyWith({
    String? id,
    String? borrowerId,
    String? borrowerUsername, // <-- Add this
    String? lenderId,
    double? amount,
    String? currency,
    String? category,
    String? reason,
    String? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? fundedAt,
    List<String>? guarantorIds,
    int? guarantorsRequired,
    double? repaidAmount,
    List<RepaymentModel>? repayments,
  }) {
    return LoanModel(
      id: id ?? this.id,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerUsername: borrowerUsername ?? this.borrowerUsername, // <-- Add this
      lenderId: lenderId ?? this.lenderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      fundedAt: fundedAt ?? this.fundedAt, // <- add this
      guarantorIds: guarantorIds ?? this.guarantorIds,
      guarantorsRequired: guarantorsRequired ?? this.guarantorsRequired,
      repaidAmount: repaidAmount ?? this.repaidAmount,
      repayments: repayments ?? this.repayments,
    );
  }
}


