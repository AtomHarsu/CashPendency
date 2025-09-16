import 'package:hive/hive.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(reader.readString(), reader.readString(), reader.readString());
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.email);
    writer.writeString(obj.password);
    writer.writeString(obj.accestoken);
  }
}

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String password;

  @HiveField(2)
  String accestoken;

  User(this.email, this.password, this.accestoken);
}

Future<void> storeUserData(
  String email,
  String password,
  String accestoken,
) async {
  final userBox = await Hive.openBox<User>('userBox');
  final user = User(email, password, accestoken);
  userBox.add(user);
}

Future<User?> getUserData() async {
  final userBox = await Hive.openBox<User>('userBox');
  if (userBox.isNotEmpty) {
    return userBox.getAt(0);
  }
  return null;
}

Future<void> logout() async {
  final userBox = await Hive.openBox<User>('userBox');
  await userBox.clear();
}
