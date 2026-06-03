import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bible_quiz.dart';

class BibleQuizState {
  final String? activeLevel; // 'beginner', 'intermediate', 'advanced' or null
  final int currentQuestionIndex;
  final List<BibleQuestion> shuffledQuestions;
  final Set<int> answeredQuestionIds;
  final int score;
  final int streak;
  final int selectedOptionIndex; // -1 if not selected yet
  final bool showExplanation;

  BibleQuizState({
    this.activeLevel,
    required this.currentQuestionIndex,
    required this.shuffledQuestions,
    required this.answeredQuestionIds,
    required this.score,
    required this.streak,
    required this.selectedOptionIndex,
    required this.showExplanation,
  });

  BibleQuizState copyWith({
    String? Function()? activeLevel,
    int? currentQuestionIndex,
    List<BibleQuestion>? shuffledQuestions,
    Set<int>? answeredQuestionIds,
    int? score,
    int? streak,
    int? selectedOptionIndex,
    bool? showExplanation,
  }) {
    return BibleQuizState(
      activeLevel: activeLevel != null ? activeLevel() : this.activeLevel,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      shuffledQuestions: shuffledQuestions ?? this.shuffledQuestions,
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      showExplanation: showExplanation ?? this.showExplanation,
    );
  }

  BibleQuestion? get currentQuestion {
    if (shuffledQuestions.isEmpty || currentQuestionIndex >= shuffledQuestions.length) {
      return null;
    }
    return shuffledQuestions[currentQuestionIndex];
  }

  bool get isAnswered => selectedOptionIndex != -1;
  bool get isCorrect => isAnswered && currentQuestion != null && selectedOptionIndex == currentQuestion!.correctAnswerIndex;
}

class BibleQuizNotifier extends StateNotifier<BibleQuizState> {
  BibleQuizNotifier()
      : super(BibleQuizState(
          activeLevel: null,
          currentQuestionIndex: 0,
          shuffledQuestions: [],
          answeredQuestionIds: {},
          score: 0,
          streak: 0,
          selectedOptionIndex: -1,
          showExplanation: false,
        ));

  void selectLevel(String level) {
    // Filter questions for this level
    final levelQuestions = BibleQuestion.allQuestions.where((q) => q.level == level).toList();
    
    // Shuffle them
    levelQuestions.shuffle();

    state = BibleQuizState(
      activeLevel: level,
      currentQuestionIndex: 0,
      shuffledQuestions: levelQuestions,
      answeredQuestionIds: {},
      score: 0,
      streak: 0,
      selectedOptionIndex: -1,
      showExplanation: false,
    );
    
    HapticFeedback.mediumImpact();
  }

  void selectOption(int index) {
    if (state.isAnswered) return; // Can't change answer once submitted

    final question = state.currentQuestion;
    if (question == null) return;

    final bool correct = index == question.correctAnswerIndex;
    final int newScore = correct ? state.score + 10 : state.score;
    final int newStreak = correct ? state.streak + 1 : 0;
    
    final newAnswered = Set<int>.from(state.answeredQuestionIds)..add(question.id);

    state = state.copyWith(
      selectedOptionIndex: index,
      showExplanation: true,
      score: newScore,
      streak: newStreak,
      answeredQuestionIds: newAnswered,
    );

    if (correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void nextQuestion() {
    if (!state.isAnswered) return;

    final nextIndex = state.currentQuestionIndex + 1;
    
    if (nextIndex >= state.shuffledQuestions.length) {
      // Infinite Loop: If the user completes the deck, shuffle the same level and restart
      final level = state.activeLevel;
      if (level != null) {
        final levelQuestions = BibleQuestion.allQuestions.where((q) => q.level == level).toList();
        levelQuestions.shuffle();
        
        state = state.copyWith(
          currentQuestionIndex: 0,
          shuffledQuestions: levelQuestions,
          selectedOptionIndex: -1,
          showExplanation: false,
          // Retain score and streak to carry over into the next round
        );
      }
    } else {
      // Move to next question in the current shuffled list
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        selectedOptionIndex: -1,
        showExplanation: false,
      );
    }
    
    HapticFeedback.mediumImpact();
  }

  void resetQuiz() {
    state = BibleQuizState(
      activeLevel: null,
      currentQuestionIndex: 0,
      shuffledQuestions: [],
      answeredQuestionIds: {},
      score: 0,
      streak: 0,
      selectedOptionIndex: -1,
      showExplanation: false,
    );
    HapticFeedback.lightImpact();
  }
}

final bibleQuizProvider = StateNotifierProvider<BibleQuizNotifier, BibleQuizState>((ref) {
  return BibleQuizNotifier();
});
