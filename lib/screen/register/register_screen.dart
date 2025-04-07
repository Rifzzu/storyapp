import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/provider/auth_provider.dart';
import 'package:storyapp/common.dart';

class RegisterScreen extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;

  const RegisterScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<RegisterScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoadingRegister = authProvider.isLoadingRegister;

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
                      AppLocalizations.of(context)!.titleRegister,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      AppLocalizations.of(context)!.bodyRegister,
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
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.nameForm,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.nameFormValidaton1;
                          } else {
                            return null;
                          }
                        },
                      ),
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
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final result = await authProvider.register(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (!context.mounted) return;

                            if (!result['error']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authProvider.message ??
                                        AppLocalizations.of(
                                          context,
                                        )!.snackBarRegisterSuccess,
                                  ),
                                ),
                              );
                              widget.onLogin();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authProvider.message ??
                                        AppLocalizations.of(
                                          context,
                                        )!.snackBarRegisterFailure,
                                  ),
                                ),
                              );
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
                            isLoadingRegister
                                ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                                : Text(
                                  AppLocalizations.of(context)!.registerBtn,
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
                  Text(AppLocalizations.of(context)!.toLogin),
                  TextButton(
                    onPressed: () {
                      widget.onLogin();
                    },
                    child: Text(AppLocalizations.of(context)!.loginBtn),
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
