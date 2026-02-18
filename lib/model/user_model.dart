class UserModel {
  final String uid;
  final String? username;
  final String? email;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    this.username,
    this.email,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: (data['uid'] ?? '') as String,
      username: data['username'] as String?,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
