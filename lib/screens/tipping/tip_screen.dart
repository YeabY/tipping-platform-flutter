import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../models/tip.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/local_tip_service.dart';

class TipScreen extends StatefulWidget {
  final User creator;
  final String? tipperName;

  const TipScreen({
    super.key,
    required this.creator,
    this.tipperName,
  });

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _customAmountController = TextEditingController();
  
  double _selectedAmount = 0;
  Currency _selectedCurrency = Currency.usd;
  bool _isCustomAmount = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _messageController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleSendTip() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _isCustomAmount 
        ? double.tryParse(_customAmountController.text) ?? 0
        : _selectedAmount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().isEnglish 
                ? 'Please enter a valid amount'
                : 'እባክዎ ትክክለኛ መጠን ያስገቡ',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get current user info
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      // Send tip using local tip service
      final result = await LocalTipService.sendTip(
        creatorId: widget.creator.id,
        creatorEmail: widget.creator.email,
        amount: amount,
        currency: _selectedCurrency.name,
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
        tipperEmail: currentUser?.email,
        tipperName: widget.tipperName ?? currentUser?.displayName ?? 'Anonymous',
      );

      if (result['success'] && mounted) {
        final tip = result['tip'] as Tip;
        _showSuccessDialog(tip);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Tip failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().isEnglish 
                  ? 'Tip failed. Please try again.'
                  : 'ገንዘብ መላክ አልተሳካም። እባክዎ እንደገና ይሞክሩ።',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(Tip tip) {
    final languageProvider = context.read<LanguageProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isEnglish 
                  ? 'Tip Sent Successfully!'
                  : 'ገንዘብ በተሳካ ሁኔታ ተልኳል!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isEnglish 
                  ? 'Your tip of ${tip.formattedAmount} has been sent to ${widget.creator.displayName}'
                  : 'የ${tip.formattedAmount} ገንዘብዎ ወደ ${widget.creator.displayName} ተልኳል',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to profile
            },
            child: Text(
              languageProvider.isEnglish ? 'Done' : 'ተጠናቋል',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isEnglish ? 'Send Tip' : 'ገንዘብ ላክ',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Creator Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: widget.creator.profileImageUrl != null
                            ? NetworkImage(widget.creator.profileImageUrl!)
                            : null,
                        child: widget.creator.profileImageUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.creator.displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              languageProvider.isEnglish 
                                  ? 'Content Creator'
                                  : 'የይዘት ፈጣሪ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Currency Selection
              Text(
                languageProvider.isEnglish ? 'Currency' : 'ምንዛሪ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: Currency.values.map((currency) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(currency.name.toUpperCase()),
                        selected: _selectedCurrency == currency,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCurrency = currency;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Amount Selection
              Text(
                languageProvider.isEnglish ? 'Tip Amount' : 'የገንዘብ መጠን',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Preset Amounts
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.tipPresets.map((amount) {
                  final displayAmount = _selectedCurrency == Currency.etb 
                      ? (amount * 55).toStringAsFixed(0) // Approximate USD to ETB conversion
                      : amount.toStringAsFixed(0);
                  final currencySymbol = _selectedCurrency == Currency.usd ? '\$' : 'ብር';
                  
                  return FilterChip(
                    label: Text('$currencySymbol$displayAmount'),
                    selected: _selectedAmount == amount && !_isCustomAmount,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAmount = amount;
                        _isCustomAmount = false;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Custom Amount Option
              FilterChip(
                label: Text(
                  languageProvider.isEnglish ? 'Custom Amount' : 'ብጁ መጠን',
                ),
                selected: _isCustomAmount,
                onSelected: (selected) {
                  setState(() {
                    _isCustomAmount = selected;
                    if (selected) {
                      _selectedAmount = 0;
                    }
                  });
                },
              ),
              
              if (_isCustomAmount) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _customAmountController,
                  label: languageProvider.isEnglish ? 'Enter Amount' : 'መጠን ያስገቡ',
                  hintText: languageProvider.isEnglish 
                      ? 'Enter tip amount' 
                      : 'የገንዘብ መጠን ያስገቡ',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.isEnglish 
                          ? 'Amount is required'
                          : 'መጠን ያስፈልጋል';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return languageProvider.isEnglish 
                          ? 'Please enter a valid amount'
                          : 'እባክዎ ትክክለኛ መጠን ያስገቡ';
                    }
                    if (amount < 0.01) {
                      return languageProvider.isEnglish 
                          ? 'Amount must be at least 0.01'
                          : 'መጠን ቢያንስ 0.01 መሆን አለበት';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Message Field
              CustomTextField(
                controller: _messageController,
                label: languageProvider.isEnglish ? 'Message (Optional)' : 'መልዕክት (አማራጭ)',
                hintText: languageProvider.isEnglish 
                    ? 'Leave a message for ${widget.creator.displayName}...'
                    : 'ለ${widget.creator.displayName} መልዕክት ይተዉ...',
                prefixIcon: const Icon(Icons.message),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > AppConstants.maxMessageLength) {
                    return languageProvider.isEnglish 
                        ? 'Message must be less than ${AppConstants.maxMessageLength} characters'
                        : 'መልዕክት ከ${AppConstants.maxMessageLength} ቁምፊ ያነሰ መሆን አለበት';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Tip Summary
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
                  children: [
                    Text(
                      languageProvider.isEnglish ? 'Tip Summary' : 'የገንዘብ ማጠቃለያ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.isEnglish ? 'Tip Amount:' : 'የገንዘብ መጠን:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _getFormattedAmount(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.isEnglish ? 'Platform Fee:' : 'የመድረክ ክፍያ:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _getFormattedFee(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.isEnglish ? 'Total:' : 'ጠቅላላ:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getFormattedAmount(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Send Tip Button
              CustomButton(
                text: _isProcessing 
                    ? (languageProvider.isEnglish ? 'Processing...' : 'እየተሰራ ነው...')
                    : (languageProvider.isEnglish 
                        ? 'Send Tip'
                        : 'ገንዘብ ላክ'),
                onPressed: _isProcessing ? null : _handleSendTip,
                isLoading: _isProcessing,
                icon: const Icon(Icons.favorite),
              ),
              
              const SizedBox(height: 16),
              
              // Security Notice
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        languageProvider.isEnglish 
                            ? 'Your payment is secure and encrypted'
                            : 'ክፍያዎ ደህንነቱ የተጠበቀ እና የተመሰጠረ ነው',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedAmount() {
    final amount = _isCustomAmount 
        ? (double.tryParse(_customAmountController.text) ?? 0)
        : _selectedAmount;
    final currencySymbol = _selectedCurrency == Currency.usd ? '\$' : 'ብር';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _getFormattedFee() {
    final amount = _isCustomAmount 
        ? (double.tryParse(_customAmountController.text) ?? 0)
        : _selectedAmount;
    final fee = amount * (AppConstants.platformFeePercentage / 100);
    final currencySymbol = _selectedCurrency == Currency.usd ? '\$' : 'ብር';
    return '$currencySymbol${fee.toStringAsFixed(2)}';
  }
}
