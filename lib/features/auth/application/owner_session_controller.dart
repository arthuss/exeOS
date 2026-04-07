import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'auth_controller.dart';

enum OwnerSessionStateKind { disabled, signedOut, resolving, linked, error }

class OwnerSessionSnapshot {
  const OwnerSessionSnapshot({
    required this.ownerId,
    required this.authUid,
    required this.provider,
    required this.identityKey,
    required this.email,
    required this.displayName,
    required this.wasCreated,
  });

  factory OwnerSessionSnapshot.fromMap(Map<dynamic, dynamic> map) {
    String readString(String key, {String fallback = ''}) {
      final value = map[key];
      return value is String ? value : fallback;
    }

    String? readNullableString(String key) {
      final value = map[key];
      if (value is! String) {
        return null;
      }
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return OwnerSessionSnapshot(
      ownerId: readString('ownerId'),
      authUid: readString('authUid'),
      provider: readString('provider'),
      identityKey: readString('identityKey'),
      email: readNullableString('email'),
      displayName: readNullableString('displayName'),
      wasCreated: map['wasCreated'] == true,
    );
  }

  final String ownerId;
  final String authUid;
  final String provider;
  final String identityKey;
  final String? email;
  final String? displayName;
  final bool wasCreated;
}

class OwnerSessionController extends ChangeNotifier {
  OwnerSessionController({
    required AuthController authController,
    FirebaseFunctions? functions,
  }) : _authController = authController,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west3') {
    _authController.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  final AuthController _authController;
  final FirebaseFunctions _functions;

  OwnerSessionStateKind _state = OwnerSessionStateKind.signedOut;
  OwnerSessionSnapshot? _snapshot;
  String? _errorMessage;
  String? _resolvedAuthUid;
  int _resolveGeneration = 0;

  OwnerSessionStateKind get state => _state;
  OwnerSessionSnapshot? get snapshot => _snapshot;
  String? get errorMessage => _errorMessage;
  bool get isLinked =>
      _state == OwnerSessionStateKind.linked && _snapshot != null;
  bool get isResolving => _state == OwnerSessionStateKind.resolving;
  bool get isDisabled => _state == OwnerSessionStateKind.disabled;
  bool get hasError =>
      _state == OwnerSessionStateKind.error && _errorMessage != null;

  Future<void> refresh() => _resolve(force: true);

  void _handleAuthChanged() {
    _resolve(force: false);
  }

  Future<void> _resolve({required bool force}) async {
    if (!_authController.isAvailable) {
      _state = OwnerSessionStateKind.disabled;
      _snapshot = null;
      _errorMessage = _authController.unavailableReason;
      _resolvedAuthUid = null;
      notifyListeners();
      return;
    }

    final currentUser = _authController.currentUser;
    final authUid = currentUser?.uid;
    if (authUid == null) {
      _state = OwnerSessionStateKind.signedOut;
      _snapshot = null;
      _errorMessage = null;
      _resolvedAuthUid = null;
      notifyListeners();
      return;
    }

    if (!force &&
        _resolvedAuthUid == authUid &&
        (_state == OwnerSessionStateKind.linked ||
            _state == OwnerSessionStateKind.resolving)) {
      return;
    }

    _resolvedAuthUid = authUid;
    final generation = ++_resolveGeneration;
    _state = OwnerSessionStateKind.resolving;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _functions
          .httpsCallable('ownerResolveSession')
          .call();
      if (!_isCurrent(authUid, generation)) {
        return;
      }
      final raw = response.data;
      if (raw is! Map<dynamic, dynamic>) {
        throw StateError('ownerResolveSession returned no payload.');
      }
      _snapshot = OwnerSessionSnapshot.fromMap(raw);
      _state = OwnerSessionStateKind.linked;
      _errorMessage = null;
      notifyListeners();
    } on FirebaseFunctionsException catch (error) {
      if (!_isCurrent(authUid, generation)) {
        return;
      }
      _snapshot = null;
      _state = OwnerSessionStateKind.error;
      _errorMessage = _humanizeFunctionsError(error);
      notifyListeners();
    } catch (error) {
      if (!_isCurrent(authUid, generation)) {
        return;
      }
      _snapshot = null;
      _state = OwnerSessionStateKind.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  bool _isCurrent(String authUid, int generation) {
    return _authController.currentUser?.uid == authUid &&
        _resolveGeneration == generation;
  }

  String _humanizeFunctionsError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'The Firebase session is missing or expired.';
      case 'failed-precondition':
        return error.message ??
            'The current auth provider is not ready for canonical owner resolution yet.';
      case 'permission-denied':
        return 'The current session is not allowed to resolve an owner.';
      case 'unavailable':
        return 'The owner resolution backend is temporarily unavailable.';
      default:
        return error.message ?? error.code;
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthChanged);
    super.dispose();
  }
}
