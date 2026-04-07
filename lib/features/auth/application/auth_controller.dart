import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum AuthRedirectOutcomeKind {
  redirecting,
  signedIn,
  alreadySignedIn,
  unsupported,
  error,
}

class AuthRedirectOutcome {
  const AuthRedirectOutcome._({required this.kind, this.user, this.message});

  const AuthRedirectOutcome.redirecting()
    : this._(kind: AuthRedirectOutcomeKind.redirecting);

  const AuthRedirectOutcome.signedIn(User user)
    : this._(kind: AuthRedirectOutcomeKind.signedIn, user: user);

  const AuthRedirectOutcome.alreadySignedIn(User user)
    : this._(kind: AuthRedirectOutcomeKind.alreadySignedIn, user: user);

  const AuthRedirectOutcome.unsupported(String message)
    : this._(kind: AuthRedirectOutcomeKind.unsupported, message: message);

  const AuthRedirectOutcome.error(String message)
    : this._(kind: AuthRedirectOutcomeKind.error, message: message);

  final AuthRedirectOutcomeKind kind;
  final User? user;
  final String? message;
}

class AuthController extends ChangeNotifier {
  AuthController({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      _available = true,
      _unavailableReason = null {
    final firebaseAuth = _auth!;
    _currentUser = firebaseAuth.currentUser;
    _subscription = firebaseAuth.userChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  AuthController.disabled(String reason)
    : _auth = null,
      _available = false,
      _unavailableReason = reason;

  final FirebaseAuth? _auth;
  final bool _available;
  final String? _unavailableReason;

  StreamSubscription<User?>? _subscription;
  User? _currentUser;

  bool get isAvailable => _available;
  String? get unavailableReason => _unavailableReason;
  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  String get accountLabel {
    final displayName = _currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = _currentUser?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'Google session';
  }

  Future<AuthRedirectOutcome> completeGoogleWebSignIn() async {
    final firebaseAuth = _auth;
    if (!_available || firebaseAuth == null) {
      return AuthRedirectOutcome.unsupported(
        _unavailableReason ??
            'Firebase web auth is not configured in this build.',
      );
    }

    if (!kIsWeb) {
      return const AuthRedirectOutcome.unsupported(
        'Native Google sign-in for future iOS builds is not wired yet.',
      );
    }

    try {
      final redirectResult = await firebaseAuth.getRedirectResult();
      if (redirectResult.user != null) {
        return AuthRedirectOutcome.signedIn(redirectResult.user!);
      }

      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        return AuthRedirectOutcome.alreadySignedIn(currentUser);
      }

      final provider = GoogleAuthProvider()
        ..setCustomParameters(<String, String>{'prompt': 'select_account'});
      await firebaseAuth.signInWithRedirect(provider);
      return const AuthRedirectOutcome.redirecting();
    } on FirebaseAuthException catch (error) {
      return AuthRedirectOutcome.error(_humanizeFirebaseError(error));
    } catch (error) {
      return AuthRedirectOutcome.error(error.toString());
    }
  }

  Future<void> signOut() async {
    final firebaseAuth = _auth;
    if (firebaseAuth == null) {
      return;
    }
    await firebaseAuth.signOut();
  }

  String _humanizeFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-blocked':
        return 'The browser blocked the Google sign-in window.';
      case 'popup-closed-by-user':
        return 'The Google sign-in window was closed before completion.';
      case 'unauthorized-domain':
        return 'The current web domain is not authorized in Firebase Auth yet.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Auth.';
      default:
        return error.message ?? error.code;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
