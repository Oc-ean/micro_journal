import 'package:firebase_auth/firebase_auth.dart';

Exception handleFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'account-exists-with-different-credential':
      return Exception('An account already exists with a different credential');
    case 'invalid-credential':
      return Exception('The credential is invalid or expired');
    case 'operation-not-allowed':
      return Exception('Google sign-in is not enabled');
    case 'user-disabled':
      return Exception('This user account has been disabled');
    case 'user-not-found':
      return Exception('No user found with this credential');
    case 'wrong-password':
      return Exception('Wrong password provided');
    case 'invalid-verification-code':
      return Exception('Invalid verification code');
    case 'invalid-verification-id':
      return Exception('Invalid verification ID');
    default:
      return Exception('Authentication failed: ${e.message}');
  }
}
