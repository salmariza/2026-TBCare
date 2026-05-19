class SessionService {
  static final SessionService instance = SessionService._init();
  SessionService._init();

  int? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;

  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;

  void setUser(int id, String name, String email) {
    _currentUserId = id;
    _currentUserName = name;
    _currentUserEmail = email;
  }

  void clear() {
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
  }

  bool get isLoggedIn => _currentUserId != null;
}
