import 'package:baberbookingapp/core/data/firebase_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseRemoteDS<UserModel> _remoteDS;
  final FirebaseAuth _auth;

  UserRepository()
      : _remoteDS = FirebaseRemoteDS<UserModel>(
          collectionName: 'users',
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (user) => user.toFirestore(),
        ),
        _auth = FirebaseAuth.instance;

  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Create auth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );

    // Save to Firestore using FirebaseRemoteDS
    await _remoteDS.update(user.id, user);

    // Update auth profile
    await userCredential.user!.updateDisplayName(name);
    await userCredential.user!.reload();

    return user;
  }

  Stream<UserModel?> watchCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _remoteDS.watchById(user.uid);
  }
}
