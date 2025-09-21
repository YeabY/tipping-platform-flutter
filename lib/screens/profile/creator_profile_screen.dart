import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/language_provider.dart';
import '../../models/user.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../services/local_tip_service.dart';
import '../tipping/tip_screen.dart';

class CreatorProfileScreen extends StatefulWidget {
  final User creator;
  final String? tipperName;

  const CreatorProfileScreen({
    super.key,
    required this.creator,
    this.tipperName,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final result = await LocalTipService.getCreatorAnalytics(widget.creator.id);
    if (mounted) {
      setState(() {
        _analytics = result['success'] ? result['analytics'] : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient background
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Profile Picture
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: widget.creator.profileImageUrl != null
                                ? Image.network(
                                    widget.creator.profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.primaryColor,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.white,
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Creator Name
                        Text(
                          widget.creator.displayName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Bio
                        if (widget.creator.bio != null && widget.creator.bio!.isNotEmpty)
                          Text(
                            widget.creator.bio!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Message
                  if (widget.tipperName != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.isEnglish 
                                ? 'Welcome, ${widget.tipperName}!'
                                : 'እንኳን ደህና መጡ፣ ${widget.tipperName}!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            languageProvider.isEnglish 
                                ? 'Support ${widget.creator.displayName} with a tip'
                                : '${widget.creator.displayName}ን በገንዘብ ይደግፉ',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Tip Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TipScreen(
                            creator: widget.creator,
                            tipperName: widget.tipperName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: Text(
                      languageProvider.isEnglish 
                          ? 'Send Tip to ${widget.creator.displayName}'
                          : '${widget.creator.displayName} ገንዘብ ላክ',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Share Options
                  Text(
                    languageProvider.isEnglish ? 'Share Profile' : 'መገለጫ ያጋሩ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareProfile(context, _getTippingUrl()),
                          icon: const Icon(Icons.share),
                          label: Text(
                            languageProvider.isEnglish ? 'Share Link' : 'ማራዘሚያ ያጋሩ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showQRCode(context, _getTippingUrl()),
                          icon: const Icon(Icons.qr_code),
                          label: Text(
                            languageProvider.isEnglish ? 'QR Code' : 'QR ኮድ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Profile URL
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.isEnglish ? 'Profile URL:' : 'የመገለጫ URL:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getTippingUrl(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyToClipboard(context, _getTippingUrl()),
                              icon: const Icon(Icons.copy),
                              tooltip: languageProvider.isEnglish ? 'Copy' : 'ቅዳ',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Creator Stats (placeholder)
                  Text(
                    languageProvider.isEnglish ? 'Creator Stats' : 'የፈጣሪ ስታቲስቲክስ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          languageProvider.isEnglish ? 'Tips Received' : 'የተቀበሉ ገንዘቦች',
                          _isLoading 
                              ? '...' 
                              : '${_analytics?['totalTips'] ?? 0}',
                          Icons.favorite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          languageProvider.isEnglish ? 'Total Earnings' : 'ጠቅላላ ገቢ',
                          _isLoading 
                              ? '...' 
                              : '${_getCurrencySymbol()}${_analytics?['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _shareProfile(BuildContext context, String url) {
    // In a real app, you would use the share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().isEnglish 
              ? 'Share functionality would be implemented here'
              : 'የማጋራት ተግባር እዚህ ይተገብራል',
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.read<LanguageProvider>().isEnglish ? 'QR Code' : 'QR ኮድ',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            Text(
              context.read<LanguageProvider>().isEnglish 
                  ? 'Scan this QR code to visit the profile'
                  : 'መገለጫውን ለመጎብኘት ይህን QR ኮድ ያንብቡ',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.read<LanguageProvider>().isEnglish ? 'Close' : 'ዝጋ',
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // In a real app, you would use the clipboard package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().isEnglish 
              ? 'Copied to clipboard!'
              : 'ወደ ክሊፕቦርድ ተቀድቷል!',
        ),
      ),
    );
  }

  String _getTippingUrl() {
    final uniqueUrl = widget.creator.uniqueUrl ?? widget.creator.id;
    return 'https://tippingplatform.com/creator/$uniqueUrl';
  }

  String _getCurrencySymbol() {
    final currency = _analytics?['currency'] as String? ?? 'USD';
    return currency == 'USD' ? '\$' : 'ብር';
  }
}
