import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/provider/auth_provider.dart';
import 'package:storyapp/common.dart';

class LoginScreen extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LoginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoadingLogin = authProvider.isLoadingLogin;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.titleLogin,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      AppLocalizations.of(context)!.bodyLogin,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  bottom: 20,
                  top: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.emailForm,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.emailFormValidaton1;
                          } else if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value)) {
                            return AppLocalizations.of(
                              context,
                            )!.emailFormValidaton2;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.passwordForm,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 8) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordFormValidation;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final result = await authProvider.login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authProvider.message ??
                                      (result
                                          ? AppLocalizations.of(
                                            context,
                                          )!.snackBarLoginSuccess
                                          : AppLocalizations.of(
                                            context,
                                          )!.snackBarLoginFailure),
                                ),
                              ),
                            );

                            if (result) {
                              widget.onLogin();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child:
                            isLoadingLogin
                                ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                                : Text(
                                  AppLocalizations.of(context)!.loginBtn,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.toRegister),

                  TextButton(
                    onPressed: () {
                      widget.onRegister();
                    },
                    child: Text(AppLocalizations.of(context)!.registerBtn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
