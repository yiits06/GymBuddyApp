class UserModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? experienceLevel;
  final List<String> goals;
  final String? gymId;
  final int? age;
  final int streakCount;

  UserModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.experienceLevel,
    required this.goals,
    this.gymId,
    this.age,
    this.streakCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'İsimsiz Sporcu',
      avatarUrl: json['avatar_url'] as String?,
      experienceLevel: json['experience_level'] as String?,
      goals: List<String>.from(json['goals'] ?? []),
      gymId: json['gym_id'] as String?,
      age: _readAge(json),
      streakCount: json['streak_count'] as int? ?? 0,
    );
  }

  static int? _readAge(Map<String, dynamic> json) {
    final ageValue = json['age'];
    if (ageValue is int) return ageValue;
    if (ageValue is String) return int.tryParse(ageValue);

    final birthDateValue = json['birth_date'] ?? json['date_of_birth'];
    if (birthDateValue is! String || birthDateValue.isEmpty) return null;

    final birthDate = DateTime.tryParse(birthDateValue);
    if (birthDate == null) return null;

    final today = DateTime.now();
    var calculatedAge = today.year - birthDate.year;
    final hasBirthdayPassed =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);

    if (!hasBirthdayPassed) calculatedAge--;
    return calculatedAge >= 0 ? calculatedAge : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'experience_level': experienceLevel,
      'goals': goals,
      'gym_id': gymId,
      'age': age,
      'streak_count': streakCount,
    };
  }
}
