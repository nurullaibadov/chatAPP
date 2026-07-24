import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Failed to get user details after sign up.');

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      statusMessage: 'Hey there! I am using ChatApp.',
      isOnline: true,
      createdAt: DateTime.now(),
    );

    await _firestoreService.saveUser(userModel);
    return userModel;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    // Update online status
    await _firestoreService.updateUserStatus(user.uid, true);
    return await _firestoreService.getUser(user.uid);
  }

  Future<UserModel?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null || credential.user == null) return null;

    final user = credential.user!;
    UserModel? existingUser = await _firestoreService.getUser(user.uid);

    if (existingUser == null) {
      existingUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Google User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        statusMessage: 'Hey there! I am using ChatApp.',
        isOnline: true,
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveUser(existingUser);
    } else {
      await _firestoreService.updateUserStatus(user.uid, true);
    }

    return existingUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.updateUserStatus(uid, false);
    }
    await _authService.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.updateUserStatus(uid, false);
    }
    await _authService.deleteAccount();
  }
}
