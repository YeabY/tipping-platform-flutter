import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_constants.dart';
import '../../services/local_tip_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _uniqueUrlController = TextEditingController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      _displayNameController.text = user.displayName;
      _bioController.text = user.bio ?? '';
      _uniqueUrlController.text = user.uniqueUrl ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _uniqueUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final languageProvider = context.read<LanguageProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await authProvider.updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        profileImageUrl: _selectedImagePath, // In a real app, you'd upload this first
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.isEnglish 
                    ? 'Profile updated successfully'
                    : 'መገለጫ በተሳካ ሁኔታ ተዘምኗል',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.isEnglish 
                  ? 'Failed to update profile'
                  : 'መገለጫ ማዘመን አልተሳካም',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isEnglish ? 'Edit Profile' : 'መገለጫ አርትዖት',
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              languageProvider.isEnglish ? 'Save' : 'አስቀምጥ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: _selectedImagePath != null
                            ? ClipOval(
                                child: Image.network(
                                  _selectedImagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.primary,
                                    );
                                  },
                                ),
                              )
                            : authProvider.currentUser?.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      authProvider.currentUser!.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Theme.of(context).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        languageProvider.isEnglish ? 'Change Photo' : 'ስዕል ቀይር',
                      ),
                    ),
                  ],
                ),
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
              
              // Bio Field
              CustomTextField(
                controller: _bioController,
                label: languageProvider.isEnglish ? 'Bio' : 'ባዮግራፊ',
                hintText: languageProvider.isEnglish 
                    ? 'Tell us about yourself...' 
                    : 'ስለ ራስዎ ይንገሩን...',
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > AppConstants.maxBioLength) {
                    return languageProvider.isEnglish 
                        ? 'Bio must be less than ${AppConstants.maxBioLength} characters'
                        : 'ባዮግራፊ ከ${AppConstants.maxBioLength} ቁምፊ ያነሰ መሆን አለበት';
                  }
                  return null;
                },
              ),
              
              if (authProvider.isCreator) ...[
                const SizedBox(height: 16),
                
                // Unique URL Field (only for creators)
                CustomTextField(
                  controller: _uniqueUrlController,
                  label: languageProvider.isEnglish ? 'Unique URL' : 'ልዩ URL',
                  hintText: languageProvider.isEnglish 
                      ? 'Enter your unique URL' 
                      : 'ልዩ URLዎን ያስገቡ',
                  prefixIcon: const Icon(Icons.link),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
                        return languageProvider.isEnglish 
                            ? 'URL can only contain letters, numbers, hyphens, and underscores'
                            : 'URL ሰያፍ ፊደላት፣ ቁጥሮች፣ ሰረዝ እና የታች መስመር ብቻ ሊይዝ ይችላል';
                      }
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Become Creator Button (only if not already a creator)
              if (!authProvider.isCreator) ...[
                CustomButton(
                  text: languageProvider.isEnglish ? 'Become a Creator' : 'ፈጣሪ ይሁኑ',
                  icon: const Icon(Icons.star),
                  onPressed: () {
                    _showBecomeCreatorDialog();
                  },
                  variant: ButtonVariant.outlined,
                ),
                const SizedBox(height: 16),
              ],
              
              // Save Button
              CustomButton(
                text: languageProvider.isEnglish ? 'Save Changes' : 'ለውጦችን አስቀምጥ',
                onPressed: _handleSave,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBecomeCreatorDialog() {
    final languageProvider = context.read<LanguageProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isEnglish ? 'Become a Creator' : 'ፈጣሪ ይሁኑ',
        ),
        content: Text(
          languageProvider.isEnglish 
              ? 'Are you sure you want to become a creator? This will allow others to send you tips.'
              : 'ፈጣሪ መሆን ይፈልጋሉ? ይህ ሌሎች ገንዘብ እንዲልኩልዎ ያስችላል።',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              languageProvider.isEnglish ? 'Cancel' : 'ሰርዝ',
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                final authProvider = context.read<AuthProvider>();
                final currentUser = authProvider.currentUser;
                
                if (currentUser == null) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          languageProvider.isEnglish 
                              ? 'Please log in first'
                              : 'እባክዎ መጀመሪያ ይግቡ',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                  return;
                }
                
                // Store creator profile
                final result = await LocalTipService.storeCreatorProfile(
                  userId: currentUser.id,
                  uniqueUrl: _uniqueUrlController.text.trim(),
                  displayName: _displayNameController.text.trim(),
                  bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
                  profileImageUrl: _selectedImagePath,
                );
                
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  
                  if (result['success']) {
                    // Update user to be a creator
                    await authProvider.becomeCreator(
                      uniqueUrl: _uniqueUrlController.text.trim(),
                      bio: _bioController.text.trim(),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          languageProvider.isEnglish 
                              ? 'You are now a creator!'
                              : 'አሁን ፈጣሪ ነዎት!',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Failed to become creator'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        languageProvider.isEnglish 
                            ? 'Failed to become creator'
                            : 'ፈጣሪ መሆን አልተሳካም',
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              languageProvider.isEnglish ? 'Confirm' : 'አረጋግጥ',
            ),
          ),
        ],
      ),
    );
  }
}
