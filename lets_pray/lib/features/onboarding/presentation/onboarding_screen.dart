import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completed status in SQLite
    await DatabaseHelper.instance.saveSetting('onboarding_completed', 'true');
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    // Navigate to Home Shell
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MainNavigationShell(),
        transitionsBuilder: (context, anim, secondaryAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Onboarding text keys
    final skipText = AppStrings.of(ref, 'onboarding_skip');
    final nextText = AppStrings.of(ref, 'onboarding_next');
    final startText = AppStrings.of(ref, 'onboarding_get_started');

    final slides = [
      _OnboardingData(
        icon: Icons.auto_stories,
        titleKey: 'onboarding_slide1_title',
        descKey: 'onboarding_slide1_desc',
        glowColor: AppTheme.liturgicalGold,
      ),
      _OnboardingData(
        icon: Icons.fingerprint, // reflecting tactile tracking
        titleKey: 'onboarding_slide2_title',
        descKey: 'onboarding_slide2_desc',
        glowColor: AppTheme.liturgicalViolet,
      ),
      _OnboardingData(
        icon: Icons.favorite_border,
        titleKey: 'onboarding_slide3_title',
        descKey: 'onboarding_slide3_desc',
        glowColor: AppTheme.liturgicalRed,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (_currentPage < 2)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                skipText.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                HapticFeedback.selectionClick();
              },
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Icon with Glow
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: slide.glowColor.withOpacity(0.06),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: slide.glowColor.withOpacity(0.1),
                              border: Border.all(
                                color: slide.glowColor.withOpacity(0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: slide.glowColor.withOpacity(0.2),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Icon(
                              slide.icon,
                              size: 56,
                              color: slide.glowColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Title
                      Text(
                        AppStrings.of(ref, slide.titleKey),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      // Description
                      Text(
                        AppStrings.of(ref, slide.descKey),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Controls Layer
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppTheme.liturgicalGold
                            : AppTheme.surfaceLightDark,
                      ),
                    ),
                  ),
                ),

                // Action Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 2
                          ? AppTheme.liturgicalGold
                          : AppTheme.surfaceDark,
                      foregroundColor: _currentPage == 2 ? Colors.black : AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _currentPage == 2
                              ? AppTheme.liturgicalGold
                              : AppTheme.surfaceLightDark,
                          width: _currentPage == 2 ? 0 : 1,
                        ),
                      ),
                      elevation: _currentPage == 2 ? 4 : 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (_currentPage == 2 ? startText : nextText).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == 2 ? Icons.check : Icons.arrow_forward,
                          size: 16,
                        ),
                      ],
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

class _OnboardingData {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final Color glowColor;

  _OnboardingData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.glowColor,
  });
}
