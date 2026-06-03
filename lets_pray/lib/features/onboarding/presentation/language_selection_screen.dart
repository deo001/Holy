import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String _selectedLang = 'en';

  void _selectLanguage(String langCode) {
    setState(() {
      _selectedLang = langCode;
    });
    ref.read(localeProvider.notifier).state = langCode;
    HapticFeedback.selectionClick();
  }

  Future<void> _onContinue() async {
    // Save selected language in SQLite
    await DatabaseHelper.instance.saveSetting('selected_language', _selectedLang);
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    // Navigate to Onboarding
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const OnboardingScreen(),
        transitionsBuilder: (context, anim, secondaryAnim, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Localized labels directly extracted via ref watch (updates immediately on selection)
    final titleText = AppStrings.of(ref, 'onboarding_lang_select_title');
    final subtitleText = AppStrings.of(ref, 'onboarding_lang_select_subtitle');
    final buttonText = AppStrings.of(ref, 'onboarding_continue');

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.liturgicalGold.withOpacity(0.03),
                    blurRadius: 90,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                // Logo & Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.liturgicalGold.withOpacity(0.06),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitleText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // 1. English Option Card
                GestureDetector(
                  onTap: () => _selectLanguage('en'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _selectedLang == 'en'
                          ? AppTheme.liturgicalGold.withOpacity(0.08)
                          : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedLang == 'en'
                            ? AppTheme.liturgicalGold
                            : AppTheme.surfaceLightDark,
                        width: 2,
                      ),
                      boxShadow: _selectedLang == 'en'
                          ? [
                              BoxShadow(
                                color: AppTheme.liturgicalGold.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedLang == 'en'
                                ? AppTheme.liturgicalGold.withOpacity(0.2)
                                : AppTheme.surfaceLightDark,
                          ),
                          child: const Text(
                            "🇺🇸",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "English",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Use English translation",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedLang == 'en')
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.liturgicalGold,
                            size: 26,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Kiswahili Option Card
                GestureDetector(
                  onTap: () => _selectLanguage('sw'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _selectedLang == 'sw'
                          ? AppTheme.liturgicalGold.withOpacity(0.08)
                          : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedLang == 'sw'
                            ? AppTheme.liturgicalGold
                            : AppTheme.surfaceLightDark,
                        width: 2,
                      ),
                      boxShadow: _selectedLang == 'sw'
                          ? [
                              BoxShadow(
                                color: AppTheme.liturgicalGold.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedLang == 'sw'
                                ? AppTheme.liturgicalGold.withOpacity(0.2)
                                : AppTheme.surfaceLightDark,
                          ),
                          child: const Text(
                            "🇹🇿",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kiswahili",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tumia tafsiri ya Kiswahili",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedLang == 'sw')
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.liturgicalGold,
                            size: 26,
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),

                // Continue Button
                ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.liturgicalGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    buttonText.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
