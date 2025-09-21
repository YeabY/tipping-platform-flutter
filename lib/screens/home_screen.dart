import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_button.dart';
import '../constants/app_constants.dart';
import '../services/local_tip_service.dart';
import '../screens/profile/creator_profile_screen.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _creators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCreators();
  }

  Future<void> _loadCreators() async {
    final creators = await LocalTipService.getAllCreatorProfiles();
    setState(() {
      _creators = creators;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(AppConstants.appName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed('/edit-profile');
                },
              ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isEnglish 
                          ? 'Welcome back, ${authProvider.currentUser?.displayName ?? 'User'}!'
                          : 'እንኳን ደህና መጡ፣ ${authProvider.currentUser?.displayName ?? 'ተጠቃሚ'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languageProvider.isEnglish 
                          ? 'Ready to support creators or start receiving tips?'
                          : 'ፈጣሪዎችን ለመደገፍ ወይም ገንዘብ መቀበል ዝግጁ ናችሁ?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              languageProvider.isEnglish ? 'Quick Actions' : 'ፈጣን ድርጊቶች',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            if (authProvider.isCreator) ...[
              // Creator Actions
              CustomButton(
                text: languageProvider.isEnglish ? 'View Dashboard' : 'ዳሽቦርድ ይመልከቱ',
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.of(context).pushNamed('/dashboard');
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                text: languageProvider.isEnglish ? 'Share Profile' : 'መገለጫ ያጋሩ',
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share profile
                },
                variant: ButtonVariant.outlined,
              ),
            ] else ...[
              // Regular User Actions
              CustomButton(
                text: languageProvider.isEnglish ? 'Browse Creators' : 'ፈጣሪዎችን ያስሱ',
                icon: const Icon(Icons.explore),
                onPressed: () {
                  _scrollToCreators();
                },
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                text: languageProvider.isEnglish ? 'Become a Creator' : 'ፈጣሪ ይሁኑ',
                icon: const Icon(Icons.star),
                onPressed: () {
                  Navigator.of(context).pushNamed('/edit-profile');
                },
                variant: ButtonVariant.outlined,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Creators List
            if (!authProvider.isCreator) ...[
              Text(
                languageProvider.isEnglish ? 'Featured Creators' : 'የተለዩ ፈጣሪዎች',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildCreatorsList(context, languageProvider),
              
              const SizedBox(height: 24),
            ],
            
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isEnglish ? 'Account Info' : 'የመለያ መረጃ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      languageProvider.isEnglish ? 'Email:' : 'ኢሜይል:',
                      authProvider.currentUser?.email ?? '',
                      Icons.email,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      languageProvider.isEnglish ? 'Account Type:' : 'የመለያ አይነት:',
                      authProvider.isCreator 
                          ? (languageProvider.isEnglish ? 'Creator' : 'ፈጣሪ')
                          : (languageProvider.isEnglish ? 'Tipper' : 'ገንዘብ ላኪ'),
                      Icons.person,
                    ),
                    if (authProvider.isCreator) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        languageProvider.isEnglish ? 'Profile URL:' : 'የመገለጫ URL:',
                        authProvider.currentUser?.tippingUrl ?? '',
                        Icons.link,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Language Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  languageProvider.isEnglish ? 'Language:' : 'ቋንቋ:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    languageProvider.toggleLanguage();
                  },
                  child: Text(
                    languageProvider.isEnglish ? 'አማርኛ' : 'English',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorsList(BuildContext context, LanguageProvider languageProvider) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_creators.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isEnglish 
                  ? 'No creators yet'
                  : 'እስካሁን ምንም ፈጣሪዎች የሉም',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isEnglish 
                  ? 'Be the first to become a creator!'
                  : 'መጀመሪያ ፈጣሪ ይሁኑ!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _creators.length,
        itemBuilder: (context, index) {
          final creator = _creators[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: InkWell(
                onTap: () => _navigateToCreatorProfile(context, creator),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: creator['profileImageUrl'] != null
                            ? NetworkImage(creator['profileImageUrl'])
                            : null,
                        child: creator['profileImageUrl'] == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        creator['displayName'] ?? 'Creator',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (creator['bio'] != null && creator['bio'].isNotEmpty)
                        Text(
                          creator['bio'],
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Icon(
                        Icons.favorite,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToCreatorProfile(BuildContext context, Map<String, dynamic> creatorProfile) {
    // Create a User object from the creator profile
    final creator = User(
      id: creatorProfile['userId'],
      email: 'creator@example.com', // We don't store email in creator profiles
      displayName: creatorProfile['displayName'],
      bio: creatorProfile['bio'],
      profileImageUrl: creatorProfile['profileImageUrl'],
      uniqueUrl: creatorProfile['uniqueUrl'],
      isCreator: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatorProfileScreen(
          creator: creator,
          tipperName: context.read<AuthProvider>().currentUser?.displayName,
        ),
      ),
    );
  }

  void _scrollToCreators() {
    // Scroll to creators section
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
