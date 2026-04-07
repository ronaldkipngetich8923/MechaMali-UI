class UserModel {
  final String id;
  final String name;
  final String phone;
  final bool isVip;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isVip,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        isVip: json['isVip'] as bool? ?? false,
      );
}
