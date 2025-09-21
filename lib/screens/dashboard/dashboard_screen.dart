import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/local_tip_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null) {
      final result = await LocalTipService.getCreatorAnalytics(currentUser.id);
      if (mounted) {
        setState(() {
          _analytics = result['success'] ? result['analytics'] : null;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isEnglish ? 'Dashboard' : 'ዳሽቦርድ',
        ),
      ),
      body: SingleChildScrollView(
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
                          ? 'Creator Dashboard'
                          : 'የፈጣሪ ዳሽቦርድ',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languageProvider.isEnglish 
                          ? 'Track your earnings and manage your profile'
                          : 'ገቢዎን ይከታተሉ እና መገለጫዎን ያቀናብሩ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Overview
            Text(
              languageProvider.isEnglish ? 'Overview' : 'አጠቃላይ እይታ',
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
                    languageProvider.isEnglish ? 'Total Earnings' : 'ጠቅላላ ገቢ',
                    _isLoading 
                        ? '...' 
                        : '${_getCurrencySymbol()}${_analytics?['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    languageProvider.isEnglish ? 'Total Tips' : 'ጠቅላላ ገንዘቦች',
                    _isLoading 
                        ? '...' 
                        : '${_analytics?['totalTips'] ?? 0}',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    languageProvider.isEnglish ? 'This Month' : 'ይህ ወር',
                    _isLoading 
                        ? '...' 
                        : '${_getCurrencySymbol()}${_getThisMonthEarnings().toStringAsFixed(2)}',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    languageProvider.isEnglish ? 'Average Tip' : 'አማካይ ገንዘብ',
                    _isLoading 
                        ? '...' 
                        : '${_getCurrencySymbol()}${_analytics?['averageTip']?.toStringAsFixed(2) ?? '0.00'}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
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
            
            CustomButton(
              text: languageProvider.isEnglish ? 'View Analytics' : 'ትንታኔ ይመልከቱ',
              icon: const Icon(Icons.analytics),
              onPressed: () {
                // Navigate to analytics
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
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: languageProvider.isEnglish ? 'Withdraw Funds' : 'ገንዘብ አውጣ',
              icon: const Icon(Icons.account_balance_wallet),
              onPressed: () {
                // Navigate to withdrawal
              },
              variant: ButtonVariant.outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Recent Tips
            Text(
              languageProvider.isEnglish ? 'Recent Tips' : 'የቅርብ ገንዘቦች',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recent Tips List or Empty State
            _buildRecentTips(context, languageProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _buildRecentTips(BuildContext context, LanguageProvider languageProvider) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final recentTips = _analytics?['recentTips'] as List<dynamic>? ?? [];
    
    if (recentTips.isEmpty) {
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
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isEnglish 
                  ? 'No tips received yet'
                  : 'እስካሁን ምንም ገንዘብ አልተቀበለም',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isEnglish 
                  ? 'Share your profile to start receiving tips from supporters'
                  : 'ከደጋፊዎች ገንዘብ መቀበል ለመጀመር መገለጫዎን ያጋሩ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentTips.take(5).map((tip) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              tip['tipperName'] ?? 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: tip['message'] != null && tip['message'].isNotEmpty
                ? Text(tip['message'])
                : null,
            trailing: Text(
              '${_getCurrencySymbol()}${tip['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getCurrencySymbol() {
    final currency = _analytics?['currency'] as String? ?? 'USD';
    return currency == 'USD' ? '\$' : 'ብር';
  }

  double _getThisMonthEarnings() {
    // For now, return total earnings as we don't have month-specific data
    return _analytics?['totalEarnings']?.toDouble() ?? 0.0;
  }
}
