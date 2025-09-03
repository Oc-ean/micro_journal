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

      await _notificationService.initialize();

      final String? savedToken = await AppPreferences.getCurrentDeviceToken();
      final bool hasExistingToken = savedToken != null && savedToken.isNotEmpty;

      final String? newToken = hasExistingToken
          ? null
          : await _notificationService.getCurrentToken();

      final existingUser = await _userRepository.getUserData(firebaseUser.uid);

      UserModel userModel;
      if (existingUser != null) {
        if (!hasExistingToken && newToken != null && newToken.isNotEmpty) {
          await _notificationService.assignTokenToUser(firebaseUser.uid);
          await AppPreferences.setCurrentDeviceToken(newToken);
        }
        userModel = existingUser;
      } else {
        userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.displayName ?? 'Unknown User',
          avatarUrl: firebaseUser.photoURL ?? '',
          followers: [],
          following: [],
          fcmTokens:
              (!hasExistingToken && newToken != null && newToken.isNotEmpty)
                  ? [newToken]
                  : [],
        );
        await _userRepository.createOrUpdateUser(userModel);

        if (!hasExistingToken && newToken != null && newToken.isNotEmpty) {
          await AppPreferences.setCurrentDeviceToken(newToken);
        }
      }

      if (!hasExistingToken && (newToken == null || newToken.isEmpty)) {
        await _initializeNotifications(firebaseUser.uid);
      }

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
      final String? token = await _notificationService.getCurrentToken();
      if (token != null && token.isNotEmpty) {
        await _notificationService.assignTokenToUser(userId);
        await AppPreferences.setCurrentDeviceToken(token);
        logman.info('Notifications initialized for user: $userId');
      }
    } catch (e) {
      logman.error('Failed to initialize notifications: $e');
    }
  }

  Future<void> refreshFCMToken() async {
    try {
      final user = currentUser;
      if (user != null) {
        final String? savedToken = await AppPreferences.getCurrentDeviceToken();
        final String? currentToken =
            await _notificationService.getCurrentToken();

        if (currentToken != null &&
            currentToken.isNotEmpty &&
            currentToken != savedToken) {
          await _notificationService.assignTokenToUser(user.uid);
          await AppPreferences.setCurrentDeviceToken(currentToken);
          logman.info('FCM token refreshed for user: ${user.uid}');
        }
      }
    } catch (e) {
      logman.error('Failed to refresh FCM token: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final user = currentUser;

      if (user != null) {
        final String? savedToken = await AppPreferences.getCurrentDeviceToken();
        if (savedToken != null) {
          await _userRepository.removeFCMToken(user.uid, savedToken);
        }

        await AppPreferences.setCurrentDeviceToken('');
      }

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      logman.info('User signed out successfully');
    } catch (e) {
      logman.error('Failed to sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> onTokenRefresh(String newToken) async {
    try {
      final user = currentUser;
      if (user != null) {
        final String? savedToken = await AppPreferences.getCurrentDeviceToken();

        if (newToken != savedToken) {
          if (savedToken != null) {
            await _userRepository.removeFCMToken(user.uid, savedToken);
          }

          await _notificationService.assignTokenToUser(user.uid);
          await AppPreferences.setCurrentDeviceToken(newToken);

          logman
              .info('FCM token refreshed automatically for user: ${user.uid}');
        }
      }
    } catch (e) {
      logman.error('Failed to handle token refresh: $e');
    }
  }
}
