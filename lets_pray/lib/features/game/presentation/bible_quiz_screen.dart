import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import 'bible_quiz_notifier.dart';

class BibleQuizScreen extends ConsumerWidget {
  const BibleQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bibleQuizProvider);
    final notifier = ref.read(bibleQuizProvider.notifier);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.of(ref, 'game_title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            notifier.resetQuiz();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (state.activeLevel != null)
            TextButton.icon(
              onPressed: () => notifier.resetQuiz(),
              icon: const Icon(Icons.change_circle, color: AppTheme.liturgicalGold),
              label: Text(
                AppStrings.of(ref, 'game_restart'),
                style: const TextStyle(color: AppTheme.liturgicalGold, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.activeLevel == null
              ? _buildLevelSelection(context, ref, notifier)
              : _buildQuizPlay(context, ref, state, notifier, locale),
        ),
      ),
    );
  }

  Widget _buildLevelSelection(BuildContext context, WidgetRef ref, BibleQuizNotifier notifier) {
    final isSw = ref.watch(localeProvider) == 'sw';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.menu_book,
            size: 80,
            color: AppTheme.liturgicalGold,
          ),
          const SizedBox(height: 24),
          Text(
            isSw ? 'CHEMSHA BONGO YA BIBLIA' : 'BIBLE TRIVIA CHALLENGE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.liturgicalGold,
                  letterSpacing: 1.0,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.of(ref, 'game_select_any_level'),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Beginner level card
          _buildLevelCard(
            context: context,
            title: AppStrings.of(ref, 'game_level_beginner'),
            description: isSw
                ? 'Maswali rahisi kuhusu hadithi za msingi za Biblia'
                : 'Simple questions about fundamental Bible stories',
            icon: Icons.child_care,
            gradientColors: [AppTheme.liturgicalGreen.withOpacity(0.8), AppTheme.liturgicalGreen.withOpacity(0.3)],
            borderColor: AppTheme.liturgicalGreen,
            onTap: () => notifier.selectLevel('beginner'),
          ),
          const SizedBox(height: 16),

          // Intermediate level card
          _buildLevelCard(
            context: context,
            title: AppStrings.of(ref, 'game_level_intermediate'),
            description: isSw
                ? 'Tafakari ya kina zaidi kuhusu manabii na mitume'
                : 'Deeper questions about prophets, apostles, and books',
            icon: Icons.psychology,
            gradientColors: [AppTheme.liturgicalGold.withOpacity(0.8), AppTheme.liturgicalGold.withOpacity(0.3)],
            borderColor: AppTheme.liturgicalGold,
            onTap: () => notifier.selectLevel('intermediate'),
          ),
          const SizedBox(height: 16),

          // Advanced level card
          _buildLevelCard(
            context: context,
            title: AppStrings.of(ref, 'game_level_advanced'),
            description: isSw
                ? 'Kwa wataalamu wa Maandiko. Maswali magumu'
                : 'For Scripture scholars. Complex details and lineage',
            icon: Icons.workspace_premium,
            gradientColors: [AppTheme.liturgicalViolet.withOpacity(0.8), AppTheme.liturgicalViolet.withOpacity(0.3)],
            borderColor: AppTheme.liturgicalViolet,
            onTap: () => notifier.selectLevel('advanced'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizPlay(
    BuildContext context,
    WidgetRef ref,
    BibleQuizState state,
    BibleQuizNotifier notifier,
    String locale,
  ) {
    final question = state.currentQuestion;
    if (question == null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.liturgicalGold));
    }

    final isSw = locale == 'sw';
    final questionText = isSw ? question.questionSw : question.questionEn;
    final options = isSw ? question.optionsSw : question.optionsEn;
    final explanation = isSw ? question.explanationSw : question.explanationEn;

    // Resolve difficulty name
    String difficultyLabel = '';
    Color difficultyColor = AppTheme.liturgicalGold;
    if (state.activeLevel == 'beginner') {
      difficultyLabel = AppStrings.of(ref, 'game_level_beginner');
      difficultyColor = AppTheme.liturgicalGreen;
    } else if (state.activeLevel == 'intermediate') {
      difficultyLabel = AppStrings.of(ref, 'game_level_intermediate');
      difficultyColor = AppTheme.liturgicalGold;
    } else if (state.activeLevel == 'advanced') {
      difficultyLabel = AppStrings.of(ref, 'game_level_advanced');
      difficultyColor = AppTheme.liturgicalViolet;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Bar (Score, Level, Streak)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: difficultyColor.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  difficultyLabel.toUpperCase(),
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // Score Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLightDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppTheme.liturgicalGold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.of(ref, 'game_score')}: ${state.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Streak Box
              if (state.streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.liturgicalGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.liturgicalGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${state.streak}',
                        style: const TextStyle(
                          color: AppTheme.liturgicalGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Question Glassmorphic Box
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.surfaceLightDark),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.of(ref, 'game_question_count').toUpperCase()} ${state.currentQuestionIndex + 1}',
                    style: const TextStyle(
                      color: AppTheme.liturgicalGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    questionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Option Selection List
          Column(
            children: List.generate(options.length, (index) {
              final optionText = options[index];
              return _buildOptionButton(state, notifier, index, optionText, question.correctAnswerIndex);
            }),
          ),
          const SizedBox(height: 12),

          // 4. Explanation Section (Fades/slides in once answered)
          if (state.showExplanation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isCorrect 
                      ? AppTheme.liturgicalGreen.withOpacity(0.3) 
                      : AppTheme.liturgicalGold.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.isCorrect ? Icons.check_circle : Icons.info,
                        color: state.isCorrect ? AppTheme.liturgicalGreen : AppTheme.liturgicalGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.isCorrect
                            ? AppStrings.of(ref, 'game_correct').toUpperCase()
                            : AppStrings.of(ref, 'game_incorrect').toUpperCase(),
                        style: TextStyle(
                          color: state.isCorrect ? AppTheme.liturgicalGreen : AppTheme.liturgicalGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Next Question Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.liturgicalGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => notifier.nextQuestion(),
                child: Text(
                  AppStrings.of(ref, 'game_next_question').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BibleQuizState state,
    BibleQuizNotifier notifier,
    int index,
    String optionText,
    int correctIndex,
  ) {
    final isAnswered = state.isAnswered;
    final isSelected = state.selectedOptionIndex == index;
    final isCorrectOption = index == correctIndex;

    Color buttonColor = AppTheme.surfaceDark;
    Color borderColor = AppTheme.surfaceLightDark;
    Widget? trailingIcon;
    TextStyle textStyle = const TextStyle(color: AppTheme.textPrimary, fontSize: 15);

    if (isAnswered) {
      if (isCorrectOption) {
        // Correct option shows green
        buttonColor = AppTheme.liturgicalGreen.withOpacity(0.08);
        borderColor = AppTheme.liturgicalGreen;
        trailingIcon = const Icon(Icons.check_circle, color: AppTheme.liturgicalGreen, size: 20);
        textStyle = const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold);
      } else if (isSelected) {
        // Incorrectly selected option shows red
        buttonColor = Colors.red.withOpacity(0.08);
        borderColor = Colors.red;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
        textStyle = const TextStyle(color: Colors.white, fontSize: 15);
      } else {
        // Unselected incorrect options are faded
        buttonColor = Colors.black.withOpacity(0.1);
        borderColor = AppTheme.surfaceLightDark.withOpacity(0.3);
        textStyle = TextStyle(color: AppTheme.textMuted.withOpacity(0.4), fontSize: 15);
      }
    } else {
      // Default hover state / selection highlight is handled by standard card
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(optionText, style: textStyle),
        trailing: trailingIcon,
        onTap: isAnswered ? null : () => notifier.selectOption(index),
      ),
    );
  }
}
