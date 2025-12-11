import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/emotion.dart';
import '../widgets/body_map.dart';

/// Phase 3: Somatic Scan
///
/// A guided body awareness meditation that focuses on the areas
/// the user marked in Phase 2. Includes breathing guidance and
/// progressive relaxation prompts.
class SomaticScanScreen extends StatefulWidget {
  const SomaticScanScreen({
    super.key,
    required this.emotion,
    required this.bodyMapData,
  });

  final Emotion emotion;
  final BodyMapData bodyMapData;

  @override
  State<SomaticScanScreen> createState() => _SomaticScanScreenState();
}

class _SomaticScanScreenState extends State<SomaticScanScreen>
    with TickerProviderStateMixin {
  // Scan state
  bool _isScanning = false;
  bool _scanComplete = false;
  int _currentStepIndex = 0;

  // Breathing state
  bool _isInhaling = true;
  int _breathCount = 0;
  static const int _breathsPerStep = 3;

  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _breathingAnimation;

  // Scan steps based on body map regions
  late List<_ScanStep> _scanSteps;

  // Timer for scan progression
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    _buildScanSteps();

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Breathing circle animation with emotion-specific duration
    final breathingParams = _getBreathingParams();
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: breathingParams.duration),
    );

    // Pulse animation for active region
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _setupAnimations();
    _entranceController.forward();
  }

  /// Get emotion-specific breathing parameters
  _BreathingParams _getBreathingParams() {
    return switch (widget.emotion.id.split('_').first) {
      'fear' || 'apprehension' || 'terror' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Breathe slowly and deeply to calm your nervous system',
          inhaleText: 'Breathe in safety',
          exhaleText: 'Release the fear',
        ),
      'anger' || 'annoyance' || 'rage' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Use cooling breaths to settle the heat of anger',
          inhaleText: 'Breathe in calm',
          exhaleText: 'Release the fire',
        ),
      'sadness' || 'pensiveness' || 'grief' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Breathe with gentle compassion for your heart',
          inhaleText: 'Breathe in warmth',
          exhaleText: 'Let sorrow flow',
        ),
      'joy' || 'serenity' || 'ecstasy' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Let your breath flow naturally with this lightness',
          inhaleText: 'Breathe in gratitude',
          exhaleText: 'Spread the joy',
        ),
      'trust' || 'acceptance' || 'admiration' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Breathe into the openness of connection',
          inhaleText: 'Breathe in openness',
          exhaleText: 'Release doubt',
        ),
      'surprise' || 'distraction' || 'amazement' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Ground yourself with steady breaths',
          inhaleText: 'Breathe in presence',
          exhaleText: 'Settle into now',
        ),
      'disgust' || 'boredom' || 'loathing' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Cleanse with clear, decisive breaths',
          inhaleText: 'Breathe in freshness',
          exhaleText: 'Release aversion',
        ),
      'anticipation' || 'interest' || 'vigilance' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Find stillness amidst the expectation',
          inhaleText: 'Breathe in patience',
          exhaleText: 'Ease the tension',
        ),
      'love' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Breathe with the fullness of an open heart',
          inhaleText: 'Breathe in love',
          exhaleText: 'Share the warmth',
        ),
      'submission' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Reclaim your power with intentional breaths',
          inhaleText: 'Breathe in strength',
          exhaleText: 'Release smallness',
        ),
      'awe' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Expand into the vastness with full breaths',
          inhaleText: 'Breathe in wonder',
          exhaleText: 'Embrace vastness',
        ),
      'disapproval' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Soften judgment with compassionate breaths',
          inhaleText: 'Breathe in acceptance',
          exhaleText: 'Release judgment',
        ),
      'remorse' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Breathe with self-compassion and forgiveness',
          inhaleText: 'Breathe in kindness',
          exhaleText: 'Release shame',
        ),
      'contempt' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Find humanity in yourself and others through breath',
          inhaleText: 'Breathe in humility',
          exhaleText: 'Release superiority',
        ),
      'aggressiveness' =>
        _BreathingParams(
          duration: 5,
          instruction: 'Channel intensity into grounded, powerful breaths',
          inhaleText: 'Breathe in control',
          exhaleText: 'Release aggression',
        ),
      'optimism' =>
        _BreathingParams(
          duration: 4,
          instruction: 'Let hope flow naturally with each breath',
          inhaleText: 'Breathe in possibility',
          exhaleText: 'Trust the process',
        ),
      _ =>
        _BreathingParams(
          duration: 4,
          instruction: 'Notice how this emotion moves with your breath',
          inhaleText: 'Breathe in awareness',
          exhaleText: 'Release resistance',
        ),
    };
  }

  void _buildScanSteps() {
    final regions = widget.bodyMapData.affectedRegions;

    if (regions.isEmpty) {
      // Default steps if no regions marked
      _scanSteps = [
        _ScanStep(
          region: 'body',
          instruction: 'Let\'s begin by noticing your whole body',
          guidance: 'Feel the weight of your body. Notice where you feel most grounded.',
        ),
        _ScanStep(
          region: 'breath',
          instruction: 'Bring attention to your breath',
          guidance: 'Notice how your breath moves through your body naturally.',
        ),
        _ScanStep(
          region: 'release',
          instruction: 'Release any tension you find',
          guidance: 'With each exhale, let go a little more.',
        ),
      ];
    } else {
      _scanSteps = [
        _ScanStep(
          region: 'opening',
          instruction: 'Begin with a deep breath',
          guidance: 'Close your eyes if comfortable. Let your body settle.',
        ),
        ...regions.map((region) => _ScanStep(
              region: region,
              instruction: 'Notice your $region',
              guidance: _getGuidanceForRegion(region),
            )),
        _ScanStep(
          region: 'integration',
          instruction: 'Bring it all together',
          guidance:
              'Notice how ${widget.emotion.name.toLowerCase()} feels throughout your body now.',
        ),
        _ScanStep(
          region: 'release',
          instruction: 'Gently release',
          guidance:
              'Thank your body for this awareness. Take one final deep breath.',
        ),
      ];
    }
  }

  String _getGuidanceForRegion(String region) {
    final emotion = widget.emotion.name.toLowerCase();
    return switch (region) {
      'head' =>
        'Notice any sensations in your head. Is there tension, warmth, or pressure? '
            'Just observe without trying to change anything.',
      'neck' =>
        'Bring awareness to your neck. Feel where $emotion might be stored here. '
            'Let your neck soften with each breath.',
      'shoulders' =>
        'Notice your shoulders. Are they raised or relaxed? '
            'Feel the weight of any $emotion you carry here.',
      'chest' =>
        'Place your attention on your chest. Notice your heartbeat. '
            'How does $emotion manifest in this area?',
      'stomach' =>
        'Bring awareness to your stomach. Notice any butterflies, tightness, or warmth. '
            'This is where many emotions are felt strongly.',
      'lower abdomen' =>
        'Focus on your lower abdomen. Breathe deeply into this space. '
            'Notice any sensations related to $emotion.',
      'arms' =>
        'Notice your arms from shoulders to fingertips. '
            'Do you feel the urge to reach out, pull back, or protect?',
      'hands' =>
        'Bring attention to your hands. Notice if they\'re tense or relaxed. '
            'Hands often hold emotional tension we don\'t notice.',
      'legs' =>
        'Feel your legs. Notice if they feel heavy, light, restless, or grounded. '
            '$emotion can affect how rooted we feel.',
      'feet' =>
        'Finally, notice your feet. Feel the connection to the ground. '
            'This is your foundation. Let it support you.',
      _ =>
        'Notice this area of your body. What sensations arise? '
            'Simply observe with curiosity and compassion.',
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

    _breathingAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _entranceController.dispose();
    _breathingController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startScan() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isScanning = true;
      _currentStepIndex = 0;
      _breathCount = 0;
    });

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    // Subtle haptic on inhale start
    HapticFeedback.selectionClick();

    _breathingController.forward().then((_) {
      setState(() {
        _isInhaling = false;
      });
      // Subtle haptic on exhale start
      HapticFeedback.selectionClick();

      _breathingController.reverse().then((_) {
        setState(() {
          _isInhaling = true;
          _breathCount++;
        });

        // Check if we should move to next step
        if (_breathCount >= _breathsPerStep) {
          _nextStep();
        } else if (_isScanning && !_scanComplete) {
          // Continue breathing
          _startBreathingCycle();
        }
      });
    });
  }

  void _nextStep() {
    // Medium haptic when transitioning between body regions
    HapticFeedback.mediumImpact();

    if (_currentStepIndex < _scanSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _breathCount = 0;
      });
      _startBreathingCycle();
    } else {
      // Scan complete - strong haptic for completion
      setState(() {
        _scanComplete = true;
        _isScanning = false;
      });
      HapticFeedback.heavyImpact();
      // Second haptic for celebration effect
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  void _proceedToNextPhase() {
    HapticFeedback.mediumImpact();
    context.push(
      '/cognitive-reframe',
      extra: {
        'emotion': widget.emotion,
        'bodyMapData': widget.bodyMapData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background glow
          _buildAmbientBackground(),

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
                        child: _buildContent(),
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
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                widget.emotion.color.withValues(alpha: 0.05 + _glowController.value * 0.03),
                AppColors.background,
              ],
            ),
          ),
        );
      },
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
                  _scanTimer?.cancel();
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
                  'Somatic Scan',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),

          const SizedBox(height: 8),

          // Progress indicator
          if (_isScanning || _scanComplete)
            LinearProgressIndicator(
              value: _scanComplete
                  ? 1.0
                  : (_currentStepIndex + 1) / _scanSteps.length,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(widget.emotion.color),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_isScanning && !_scanComplete) {
      return _buildStartScreen();
    } else if (_scanComplete) {
      return _buildCompleteScreen();
    } else {
      return _buildScanningScreen();
    }
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Breathing circle preview
          _BreathingCircle(
            animation: _breathingController,
            color: widget.emotion.color,
            size: 180,
            isActive: false,
          ),

          const SizedBox(height: 32),

          Text(
            'Guided Body Scan',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Based on your body map, we\'ll guide your attention '
            'through ${widget.bodyMapData.affectedRegions.length} areas '
            'where you feel ${widget.emotion.name.toLowerCase()}.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Duration: ~${_scanSteps.length * _breathsPerStep * 8 ~/ 60} minutes',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 32),

          AppButton(
            onPressed: _startScan,
            label: 'Begin Scan',
            icon: Icons.play_arrow,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningScreen() {
    final currentStep = _scanSteps[_currentStepIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step indicator
          Text(
            'Step ${_currentStepIndex + 1} of ${_scanSteps.length}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 24),

          // Breathing circle
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return _BreathingCircle(
                animation: _breathingController,
                color: widget.emotion.color,
                size: 200,
                isActive: true,
                isInhaling: _isInhaling,
              );
            },
          ),

          const SizedBox(height: 8),

          // Breath instruction
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isInhaling ? 'Breathe in...' : 'Breathe out...',
              key: ValueKey(_isInhaling),
              style: AppTypography.bodyLarge.copyWith(
                color: widget.emotion.color,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Instruction
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              currentStep.instruction,
              key: ValueKey(currentStep.region),
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Guidance
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey('${currentStep.region}_guidance'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentStep.guidance,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Skip step button
          TextButton(
            onPressed: _nextStep,
            child: Text(
              'Skip to next →',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteScreen() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Completion icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.success, width: 3),
            ),
            child: Icon(
              Icons.check,
              color: AppColors.success,
              size: 60,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Scan Complete',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'You\'ve brought mindful attention to how '
            '${widget.emotion.name.toLowerCase()} feels in your body. '
            'This awareness is the first step to understanding and '
            'working with your emotions.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          AppButton(
            onPressed: _proceedToNextPhase,
            label: 'Continue to Reframe',
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
        _PhaseIndicator(phase: 3, isActive: !_scanComplete, isComplete: _scanComplete, label: 'Scan'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 4, isActive: false, isComplete: false, label: 'Reframe'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 5, isActive: false, isComplete: false, label: 'Reflect'),
      ],
    );
  }
}

/// Breathing circle widget
class _BreathingCircle extends StatelessWidget {
  const _BreathingCircle({
    required this.animation,
    required this.color,
    required this.size,
    required this.isActive,
    this.isInhaling = true,
  });

  final Animation<double> animation;
  final Color color;
  final double size;
  final bool isActive;
  final bool isInhaling;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = isActive ? (0.7 + animation.value * 0.3) : 0.85;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isActive ? 0.4 : 0.2),
                blurRadius: isActive ? 40 + animation.value * 20 : 20,
                spreadRadius: isActive ? 10 + animation.value * 10 : 5,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.6),
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A step in the somatic scan
class _ScanStep {
  const _ScanStep({
    required this.region,
    required this.instruction,
    required this.guidance,
  });

  final String region;
  final String instruction;
  final String guidance;
}

/// Emotion-specific breathing parameters
class _BreathingParams {
  const _BreathingParams({
    required this.duration,
    required this.instruction,
    required this.inhaleText,
    required this.exhaleText,
  });

  final int duration; // seconds per breath cycle
  final String instruction; // Overall breathing instruction
  final String inhaleText; // Text to show during inhale
  final String exhaleText; // Text to show during exhale
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
