import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Password reset failed'),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _emailSent
                    ? (languageProvider.isEnglish ? 'Check Your Email' : 'ኢሜይልዎን ያረጋግጡ')
                    : (languageProvider.isEnglish ? 'Forgot Password?' : 'የይለፍ ቃል ረሳሽ?'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                _emailSent
                    ? (languageProvider.isEnglish 
                        ? 'We\'ve sent a password reset link to ${_emailController.text}'
                        : 'የይለፍ ቃል ዳግም አቋቁም ማራዘሚያ ወደ ${_emailController.text} ልከናል')
                    : (languageProvider.isEnglish 
                        ? 'Enter your email address and we\'ll send you a link to reset your password.'
                        : 'ኢሜይል አድራሻዎን ያስገቡ እና የይለፍ ቃልዎን ለማስተካከል ማራዘሚያ እንልክልዎታለን።'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              if (!_emailSent) ...[
                // Email Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: languageProvider.isEnglish ? 'Email Address' : 'ኢሜይል አድራሻ',
                        hintText: languageProvider.isEnglish 
                            ? 'Enter your email address' 
                            : 'ኢሜይል አድራሻዎን ያስገቡ',
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
                      
                      const SizedBox(height: 32),
                      
                      // Reset Password Button
                      CustomButton(
                        text: languageProvider.isEnglish ? 'Send Reset Link' : 'ዳግም አቋቁም ማራዘሚያ ላክ',
                        onPressed: authProvider.isLoading ? null : _handleResetPassword,
                        isLoading: authProvider.isLoading,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success State
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mark_email_read,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.isEnglish 
                            ? 'Email Sent Successfully!'
                            : 'ኢሜይል በተሳካ ሁኔታ ተልኳል!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.isEnglish 
                            ? 'Please check your email and click the link to reset your password.'
                            : 'እባክዎ ኢሜይልዎን ያረጋግጡ እና የይለፍ ቃልዎን ለማስተካከል ማራዘሚያውን ይጫኑ።',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Back to Login Button
                CustomButton(
                  text: languageProvider.isEnglish ? 'Back to Login' : 'ወደ መግባት ተመለስ',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  variant: ButtonVariant.outlined,
                ),
                
                const SizedBox(height: 16),
                
                // Resend Email Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                    });
                  },
                  child: Text(
                    languageProvider.isEnglish ? 'Didn\'t receive the email?' : 'ኢሜይል አልደረሰም?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
