class User {
  final int id;
  final String name;
  final String email;
  final String? profilePicture; // Make this nullable
  final String role; // Make this nullable

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '', // Provide default value if null
      email: json['email'] ?? '', // Provide default value if null
      profilePicture: json['profile_picture'], // Can be null
      role: json['role'] ?? 'pengurus',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'role': role,
    };
  }
}
