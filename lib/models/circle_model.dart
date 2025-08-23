class CircleModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final double successRate;
  final int totalLoans;
  final DateTime createdAt;
  final String? description;

  CircleModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberIds = const [],
    this.successRate = 0.0,
    this.totalLoans = 0,
    required this.createdAt,
    this.description,
  });

  factory CircleModel.fromMap(Map<String, dynamic> map) {
    return CircleModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      successRate: (map['successRate'] ?? 0.0).toDouble(),
      totalLoans: map['totalLoans'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'successRate': successRate,
      'totalLoans': totalLoans,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'description': description,
    };
  }

  int get memberCount => memberIds.length + 1; // +1 for owner

  bool isOwner(String userId) => ownerId == userId;
  bool isMember(String userId) => memberIds.contains(userId) || isOwner(userId);
}

