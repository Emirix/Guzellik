import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/common/custom_header.dart';

/// Profile screen - User profile and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'Profil',
            subtitle: 'Hesap ayarları',
            actions: [
              Consumer<AppStateProvider>(
                builder: (context, appState, _) {
                  return IconButton(
                    icon: Icon(
                      appState.isDarkMode 
                          ? Icons.light_mode 
                          : Icons.dark_mode,
                    ),
                    onPressed: () => appState.toggleTheme(),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profil Ekranı',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profil bilgileriniz burada görünecek',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
