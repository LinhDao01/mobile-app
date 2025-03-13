class User {
  final String id;
  final String? username;
  final String email;
  final String? name;
  final String? avatar;

  User({
    required this.id,
    this.username,
    required this.email,
    this.name,
    this.avatar,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // print("Raw JSON: $json");
    // print("ID: ${json['id']}, Type: ${json['id'].runtimeType}");
    // print("Email: ${json['email']}, Type: ${json['email'].runtimeType}");
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? 'unknown',
      email: json['email'] ?? '',
      name: json['name'] ?? 'unknown',
      avatar: json['avatar'] ?? '',
    );
  }
}
