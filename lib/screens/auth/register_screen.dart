import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().isEnglish 
                ? 'Please accept the terms and conditions'
                : 'እባክዎ ውሎችን እና ሁኔታዎችን ይቀበሉ',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  languageProvider.isEnglish ? 'Create Account' : 'መለያ ይፍጠሩ',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  languageProvider.isEnglish 
                      ? 'Sign up to get started'
                      : 'መጀመር ያስፈልጋል',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Display Name Field
                CustomTextField(
                  controller: _displayNameController,
                  label: languageProvider.isEnglish ? 'Display Name' : 'የማሳያ ስም',
                  hintText: languageProvider.isEnglish 
                      ? 'Enter your display name' 
                      : 'የማሳያ ስምዎን ያስገቡ',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.isEnglish 
                          ? 'Display name is required'
                          : 'የማሳያ ስም ያስፈልጋል';
                    }
                    if (value.length > AppConstants.maxDisplayNameLength) {
                      return languageProvider.isEnglish 
                          ? 'Display name must be less than ${AppConstants.maxDisplayNameLength} characters'
                          : 'የማሳያ ስም ከ${AppConstants.maxDisplayNameLength} ቁምፊ ያነሰ መሆን አለበት';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: languageProvider.isEnglish ? 'Email' : 'ኢሜይል',
                  hintText: languageProvider.isEnglish 
                      ? 'Enter your email' 
                      : 'ኢሜይልዎን ያስገቡ',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.isEnglish 
                          ? 'Email is required'
                          : 'ኢሜይል ያስፈልጋል';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return languageProvider.isEnglish 
                          ? 'Please enter a valid email'
                          : 'እባክዎ ትክክለኛ ኢሜይል ያስገቡ';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: languageProvider.isEnglish ? 'Password' : 'የይለፍ ቃል',
                  hintText: languageProvider.isEnglish 
                      ? 'Enter your password' 
                      : 'የይለፍ ቃልዎን ያስገቡ',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.isEnglish 
                          ? 'Password is required'
                          : 'የይለፍ ቃል ያስፈልጋል';
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return languageProvider.isEnglish 
                          ? 'Password must be at least ${AppConstants.minPasswordLength} characters'
                          : 'የይለፍ ቃል ቢያንስ ${AppConstants.minPasswordLength} ቁምፊ መሆን አለበት';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: languageProvider.isEnglish ? 'Confirm Password' : 'የይለፍ ቃል አረጋግጥ',
                  hintText: languageProvider.isEnglish 
                      ? 'Confirm your password' 
                      : 'የይለፍ ቃልዎን ያረጋግጡ',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.isEnglish 
                          ? 'Please confirm your password'
                          : 'እባክዎ የይለፍ ቃልዎን ያረጋግጡ';
                    }
                    if (value != _passwordController.text) {
                      return languageProvider.isEnglish 
                          ? 'Passwords do not match'
                          : 'የይለፍ ቃሎች አይዛመዱም';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: languageProvider.isEnglish 
                                      ? 'I agree to the '
                                      : 'እስማማለሁ ',
                                ),
                                TextSpan(
                                  text: languageProvider.isEnglish 
                                      ? 'Terms & Conditions'
                                      : 'ውሎች እና ሁኔታዎች',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: languageProvider.isEnglish 
                                      ? ' and '
                                      : ' እና ',
                                ),
                                TextSpan(
                                  text: languageProvider.isEnglish 
                                      ? 'Privacy Policy'
                                      : 'የግላዊነት ፖሊሲ',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: languageProvider.isEnglish ? 'Create Account' : 'መለያ ይፍጠሩ',
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  isLoading: authProvider.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      languageProvider.isEnglish 
                          ? "Already have an account? " 
                          : 'የነበረዎ መለያ አለ? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        languageProvider.isEnglish ? 'Sign In' : 'ግባ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
