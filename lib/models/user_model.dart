class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final double trustScore;
  final String kycStatus; // 'not_started', 'in_progress', 'verified'
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> circleIds; // list of circles the user joined
  final String? location;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.trustScore = 0.0,
    this.kycStatus = 'not_started',
    required this.createdAt,
    required this.updatedAt,
    this.circleIds = const [], // default empty list
    this.location,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      avatarUrl: map['avatarUrl'],
      trustScore: (map['trustScore'] ?? 0.0).toDouble(),
      kycStatus: map['kycStatus'] ?? 'not_started',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      circleIds: List<String>.from(map['circleIds'] ?? []),
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'trustScore': trustScore,
      'kycStatus': kycStatus,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'circleIds': circleIds,
      'location': location,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    double? trustScore,
    String? kycStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? circleIds,
    String? location,

  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      trustScore: trustScore ?? this.trustScore,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      circleIds: circleIds ?? this.circleIds,
      location: location ?? this.location,
    );
  }
}

