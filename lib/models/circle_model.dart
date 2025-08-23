class CircleModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final double trustScore;
  final int totalLoans;
  final DateTime createdAt;
  final String? description;

  CircleModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberIds = const [],
    this.trustScore = 0.0,
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
      trustScore: (map['trustScore'] ?? 0.0).toDouble(),
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
      'trustScore': trustScore,
      'totalLoans': totalLoans,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'description': description,
    };
  }

  int get memberCount => memberIds.length + 1; // +1 for owner

  bool isOwner(String userId) => ownerId == userId;
  bool isMember(String userId) => memberIds.contains(userId) || isOwner(userId);

    CircleModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? memberIds,
    double? trustScore,
    int? totalLoans,
    DateTime? createdAt,
    String? description,
  }) {
    return CircleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      trustScore: trustScore ?? this.trustScore,
      totalLoans: totalLoans ?? this.totalLoans,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

}

