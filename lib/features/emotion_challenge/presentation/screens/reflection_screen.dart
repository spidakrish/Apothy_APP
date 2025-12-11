import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import '../providers/emotion_challenge_providers.dart';
import '../widgets/body_map.dart';

/// A reflection question with user response
class ReflectionQuestion {
  ReflectionQuestion({
    required this.question,
    this.response = '',
    this.isAnswered = false,
  });

  final String question;
  String response;
  bool isAnswered;
}

/// Phase 5: Reflection Pool
///
/// A beautiful, interactive journaling space where the AI asks
/// personalized questions based on the user's emotional journey.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.emotion,
    this.bodyMapData,
    this.cbtScore,
  });

  final Emotion emotion;
  final BodyMapData? bodyMapData;
  final int? cbtScore;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen>
    with TickerProviderStateMixin {
  // Session tracking
  final _uuid = const Uuid();
  late final String _sessionId;
  late final DateTime _sessionStartTime;
  // Questions and responses
  late List<ReflectionQuestion> _questions;
  int _currentQuestionIndex = 0;
  bool _isJourneyComplete = false;

  // Text controller for responses
  final _responseController = TextEditingController();
  final _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _rippleController;
  late AnimationController _waveController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize session tracking
    _sessionId = _uuid.v4();
    _sessionStartTime = DateTime.now();

    _questions = _generatePersonalizedQuestions();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _setupAnimations();
    _entranceController.forward();
  }

  List<ReflectionQuestion> _generatePersonalizedQuestions() {
    final regions = widget.bodyMapData?.affectedRegions ?? [];
    final emotionId = widget.emotion.id.split('_').first;

    // Get emotion-specific question set
    final questionSet = _getQuestionSetForEmotion(emotionId);

    final questions = <ReflectionQuestion>[];

    // Question 1: Trigger/Context
    questions.add(ReflectionQuestion(question: questionSet.triggerQuestion));

    // Question 2: Body awareness (if body map exists)
    if (regions.isNotEmpty) {
      final primaryRegion = regions.first;
      questions.add(ReflectionQuestion(
        question: questionSet.bodyQuestion.replaceAll('{region}', primaryRegion),
      ));
    }

    // Question 3: Deeper meaning
    questions.add(ReflectionQuestion(question: questionSet.meaningQuestion));

    // Question 4: Action/Response
    questions.add(ReflectionQuestion(question: questionSet.actionQuestion));

    // Question 5: Integration/Learning
    questions.add(ReflectionQuestion(question: questionSet.integrationQuestion));

    return questions;
  }

  _ReflectionQuestionSet _getQuestionSetForEmotion(String emotionId) {
    return switch (emotionId) {
      'fear' || 'apprehension' || 'terror' => _ReflectionQuestionSet(
        triggerQuestion: 'What situation or thought triggered this fear? What specifically felt threatening?',
        bodyQuestion: 'You felt fear in your {region}. When else has your body signaled danger this way?',
        meaningQuestion: 'What is this fear trying to protect you from? What matters so much that it feels scary?',
        actionQuestion: 'What would help you feel even 10% safer right now? What small step toward security could you take?',
        integrationQuestion: 'Your future self has moved through this fear. What wisdom would they send back to you?',
      ),
      'anger' || 'annoyance' || 'rage' => _ReflectionQuestionSet(
        triggerQuestion: 'What boundary was crossed? What felt unfair or wrong that sparked this anger?',
        bodyQuestion: 'Anger showed up in your {region}. Where does anger typically live in your body?',
        meaningQuestion: 'What value or need is this anger defending? What does it want you to fight for?',
        actionQuestion: 'How could you honor this anger without being controlled by it? What healthy action could you take?',
        integrationQuestion: 'When you look back at this anger, what will you want to have done with its energy?',
      ),
      'sadness' || 'pensiveness' || 'grief' => _ReflectionQuestionSet(
        triggerQuestion: 'What loss—big or small—is this sadness mourning? What feels missing?',
        bodyQuestion: 'Your {region} holds this sadness. What memories does this physical feeling connect to?',
        meaningQuestion: 'What does this sadness reveal about what you value? What did this loss mean to you?',
        actionQuestion: 'What does your sad heart need right now? Comfort? Space? Expression?',
        integrationQuestion: 'How might this sadness be reshaping you? What are you learning about yourself?',
      ),
      'joy' || 'serenity' || 'ecstasy' => _ReflectionQuestionSet(
        triggerQuestion: 'What brought this joy alive? What aligned in this moment to create happiness?',
        bodyQuestion: 'Joy lives in your {region}. How does your body know when something is truly good?',
        meaningQuestion: 'What does this joy tell you about what matters to you? What lights you up?',
        actionQuestion: 'How can you savor this moment more fully? What would deepen this joy?',
        integrationQuestion: 'How can you carry the essence of this joy forward? What will help you return to it?',
      ),
      'trust' || 'acceptance' || 'admiration' => _ReflectionQuestionSet(
        triggerQuestion: 'What inspired this trust? What did you notice that made connection feel safe?',
        bodyQuestion: 'Trust settled into your {region}. How does your body recognize trustworthiness?',
        meaningQuestion: 'What qualities or actions earned this trust? What does trust mean to you?',
        actionQuestion: 'How can you honor this trust? What would deepen or protect this connection?',
        integrationQuestion: 'What is this trust teaching you about yourself and relationships?',
      ),
      'surprise' || 'distraction' || 'amazement' => _ReflectionQuestionSet(
        triggerQuestion: 'What unexpected thing happened? What did you not see coming?',
        bodyQuestion: 'Surprise registered in your {region}. How does your body typically respond to the unexpected?',
        meaningQuestion: 'What does this surprise challenge or confirm? What assumptions did it shake?',
        actionQuestion: 'How can you stay curious rather than reactive? What might this surprise reveal?',
        integrationQuestion: 'How might this unexpected turn be an opportunity? What new path does it open?',
      ),
      'disgust' || 'boredom' || 'loathing' => _ReflectionQuestionSet(
        triggerQuestion: 'What feels wrong or repulsive? What boundary has been violated?',
        bodyQuestion: 'Disgust showed up in your {region}. What does your body reject or want to expel?',
        meaningQuestion: 'What values or standards does this disgust protect? What line got crossed?',
        actionQuestion: 'What do you need to remove or distance yourself from? What boundary needs reinforcing?',
        integrationQuestion: 'What is this strong reaction teaching you about your limits and standards?',
      ),
      'anticipation' || 'interest' || 'vigilance' => _ReflectionQuestionSet(
        triggerQuestion: 'What are you looking toward? What possibility has captured your attention?',
        bodyQuestion: 'Anticipation energized your {region}. How does your body signal readiness?',
        meaningQuestion: 'What does this anticipation reveal about what you want? What are you hoping for?',
        actionQuestion: 'How can you prepare without over-preparing? What needs attention now?',
        integrationQuestion: 'However this unfolds, what will you have learned from this period of waiting?',
      ),
      'love' => _ReflectionQuestionSet(
        triggerQuestion: 'What opened your heart? What connection or experience sparked this love?',
        bodyQuestion: 'Love fills your {region}. Where do you physically feel the warmth of connection?',
        meaningQuestion: 'What makes this love special? What qualities or moments define it?',
        actionQuestion: 'How can you express this love? What gesture—small or large—feels true?',
        integrationQuestion: 'How is this love changing you? What are you becoming through loving?',
      ),
      'submission' => _ReflectionQuestionSet(
        triggerQuestion: 'What situation led you to yield or defer? What made speaking up feel unsafe?',
        bodyQuestion: 'Submission shows in your {region}. When does your body pull back or make itself small?',
        meaningQuestion: 'What fear underlies this submission? What are you trying to avoid?',
        actionQuestion: 'What would it feel like to reclaim even a bit of your voice? What small assertion could you make?',
        integrationQuestion: 'What would your most confident self want you to know about this moment?',
      ),
      'awe' => _ReflectionQuestionSet(
        triggerQuestion: 'What vast or magnificent thing stopped you in wonder? What exceeded your normal experience?',
        bodyQuestion: 'Awe expanded into your {region}. How does your body respond to the extraordinary?',
        meaningQuestion: 'What perspective shift does this awe offer? How does it change your sense of scale?',
        actionQuestion: 'How can you stay present with this wonder? What would deepen this sense of connection?',
        integrationQuestion: 'How will you carry this sense of awe forward? What does it inspire in you?',
      ),
      'disapproval' => _ReflectionQuestionSet(
        triggerQuestion: 'What action or choice disappointed you? What standard wasn\'t met?',
        bodyQuestion: 'Disapproval tightened in your {region}. Where does judgment live in your body?',
        meaningQuestion: 'What values does this disapproval protect? What matters enough to cause this reaction?',
        actionQuestion: 'Can you hold your standards while softening judgment? What would wisdom look like here?',
        integrationQuestion: 'What is this disapproval teaching you about expectations and acceptance?',
      ),
      'remorse' => _ReflectionQuestionSet(
        triggerQuestion: 'What action are you regretting? What do you wish you could do differently?',
        bodyQuestion: 'Remorse weighs on your {region}. How does regret feel physically in your body?',
        meaningQuestion: 'What does this remorse reveal about who you want to be? What values did you compromise?',
        actionQuestion: 'What amends can you make? What step toward repair feels right?',
        integrationQuestion: 'How can you learn from this without drowning in shame? What will you do differently?',
      ),
      'contempt' => _ReflectionQuestionSet(
        triggerQuestion: 'Who or what are you looking down on? What triggered this sense of superiority?',
        bodyQuestion: 'Contempt hardens in your {region}. Where does judgment create tension?',
        meaningQuestion: 'What insecurity might this contempt be masking? What are you trying to prove?',
        actionQuestion: 'Can you find common humanity here? What would soften this judgment?',
        integrationQuestion: 'What would it cost you to release this contempt? What might you gain?',
      ),
      'aggressiveness' => _ReflectionQuestionSet(
        triggerQuestion: 'What provoked this aggressive energy? What feels like it needs to be conquered or won?',
        bodyQuestion: 'Aggressiveness surges through your {region}. How does your body prepare for confrontation?',
        meaningQuestion: 'What is this intensity really about? What needs protection or assertion?',
        actionQuestion: 'How can you channel this energy constructively? What action serves you without harming others?',
        integrationQuestion: 'What strength lies beneath the aggression? How can you access that without the fight?',
      ),
      'optimism' => _ReflectionQuestionSet(
        triggerQuestion: 'What sparked this hopeful feeling? What possibility lit up for you?',
        bodyQuestion: 'Optimism lifts your {region}. Where does hope feel light in your body?',
        meaningQuestion: 'What is this optimism grounded in? What makes this hope realistic?',
        actionQuestion: 'What action would honor this optimism? How can you move toward this possibility?',
        integrationQuestion: 'How can you maintain hope even if outcomes vary? What will you have gained from hoping?',
      ),
      _ => _ReflectionQuestionSet(
        triggerQuestion: 'What triggered this feeling? What circumstances or thoughts brought it forward?',
        bodyQuestion: 'This emotion lives in your {region}. What does your body want you to know?',
        meaningQuestion: 'What is this emotion trying to tell you? What need or value lies underneath?',
        actionQuestion: 'What would honor this feeling? What response feels authentic and kind?',
        integrationQuestion: 'What will you take forward from this emotional experience?',
      ),
    };
  }

  void _setupAnimations() {
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rippleController.dispose();
    _waveController.dispose();
    _responseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveResponse() {
    final response = _responseController.text.trim();
    if (response.isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      _questions[_currentQuestionIndex].response = response;
      _questions[_currentQuestionIndex].isAnswered = true;
    });

    _responseController.clear();
    _focusNode.unfocus();

    // Move to next question or complete
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _isJourneyComplete = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _skipQuestion() {
    HapticFeedback.lightImpact();

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _responseController.clear();
    } else {
      setState(() {
        _isJourneyComplete = true;
      });
    }
  }

  Future<void> _completeJourney() async {
    HapticFeedback.mediumImpact();

    // Create the emotion challenge session entity
    final session = EmotionChallengeSession(
      id: _sessionId,
      emotion: widget.emotion,
      bodyMapPoints: widget.bodyMapData?.points ?? [],
      cbtScore: widget.cbtScore ?? 0,
      reflections: _questions.map((q) {
        return ReflectionResponse(
          question: q.question,
          response: q.response,
          isAnswered: q.isAnswered,
        );
      }).toList(),
      startedAt: _sessionStartTime,
      completedAt: DateTime.now(),
      xpEarned: 50, // Fixed XP reward for completing emotion challenge
    );

    // Initialize and save the session to local storage
    final emotionChallengeRepo =
        ref.read(emotionChallengeRepositoryProvider);
    await emotionChallengeRepo.initialize();
    await emotionChallengeRepo.saveSession(session);

    // Award XP to the user
    final dashboardRepo = ref.read(dashboardRepositoryProvider);
    await dashboardRepo.awardXp(
      50,
      reason: 'Emotion Challenge Completed',
    );

    // Pop all the way back to the mirror screen
    if (mounted) {
      context.go('/mirror');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated water background
          _WaterBackground(
            rippleAnimation: _rippleController,
            waveAnimation: _waveController,
            color: widget.emotion.color,
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Column(
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: _buildHeader(),
                    ),

                    // Main content
                    Expanded(
                      child: FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: _isJourneyComplete
                            ? _buildCompletionScreen()
                            : _buildReflectionContent(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  'Reflection Pool',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 12),

          // Progress dots
          if (!_isJourneyComplete)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_questions.length, (index) {
                final isActive = index == _currentQuestionIndex;
                final isAnswered = _questions[index].isAnswered;

                return Container(
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isAnswered
                        ? AppColors.success
                        : isActive
                            ? widget.emotion.color
                            : AppColors.surface,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildReflectionContent() {
    final currentQuestion = _questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Question number
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 24),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.emotion.color.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.emotion.color.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: widget.emotion.color.withValues(alpha: 0.5),
                  size: 32,
                ),

                const SizedBox(height: 16),

                Text(
                  currentQuestion.question,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Response input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? widget.emotion.color
                    : AppColors.borderSubtle,
              ),
            ),
            child: TextField(
              controller: _responseController,
              focusNode: _focusNode,
              maxLines: 5,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _skipQuestion,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AppButton(
                  onPressed: _responseController.text.trim().isNotEmpty
                      ? _saveResponse
                      : null,
                  label: _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Complete Reflection',
                  isEnabled: _responseController.text.trim().isNotEmpty,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Phase indicator
          _buildPhaseIndicator(),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final answeredCount = _questions.where((q) => q.isAnswered).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Completion badge
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.emotion.color,
                  widget.emotion.color.withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.emotion.color.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 4),
                Text(
                  'Journey',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Complete',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Your Emotional Journey',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Journey summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _JourneySummaryItem(
                  icon: Icons.mood,
                  label: 'Emotion',
                  value: widget.emotion.name,
                  color: widget.emotion.color,
                ),
                const Divider(height: 24),
                _JourneySummaryItem(
                  icon: Icons.accessibility_new,
                  label: 'Body Awareness',
                  value: '${widget.bodyMapData?.affectedRegions.length ?? 0} regions',
                  color: AppColors.info,
                ),
                const Divider(height: 24),
                _JourneySummaryItem(
                  icon: Icons.psychology,
                  label: 'Thoughts Reframed',
                  value: '${widget.cbtScore ?? 0} points',
                  color: AppColors.success,
                ),
                const Divider(height: 24),
                _JourneySummaryItem(
                  icon: Icons.edit_note,
                  label: 'Reflections',
                  value: '$answeredCount of ${_questions.length}',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Key insight
          if (answeredCount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.emotion.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.emotion.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: widget.emotion.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Key Insight',
                        style: AppTypography.labelMedium.copyWith(
                          color: widget.emotion.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'ve taken time to understand your ${widget.emotion.name.toLowerCase()} '
                    'today. This awareness is powerful. Remember: emotions are messengers, '
                    'not enemies.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],

          // Complete button
          AppButton(
            onPressed: _completeJourney,
            label: 'Return to Mirror',
            icon: Icons.check_circle_outline,
            width: double.infinity,
          ),

          const SizedBox(height: 16),

          // XP earned indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.primary, size: 16),
                Text(
                  '50 XP earned',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Phase indicator showing all complete
          _buildPhaseIndicator(allComplete: true),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator({bool allComplete = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PhaseIndicator(phase: 1, isActive: false, isComplete: true, label: 'Compass'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 2, isActive: false, isComplete: true, label: 'Body Map'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 3, isActive: false, isComplete: true, label: 'Scan'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 4, isActive: false, isComplete: true, label: 'Reframe'),
        _PhaseConnector(isComplete: allComplete),
        _PhaseIndicator(
          phase: 5,
          isActive: !allComplete,
          isComplete: allComplete,
          label: 'Reflect',
        ),
      ],
    );
  }
}

/// Animated water background
class _WaterBackground extends StatelessWidget {
  const _WaterBackground({
    required this.rippleAnimation,
    required this.waveAnimation,
    required this.color,
  });

  final Animation<double> rippleAnimation;
  final Animation<double> waveAnimation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([rippleAnimation, waveAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: _WaterPainter(
            rippleProgress: rippleAnimation.value,
            waveProgress: waveAnimation.value,
            color: color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WaterPainter extends CustomPainter {
  _WaterPainter({
    required this.rippleProgress,
    required this.waveProgress,
    required this.color,
  });

  final double rippleProgress;
  final double waveProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Ripple circles
    final center = Offset(size.width / 2, size.height * 0.4);
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final delay = i * 0.3;
      final progress = (rippleProgress + delay) % 1.0;
      final radius = progress * size.width * 0.6;
      final opacity = (1.0 - progress) * 0.3;

      ripplePaint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, radius, ripplePaint);
    }

    // Subtle wave at bottom
    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final waveHeight = math.sin((normalizedX + waveProgress) * math.pi * 4) * 10;
      final y = size.height - 50 + waveHeight;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.05);

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(_WaterPainter oldDelegate) =>
      oldDelegate.rippleProgress != rippleProgress ||
      oldDelegate.waveProgress != waveProgress;
}

class _JourneySummaryItem extends StatelessWidget {
  const _JourneySummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  const _PhaseIndicator({
    required this.phase,
    required this.isActive,
    required this.isComplete,
    required this.label,
  });

  final int phase;
  final bool isActive;
  final bool isComplete;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : AppColors.surface,
            border: Border.all(
              color: isComplete
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.borderSubtle,
              width: 2,
            ),
          ),
          child: Center(
            child: isComplete
                ? Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$phase',
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActive
                ? AppColors.textPrimary
                : isComplete
                    ? AppColors.success
                    : AppColors.textTertiary,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _PhaseConnector extends StatelessWidget {
  const _PhaseConnector({required this.isComplete});

  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isComplete ? AppColors.success : AppColors.borderSubtle,
    );
  }
}

/// Emotion-specific reflection question set
class _ReflectionQuestionSet {
  const _ReflectionQuestionSet({
    required this.triggerQuestion,
    required this.bodyQuestion,
    required this.meaningQuestion,
    required this.actionQuestion,
    required this.integrationQuestion,
  });

  final String triggerQuestion; // What triggered this emotion?
  final String bodyQuestion; // Body awareness question (uses {region} placeholder)
  final String meaningQuestion; // What does this emotion mean?
  final String actionQuestion; // What action to take?
  final String integrationQuestion; // What to learn/integrate?
}
