import 'package:flutter/material.dart';
import 'task_page.dart';
import 'register_page.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showPasswordDialog(String username) {
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  '${AppTranslations.getText(languageNotifier.value, 'welcome')}$username!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.getText(
                    languageNotifier.value,
                    'enter_password_to_continue',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.key_rounded,
                      color: Colors.blueAccent,
                    ),
                    hintText: AppTranslations.getText(
                      languageNotifier.value,
                      'password',
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _attemptLogin(context, username),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          AppTranslations.getText(
                            languageNotifier.value,
                            'cancel',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _attemptLogin(context, username),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          AppTranslations.getText(
                            languageNotifier.value,
                            'login_title',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showResetPasswordDialog(username);
                  },
                  child: Text(
                    AppTranslations.getText(
                      languageNotifier.value,
                      'forgot_password',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResetPasswordDialog(String username) {
    final formKey = GlobalKey<FormState>();
    String newPassword = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppTranslations.getText(
                      languageNotifier.value,
                      'reset_password_title',
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(dialogContext).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTranslations.getText(
                      languageNotifier.value,
                      'reset_password_desc',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    obscureText: true,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) => newPassword = value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.key_rounded,
                        color: Colors.blueAccent,
                      ),
                      hintText: AppTranslations.getText(
                        languageNotifier.value,
                        'new_password',
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.getText(
                          languageNotifier.value,
                          'please_enter_password',
                        );
                      }
                      if (value.length < 4) {
                        return AppTranslations.getText(
                          languageNotifier.value,
                          'password_short',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.key_rounded,
                        color: Colors.blueAccent,
                      ),
                      hintText: AppTranslations.getText(
                        languageNotifier.value,
                        'confirm_new_password',
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value != newPassword) {
                        return AppTranslations.getText(
                          languageNotifier.value,
                          'passwords_do_not_match',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppTranslations.getText(
                              languageNotifier.value,
                              'cancel',
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            await AuthService.resetPassword(
                              username,
                              newPassword,
                            );

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppTranslations.getText(
                                      languageNotifier.value,
                                      'password_reset_success',
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppTranslations.getText(
                              languageNotifier.value,
                              'reset_password_button',
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _attemptLogin(BuildContext dialogContext, String username) async {
    final password = _passwordController.text;

    if (AuthService.authenticate(username, password)) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      await _enterAsUser(username);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppTranslations.getText(languageNotifier.value, 'wrong_password'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enterAsUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark =
        prefs.getBool('isDarkMode_$username') ??
        (themeNotifier.value == ThemeMode.dark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => TaskPage(currentUser: username)),
    );
  }

  void _goToRegister() async {
    final createdUsername = await showDialog<String>(
      context: context,
      builder: (_) => const RegisterPage(),
    );

    if (!mounted) return;

    if (createdUsername != null && createdUsername.isNotEmpty) {
      await _enterAsUser(createdUsername);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = AuthService.registeredUsers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTranslations.getText(
                    languageNotifier.value,
                    'who_is_logging_in',
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                Wrap(
                  spacing: 20,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: [
                    ...users.map((username) {
                      return GestureDetector(
                        onTap: () => _showPasswordDialog(username),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blueAccent.withValues(
                                alpha: 0.2,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    GestureDetector(
                      onTap: _goToRegister,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.grey.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.add,
                              size: 50,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppTranslations.getText(
                              languageNotifier.value,
                              'add_account',
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
