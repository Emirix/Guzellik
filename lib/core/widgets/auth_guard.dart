import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/auth_required_screen.dart';

/// Auth guard widget that protects routes requiring authentication
///
/// Wraps protected content and shows AuthRequiredScreen if user is not authenticated
class AuthGuard extends StatelessWidget {
  /// The widget to show when user is authenticated
  final Widget child;

  /// Description of what feature requires auth (e.g., "Profilim", "Favoriler")
  final String requiredFor;

  /// Path to redirect to after successful login
  final String? redirectPath;

  const AuthGuard({
    super.key,
    required this.child,
    required this.requiredFor,
    this.redirectPath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAuth = authProvider.isAuthenticated;
        print(
          '🛡️ AuthGuard check for "$requiredFor" - isAuthenticated: $isAuth',
        );

        if (isAuth) {
          return child;
        }

        return AuthRequiredScreen(
          requiredFor: requiredFor,
          redirectPath: redirectPath,
        );
      },
    );
  }
}
