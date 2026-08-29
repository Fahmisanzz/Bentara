import '../models/user_model.dart';

abstract class AppAuthState {
  const AppAuthState();
}

class AuthInitial extends AppAuthState {
  const AuthInitial();
}

class AuthLoading extends AppAuthState {
  const AuthLoading();
}

class Authenticated extends AppAuthState {
  final UserModel user;
  const Authenticated(this.user);
}

class Unauthenticated extends AppAuthState {
  const Unauthenticated();
}

class AuthError extends AppAuthState {
  final String message;
  const AuthError(this.message);
}
