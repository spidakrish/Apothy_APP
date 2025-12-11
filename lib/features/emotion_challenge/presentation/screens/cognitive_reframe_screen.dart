import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/emotion.dart';
import '../widgets/body_map.dart';

/// A thought pattern that can be reframed
class ThoughtPattern {
  const ThoughtPattern({
    required this.id,
    required this.negativeThought,
    required this.cognitiveDistortion,
    required this.reframedThought,
    required this.explanation,
  });

  final String id;
  final String negativeThought;
  final String cognitiveDistortion;
  final String reframedThought;
  final String explanation;
}

/// Phase 4: Cognitive Reframe
///
/// Gamified CBT exercises where users identify and reframe
/// negative thought patterns associated with their emotion.
class CognitiveReframeScreen extends StatefulWidget {
  const CognitiveReframeScreen({
    super.key,
    required this.emotion,
    this.bodyMapData,
  });

  final Emotion emotion;
  final BodyMapData? bodyMapData;

  @override
  State<CognitiveReframeScreen> createState() => _CognitiveReframeScreenState();
}

class _CognitiveReframeScreenState extends State<CognitiveReframeScreen>
    with TickerProviderStateMixin {
  // Game state
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _showingReframe = false;
  bool _completed = false;

  // Thought patterns based on emotion
  late List<ThoughtPattern> _thoughtPatterns;

  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _cardController;
  late AnimationController _successController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  // Swipe state
  double _swipeOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _thoughtPatterns = _getThoughtPatternsForEmotion(widget.emotion);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _setupAnimations();
    _entranceController.forward();
  }

  List<ThoughtPattern> _getThoughtPatternsForEmotion(Emotion emotion) {
    // Generate thought patterns based on the emotion
    final patterns = <ThoughtPattern>[];

    switch (emotion.id.split('_').first) {
      case 'fear':
      case 'apprehension':
      case 'terror':
        patterns.addAll([
          ThoughtPattern(
            id: 'fear_1',
            negativeThought: 'Something terrible is going to happen',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'I don\'t know what will happen, but I can handle uncertainty',
            explanation:
                'Fortune telling assumes we can predict the future, usually negatively.',
          ),
          ThoughtPattern(
            id: 'fear_2',
            negativeThought: 'I can\'t cope with this',
            cognitiveDistortion: 'Underestimation',
            reframedThought:
                'I\'ve coped with difficult things before. I can find ways to manage this.',
            explanation:
                'We often underestimate our ability to handle challenges.',
          ),
          ThoughtPattern(
            id: 'fear_3',
            negativeThought: 'Everyone will notice I\'m anxious',
            cognitiveDistortion: 'Mind Reading',
            reframedThought:
                'Most people are focused on themselves. My anxiety isn\'t as visible as it feels.',
            explanation:
                'We assume others can see our internal state when they usually can\'t.',
          ),
        ]);
        break;

      case 'sadness':
      case 'pensiveness':
      case 'grief':
        patterns.addAll([
          ThoughtPattern(
            id: 'sad_1',
            negativeThought: 'Things will never get better',
            cognitiveDistortion: 'Overgeneralization',
            reframedThought:
                'I feel bad right now, but feelings change. This is temporary.',
            explanation:
                'Overgeneralization extends one moment to all of time.',
          ),
          ThoughtPattern(
            id: 'sad_2',
            negativeThought: 'I\'m a failure',
            cognitiveDistortion: 'Labeling',
            reframedThought:
                'I experienced a setback, but that doesn\'t define my whole self.',
            explanation: 'Labeling reduces complex humans to simple categories.',
          ),
          ThoughtPattern(
            id: 'sad_3',
            negativeThought: 'Nobody understands how I feel',
            cognitiveDistortion: 'All-or-Nothing Thinking',
            reframedThought:
                'Some people may not understand fully, but others might. I can try reaching out.',
            explanation:
                'All-or-nothing thinking sees things in black and white.',
          ),
        ]);
        break;

      case 'anger':
      case 'annoyance':
      case 'rage':
        patterns.addAll([
          ThoughtPattern(
            id: 'anger_1',
            negativeThought: 'They did this on purpose to hurt me',
            cognitiveDistortion: 'Mind Reading',
            reframedThought:
                'I don\'t know their intentions. There might be other explanations.',
            explanation:
                'We assume we know why others act, often attributing negative intent.',
          ),
          ThoughtPattern(
            id: 'anger_2',
            negativeThought: 'This is completely unfair',
            cognitiveDistortion: 'Should Statements',
            reframedThought:
                'I wish this were different. I can accept what is while working to change it.',
            explanation:
                'Should statements create rigid rules about how things must be.',
          ),
          ThoughtPattern(
            id: 'anger_3',
            negativeThought: 'I can\'t let them get away with this',
            cognitiveDistortion: 'Emotional Reasoning',
            reframedThought:
                'I feel wronged, but acting on anger rarely helps. What response serves me best?',
            explanation:
                'Emotional reasoning assumes our feelings reflect reality.',
          ),
        ]);
        break;

      case 'joy':
      case 'serenity':
      case 'ecstasy':
        patterns.addAll([
          ThoughtPattern(
            id: 'joy_1',
            negativeThought: 'This happiness won\'t last',
            cognitiveDistortion: 'Discounting the Positive',
            reframedThought:
                'I can appreciate this moment fully without worrying about the future.',
            explanation: 'Discounting dismisses positive experiences.',
          ),
          ThoughtPattern(
            id: 'joy_2',
            negativeThought: 'I don\'t deserve to feel this good',
            cognitiveDistortion: 'Disqualifying',
            reframedThought:
                'Everyone deserves moments of happiness. I can allow myself this feeling.',
            explanation:
                'Disqualifying rejects positive experiences as not counting.',
          ),
          ThoughtPattern(
            id: 'joy_3',
            negativeThought: 'Something bad will happen to balance this out',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'Life has ups and downs, but good moments don\'t cause bad ones.',
            explanation:
                'This is superstitious thinking disguised as realism.',
          ),
        ]);
        break;

      case 'trust':
      case 'acceptance':
      case 'admiration':
        patterns.addAll([
          ThoughtPattern(
            id: 'trust_1',
            negativeThought: 'They\'ll probably let me down eventually',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'Past betrayals don\'t determine future relationships. I can trust cautiously.',
            explanation:
                'Predicting negative outcomes based on past experiences limits connection.',
          ),
          ThoughtPattern(
            id: 'trust_2',
            negativeThought: 'I\'m being naive for trusting',
            cognitiveDistortion: 'Labeling',
            reframedThought:
                'Trust is a strength, not a weakness. I can be wise and open-hearted.',
            explanation:
                'Labeling trust as naivety prevents healthy vulnerability.',
          ),
          ThoughtPattern(
            id: 'trust_3',
            negativeThought: 'If I trust them completely, I\'ll lose myself',
            cognitiveDistortion: 'All-or-Nothing Thinking',
            reframedThought:
                'Trust doesn\'t mean losing boundaries. I can trust while maintaining my identity.',
            explanation:
                'Black-and-white thinking makes trust feel like surrendering autonomy.',
          ),
        ]);
        break;

      case 'surprise':
      case 'distraction':
      case 'amazement':
        patterns.addAll([
          ThoughtPattern(
            id: 'surprise_1',
            negativeThought: 'I should have seen this coming',
            cognitiveDistortion: 'Should Statements',
            reframedThought:
                'Life is unpredictable. Not anticipating everything doesn\'t mean I failed.',
            explanation:
                'Should statements create unrealistic expectations of control.',
          ),
          ThoughtPattern(
            id: 'surprise_2',
            negativeThought: 'This changes everything in a bad way',
            cognitiveDistortion: 'Jumping to Conclusions',
            reframedThought:
                'Unexpected changes can lead to good outcomes. I can stay curious about what unfolds.',
            explanation:
                'Assuming negative impact before seeing results limits possibility.',
          ),
          ThoughtPattern(
            id: 'surprise_3',
            negativeThought: 'I can\'t handle unexpected situations',
            cognitiveDistortion: 'Underestimation',
            reframedThought:
                'I\'ve adapted to surprises before. I have the flexibility to respond.',
            explanation:
                'We underestimate our capacity for adaptation and resilience.',
          ),
        ]);
        break;

      case 'disgust':
      case 'boredom':
      case 'loathing':
        patterns.addAll([
          ThoughtPattern(
            id: 'disgust_1',
            negativeThought: 'This is completely unacceptable',
            cognitiveDistortion: 'Should Statements',
            reframedThought:
                'I can have strong preferences without requiring the world to match them.',
            explanation:
                'Rigid expectations about how things should be create suffering.',
          ),
          ThoughtPattern(
            id: 'disgust_2',
            negativeThought: 'I need to get away from this immediately',
            cognitiveDistortion: 'Emotional Reasoning',
            reframedThought:
                'My disgust is a signal, but I can choose my response thoughtfully.',
            explanation:
                'Treating feelings as facts can lead to impulsive reactions.',
          ),
          ThoughtPattern(
            id: 'disgust_3',
            negativeThought: 'This completely ruins everything',
            cognitiveDistortion: 'Magnification',
            reframedThought:
                'This is unpleasant, but it doesn\'t define the whole experience.',
            explanation:
                'Magnification makes single negative elements overshadow everything else.',
          ),
        ]);
        break;

      case 'anticipation':
      case 'interest':
      case 'vigilance':
        patterns.addAll([
          ThoughtPattern(
            id: 'anticipation_1',
            negativeThought: 'I need to know exactly what will happen',
            cognitiveDistortion: 'Need for Certainty',
            reframedThought:
                'Uncertainty is uncomfortable but natural. I can move forward without all answers.',
            explanation:
                'Demanding certainty in an uncertain world creates constant anxiety.',
          ),
          ThoughtPattern(
            id: 'anticipation_2',
            negativeThought: 'If I don\'t prepare for every possibility, something will go wrong',
            cognitiveDistortion: 'Catastrophizing',
            reframedThought:
                'Reasonable preparation is enough. I can handle unexpected challenges as they arise.',
            explanation:
                'Over-preparation based on catastrophic thinking is exhausting and often unnecessary.',
          ),
          ThoughtPattern(
            id: 'anticipation_3',
            negativeThought: 'I can\'t relax until this is over',
            cognitiveDistortion: 'All-or-Nothing Thinking',
            reframedThought:
                'I can be both prepared and present. Anticipation doesn\'t require constant tension.',
            explanation:
                'Black-and-white thinking makes us choose between vigilance and peace.',
          ),
        ]);
        break;

      case 'love':
        patterns.addAll([
          ThoughtPattern(
            id: 'love_1',
            negativeThought: 'I\'m being too vulnerable',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'Vulnerability is the gateway to connection. I can be open while honoring my boundaries.',
            explanation:
                'Predicting hurt prevents us from experiencing deep connection.',
          ),
          ThoughtPattern(
            id: 'love_2',
            negativeThought: 'If this ends, I won\'t survive',
            cognitiveDistortion: 'Catastrophizing',
            reframedThought:
                'Love is precious, but I am whole with or without it. I can cherish this while trusting my resilience.',
            explanation:
                'Making love our entire foundation creates fragility rather than strength.',
          ),
          ThoughtPattern(
            id: 'love_3',
            negativeThought: 'I need them to complete me',
            cognitiveDistortion: 'External Validation',
            reframedThought:
                'Love enhances my life, but my worth isn\'t dependent on it. I can give and receive from wholeness.',
            explanation:
                'Seeking completion through others creates dependency rather than partnership.',
          ),
        ]);
        break;

      case 'submission':
        patterns.addAll([
          ThoughtPattern(
            id: 'submission_1',
            negativeThought: 'My needs don\'t matter as much as theirs',
            cognitiveDistortion: 'Minimization',
            reframedThought:
                'I can honor others\' needs while valuing my own. Both matter equally.',
            explanation:
                'Minimizing our needs leads to resentment and loss of self.',
          ),
          ThoughtPattern(
            id: 'submission_2',
            negativeThought: 'If I assert myself, they\'ll reject me',
            cognitiveDistortion: 'Mind Reading',
            reframedThought:
                'I don\'t know how they\'ll respond. Healthy relationships allow both voices.',
            explanation:
                'Assuming rejection prevents authentic expression and growth.',
          ),
          ThoughtPattern(
            id: 'submission_3',
            negativeThought: 'It\'s safer to just go along',
            cognitiveDistortion: 'Emotional Reasoning',
            reframedThought:
                'Short-term comfort isn\'t the same as safety. I can find courage to be authentic.',
            explanation:
                'Following fear limits growth and breeds quiet resentment.',
          ),
        ]);
        break;

      case 'awe':
        patterns.addAll([
          ThoughtPattern(
            id: 'awe_1',
            negativeThought: 'I\'m too small and insignificant',
            cognitiveDistortion: 'Magnification/Minimization',
            reframedThought:
                'Being part of something vast doesn\'t make me insignificant. Both can be true.',
            explanation:
                'Awe can trigger self-diminishment, but we can be both humble and valuable.',
          ),
          ThoughtPattern(
            id: 'awe_2',
            negativeThought: 'I\'ll never achieve anything this meaningful',
            cognitiveDistortion: 'Comparison',
            reframedThought:
                'Greatness takes many forms. I can be inspired without diminishing my own path.',
            explanation:
                'Comparing our beginning to someone else\'s mastery steals our joy.',
          ),
          ThoughtPattern(
            id: 'awe_3',
            negativeThought: 'This feeling is too intense, I need to shut down',
            cognitiveDistortion: 'Emotional Avoidance',
            reframedThought:
                'Big emotions are safe to feel. I can stay present with this expansive feeling.',
            explanation:
                'Fearing intensity causes us to numb ourselves to wonder and beauty.',
          ),
        ]);
        break;

      case 'disapproval':
        patterns.addAll([
          ThoughtPattern(
            id: 'disapproval_1',
            negativeThought: 'They should know better',
            cognitiveDistortion: 'Should Statements',
            reframedThought:
                'People act from their own understanding. I can disagree without demanding they change.',
            explanation:
                'Should statements about others create frustration and judgment.',
          ),
          ThoughtPattern(
            id: 'disapproval_2',
            negativeThought: 'Their choice reflects badly on me',
            cognitiveDistortion: 'Personalization',
            reframedThought:
                'Others\' actions are about them, not me. I can separate my worth from their choices.',
            explanation:
                'Taking responsibility for others\' behavior burdens us unnecessarily.',
          ),
          ThoughtPattern(
            id: 'disapproval_3',
            negativeThought: 'I need to correct them immediately',
            cognitiveDistortion: 'Emotional Reasoning',
            reframedThought:
                'My disapproval is valid, but I can choose when and how to respond.',
            explanation:
                'Acting on every negative feeling can damage relationships unnecessarily.',
          ),
        ]);
        break;

      case 'remorse':
        patterns.addAll([
          ThoughtPattern(
            id: 'remorse_1',
            negativeThought: 'I\'m a terrible person for what I did',
            cognitiveDistortion: 'Labeling',
            reframedThought:
                'I made a mistake, but that doesn\'t define my entire character. I can learn and grow.',
            explanation:
                'Labeling ourselves based on actions prevents growth and self-compassion.',
          ),
          ThoughtPattern(
            id: 'remorse_2',
            negativeThought: 'I can never make up for this',
            cognitiveDistortion: 'All-or-Nothing Thinking',
            reframedThought:
                'Making amends is a process, not perfection. I can take meaningful steps forward.',
            explanation:
                'Black-and-white thinking makes repair feel impossible.',
          ),
          ThoughtPattern(
            id: 'remorse_3',
            negativeThought: 'Everyone will judge me forever',
            cognitiveDistortion: 'Overgeneralization',
            reframedThought:
                'People can forgive and move forward. I deserve the same compassion I\'d offer others.',
            explanation:
                'Extending one mistake across all time and people magnifies pain.',
          ),
        ]);
        break;

      case 'contempt':
        patterns.addAll([
          ThoughtPattern(
            id: 'contempt_1',
            negativeThought: 'They\'re beneath me',
            cognitiveDistortion: 'Superiority Complex',
            reframedThought:
                'Everyone has inherent worth, including those I disagree with. I can maintain boundaries without dehumanizing.',
            explanation:
                'Contempt creates separation and prevents understanding.',
          ),
          ThoughtPattern(
            id: 'contempt_2',
            negativeThought: 'They deserve whatever happens to them',
            cognitiveDistortion: 'Just-World Fallacy',
            reframedThought:
                'Life isn\'t always fair. I can hold people accountable without wishing them harm.',
            explanation:
                'Believing people deserve suffering hardens us and prevents compassion.',
          ),
          ThoughtPattern(
            id: 'contempt_3',
            negativeThought: 'Nothing they do will ever change my mind',
            cognitiveDistortion: 'Mental Filtering',
            reframedThought:
                'People can grow and change. I can stay open to evidence of transformation.',
            explanation:
                'Filtering out positive changes keeps us stuck in old narratives.',
          ),
        ]);
        break;

      case 'aggressiveness':
        patterns.addAll([
          ThoughtPattern(
            id: 'aggressiveness_1',
            negativeThought: 'I need to dominate this situation or I\'ll lose',
            cognitiveDistortion: 'All-or-Nothing Thinking',
            reframedThought:
                'Not every interaction is win-lose. I can be assertive without being aggressive.',
            explanation:
                'Zero-sum thinking makes every situation feel like a battle.',
          ),
          ThoughtPattern(
            id: 'aggressiveness_2',
            negativeThought: 'Showing any weakness will be exploited',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'Authenticity isn\'t weakness. I can be strong and real simultaneously.',
            explanation:
                'Predicting exploitation keeps us in defensive, exhausting postures.',
          ),
          ThoughtPattern(
            id: 'aggressiveness_3',
            negativeThought: 'I have to strike first before they do',
            cognitiveDistortion: 'Mind Reading',
            reframedThought:
                'I don\'t know their intentions. I can be prepared without being preemptively aggressive.',
            explanation:
                'Assuming hostile intent creates conflicts that might not have existed.',
          ),
        ]);
        break;

      case 'optimism':
        patterns.addAll([
          ThoughtPattern(
            id: 'optimism_1',
            negativeThought: 'I\'m setting myself up for disappointment',
            cognitiveDistortion: 'Fortune Telling',
            reframedThought:
                'Hope is valuable even if outcomes vary. I can be optimistic while accepting uncertainty.',
            explanation:
                'Predicting disappointment to avoid pain also prevents joy.',
          ),
          ThoughtPattern(
            id: 'optimism_2',
            negativeThought: 'I\'m being unrealistic',
            cognitiveDistortion: 'Disqualifying the Positive',
            reframedThought:
                'Optimism based on effort and possibility is different from denial. I can see clearly and still hope.',
            explanation:
                'Dismissing positive outlook as naive limits our motivation and energy.',
          ),
          ThoughtPattern(
            id: 'optimism_3',
            negativeThought: 'Good things don\'t happen to people like me',
            cognitiveDistortion: 'Personalization',
            reframedThought:
                'Everyone deserves good outcomes. My past doesn\'t limit my future possibilities.',
            explanation:
                'Creating a fixed story about our worthiness becomes self-fulfilling.',
          ),
        ]);
        break;

      default:
        // Generic patterns for other emotions
        patterns.addAll([
          ThoughtPattern(
            id: 'gen_1',
            negativeThought: 'I shouldn\'t feel this way',
            cognitiveDistortion: 'Should Statements',
            reframedThought:
                'All emotions are valid. I can accept how I feel while choosing my response.',
            explanation:
                'Telling ourselves how we should feel adds suffering to suffering.',
          ),
          ThoughtPattern(
            id: 'gen_2',
            negativeThought: 'This feeling is too much to handle',
            cognitiveDistortion: 'Catastrophizing',
            reframedThought:
                'This feeling is intense but temporary. I can ride this wave.',
            explanation: 'Catastrophizing makes things seem more overwhelming.',
          ),
          ThoughtPattern(
            id: 'gen_3',
            negativeThought: 'There must be something wrong with me',
            cognitiveDistortion: 'Personalization',
            reframedThought:
                'Feeling emotions means I\'m human. This experience is part of being alive.',
            explanation: 'Personalization turns normal experiences into flaws.',
          ),
        ]);
    }

    return patterns;
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
    _cardController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_swipeOffset.abs() > threshold) {
      // Successful swipe
      HapticFeedback.mediumImpact();
      if (!_showingReframe) {
        // Swiped away negative thought - show reframe
        setState(() {
          _showingReframe = true;
        });
      } else {
        // Swiped away reframe - mark as complete and move to next
        _completeCard();
      }
    }

    // Reset swipe
    setState(() {
      _swipeOffset = 0.0;
    });
  }

  void _completeCard() {
    setState(() {
      _score += 10 + (_streak * 5);
      _streak++;
    });

    _successController.forward(from: 0.0);

    // Move to next pattern after animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentIndex < _thoughtPatterns.length - 1) {
        setState(() {
          _currentIndex++;
          _showingReframe = false;
        });
      } else {
        setState(() {
          _completed = true;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _skipCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _streak = 0;
      if (!_showingReframe) {
        _showingReframe = true;
      } else if (_currentIndex < _thoughtPatterns.length - 1) {
        _currentIndex++;
        _showingReframe = false;
      } else {
        _completed = true;
      }
    });
  }

  void _proceedToNextPhase() {
    HapticFeedback.mediumImpact();
    context.push(
      '/reflection',
      extra: {
        'emotion': widget.emotion,
        'bodyMapData': widget.bodyMapData,
        'cbtScore': _score,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                    child: _completed ? _buildCompleteScreen() : _buildGameScreen(),
                  ),
                ),

                // Footer
                FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: _buildFooter(),
                ),
              ],
            );
          },
        ),
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
                  'Cognitive Reframe',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Score display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + (_showingReframe ? 0.5 : 0)) /
                      _thoughtPatterns.length,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation(widget.emotion.color),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentIndex + 1}/${_thoughtPatterns.length}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          if (_streak > 1) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak streak!',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final currentPattern = _thoughtPatterns[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Instructions
          Text(
            _showingReframe
                ? 'Here\'s a healthier perspective:'
                : 'Swipe away this unhelpful thought:',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Thought card
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.translate(
                  offset: Offset(_swipeOffset, 0),
                  child: Transform.rotate(
                    angle: _swipeOffset * 0.001,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showingReframe
                          ? _buildReframeCard(currentPattern)
                          : _buildNegativeThoughtCard(currentPattern),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Swipe hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, color: AppColors.textTertiary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Swipe left or right to continue',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Skip button
          TextButton(
            onPressed: _skipCard,
            child: Text(
              'Skip this one',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegativeThoughtCard(ThoughtPattern pattern) {
    return Container(
      key: ValueKey('negative_${pattern.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Distortion badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pattern.cognitiveDistortion,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Negative thought
          Icon(
            Icons.format_quote,
            color: AppColors.error.withValues(alpha: 0.5),
            size: 32,
          ),

          const SizedBox(height: 12),

          Text(
            pattern.negativeThought,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Explanation
          Text(
            pattern.explanation,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReframeCard(ThoughtPattern pattern) {
    return Container(
      key: ValueKey('reframe_${pattern.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Reframed Thought',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Icon(
            Icons.format_quote,
            color: AppColors.success.withValues(alpha: 0.5),
            size: 32,
          ),

          const SizedBox(height: 12),

          Text(
            pattern.reframedThought,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Points indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  '+${10 + (_streak * 5)} points',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Trophy icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.warning.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 60,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Reframing Complete!',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Score summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.star,
                  value: '$_score',
                  label: 'Points',
                  color: AppColors.primary,
                ),
                _StatItem(
                  icon: Icons.psychology,
                  value: '${_thoughtPatterns.length}',
                  label: 'Reframes',
                  color: AppColors.success,
                ),
                _StatItem(
                  icon: Icons.local_fire_department,
                  value: '$_streak',
                  label: 'Best Streak',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'You\'ve practiced identifying cognitive distortions and '
            'reframing negative thoughts related to ${widget.emotion.name.toLowerCase()}. '
            'This skill gets stronger with practice.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          AppButton(
            onPressed: _proceedToNextPhase,
            label: 'Continue to Reflection',
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _buildPhaseIndicator(),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PhaseIndicator(phase: 1, isActive: false, isComplete: true, label: 'Compass'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 2, isActive: false, isComplete: true, label: 'Body Map'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 3, isActive: false, isComplete: true, label: 'Scan'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 4, isActive: !_completed, isComplete: _completed, label: 'Reframe'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 5, isActive: false, isComplete: false, label: 'Reflect'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
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
