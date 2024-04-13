
class UserModel {
  String uid;
  String name;
  String email;
  String password;
  String imageProfile;

  UserModel(
    this.uid,
    this.name,
    this.email,
    this.password,
    {this.imageProfile = "",}  
   );

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "password": password,
      "imageProfile": imageProfile,
    };
  }
} 