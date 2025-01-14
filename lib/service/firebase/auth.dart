import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStatechanges => _firebaseAuth.authStateChanges();

  Future<void> loginwithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Create USER WITH EMAIL-PASSWORD
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName('$firstName $lastName');
        await user.reload();
        user = _firebaseAuth.currentUser;

        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email,
          'photoUrl': user.photoURL ?? 'empty.jpg',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }
}
