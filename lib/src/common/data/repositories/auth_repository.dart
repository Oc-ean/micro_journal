import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:micro_journal/src/common/common.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;
  final NotificationService _notificationService;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required UserRepository userRepository,
    required NotificationService notificationService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _userRepository = userRepository,
        _notificationService = notificationService;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        logman.error('Failed to authenticate with Firebase');
        throw Exception('Failed to authenticate with Firebase');
      }

      final token = await _notificationService.getCurrentToken();

      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: firebaseUser.displayName ?? 'Unknown User',
        avatarUrl: firebaseUser.photoURL ?? '',
        followers: [],
        following: [],
        fcmTokens: [token!],
      );

      await _userRepository.createOrUpdateUser(userModel);
      await _initializeNotifications(firebaseUser.uid);

      return userModel;
    } on FirebaseAuthException catch (e) {
      logman.info('FirebaseAuthException: $e');
      throw handleFirebaseAuthException(e);
    } catch (e) {
      logman.error('Failed to sign in with Google: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> _initializeNotifications(String userId) async {
    try {
      await _notificationService.initialize();

      final fcmToken = await _notificationService.getCurrentToken();
      if (fcmToken != null) {
        await _userRepository.updateFCMToken(userId, fcmToken);
      }
    } catch (e) {
      logman.error('Failed to initialize notifications: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
