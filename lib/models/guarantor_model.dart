class GuarantorRequestModel {
  final String id;
  final String loanId;
  final String borrowerId;
  final String guarantorId;
  final String status; // 'pending', 'confirmed', 'declined'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? note;

  GuarantorRequestModel({
    required this.id,
    required this.loanId,
    required this.borrowerId,
    required this.guarantorId,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
    this.note,
  });

  factory GuarantorRequestModel.fromMap(Map<String, dynamic> map) {
    return GuarantorRequestModel(
      id: map['id'] ?? '',
      loanId: map['loanId'] ?? '',
      borrowerId: map['borrowerId'] ?? '',
      guarantorId: map['guarantorId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
          : null,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanId': loanId,
      'borrowerId': borrowerId,
      'guarantorId': guarantorId,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
      'note': note,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isDeclined => status == 'declined';
}

