class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneCountryCode,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'student',
    this.isActive = true,
  });

  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneCountryCode;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final bool isActive;

  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'] as String,
      userName: (json['user_name'] as String?)?.trim() ?? '',
      firstName: (json['first_name'] as String?)?.trim() ?? '',
      lastName: (json['last_name'] as String?)?.trim() ?? '',
      email: json['email'] as String?,
      phoneCountryCode: json['phone_country_code'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: (json['role'] as String?)?.trim().isNotEmpty == true
          ? (json['role'] as String).trim()
          : 'student',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    if (userName.isNotEmpty) return userName;
    return email ?? '';
  }
}
