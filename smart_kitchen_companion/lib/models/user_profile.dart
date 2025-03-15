class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> followers;
  final List<String> following;
  final String tier;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    List<String>? followers,
    List<String>? following,
    String? tier,
  })  : followers = followers ?? [],
        following = following ?? [],
        tier = tier ?? 'free';

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      tier: data['tier'] ?? 'free',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
      'tier': tier,
    };
  }
}
