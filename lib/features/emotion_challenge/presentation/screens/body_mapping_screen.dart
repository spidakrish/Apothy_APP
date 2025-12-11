import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/emotion.dart';
import '../widgets/body_map.dart';

/// Phase 2: Body Sensation Mapping
///
/// Users paint on a body silhouette to mark where they feel
/// the selected emotion. Supports different intensities and
/// provides insights based on the mapping.
class BodyMappingScreen extends StatefulWidget {
  const BodyMappingScreen({
    super.key,
    required this.emotion,
  });

  /// The emotion selected in Phase 1
  final Emotion emotion;

  @override
  State<BodyMappingScreen> createState() => _BodyMappingScreenState();
}

class _BodyMappingScreenState extends State<BodyMappingScreen>
    with TickerProviderStateMixin {
  // Body map data
  BodyMapData? _bodyMapData;

  // Brush intensity (0.0 - 1.0)
  double _brushIntensity = 0.7;

  // Animation controllers
  late AnimationController _entranceController;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _bodyFadeAnimation;
  late Animation<double> _bodyScaleAnimation;
  late Animation<double> _footerFadeAnimation;

  // Key for body map to force rebuild on clear
  final GlobalKey<BodyMapState> _bodyMapKey = GlobalKey<BodyMapState>();

  @override
  void initState() {
    super.initState();

    _bodyMapData = BodyMapData.empty(widget.emotion);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _setupAnimations();
    _entranceController.forward();
  }

  void _setupAnimations() {
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _bodyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    _bodyScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onMapUpdated(BodyMapData data) {
    setState(() {
      _bodyMapData = data;
    });
  }

  void _clearMap() {
    HapticFeedback.mediumImpact();
    _bodyMapKey.currentState?.clearMap();
  }

  void _proceedToNextPhase() {
    if (_bodyMapData == null || _bodyMapData!.points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please mark where you feel this emotion',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    // Navigate to Phase 3 (Somatic Scan) with body map data
    // For now, we'll pass the data through the route
    context.push(
      '/somatic-scan',
      extra: {
        'emotion': widget.emotion,
        'bodyMapData': _bodyMapData,
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

                // Body map
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFadeAnimation,
                    child: ScaleTransition(
                      scale: _bodyScaleAnimation,
                      child: _buildBodyMap(),
                    ),
                  ),
                ),

                // Intensity slider and controls
                FadeTransition(
                  opacity: _footerFadeAnimation,
                  child: _buildControls(),
                ),

                // Footer
                FadeTransition(
                  opacity: _footerFadeAnimation,
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
                  'Body Mapping',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _clearMap,
                tooltip: 'Clear map',
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Emotion indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.emotion.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.emotion.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.emotion.color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mapping: ${widget.emotion.name}',
                  style: AppTypography.labelMedium.copyWith(
                    color: widget.emotion.color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Where do you feel this emotion?',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Tap or drag on the body to mark sensations',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMap() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: AspectRatio(
          aspectRatio: 0.5, // Tall body shape
          child: BodyMap(
            key: _bodyMapKey,
            emotion: widget.emotion,
            brushIntensity: _brushIntensity,
            onMapUpdated: _onMapUpdated,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Intensity slider
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Intensity',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: widget.emotion.color,
                    inactiveTrackColor:
                        widget.emotion.color.withValues(alpha: 0.2),
                    thumbColor: widget.emotion.color,
                    overlayColor: widget.emotion.color.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _brushIntensity,
                    min: 0.2,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _brushIntensity = value;
                      });
                    },
                  ),
                ),
              ),
              Icon(
                Icons.water_drop,
                color: widget.emotion.color,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Insight text
          if (_bodyMapData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle,
                ),
              ),
              child: Text(
                _bodyMapData!.generateInsight(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final hasPoints = _bodyMapData != null && _bodyMapData!.points.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            onPressed: _proceedToNextPhase,
            label: hasPoints ? 'Continue to Somatic Scan' : 'Mark sensations to continue',
            variant: hasPoints ? AppButtonVariant.primary : AppButtonVariant.outlined,
            width: double.infinity,
          ),

          const SizedBox(height: 12),

          // Phase indicator
          _buildPhaseIndicator(),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PhaseIndicator(phase: 1, isActive: false, isComplete: true, label: 'Compass'),
        _PhaseConnector(isComplete: true),
        _PhaseIndicator(phase: 2, isActive: true, isComplete: false, label: 'Body Map'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 3, isActive: false, isComplete: false, label: 'Scan'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 4, isActive: false, isComplete: false, label: 'Reframe'),
        _PhaseConnector(isComplete: false),
        _PhaseIndicator(phase: 5, isActive: false, isComplete: false, label: 'Reflect'),
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
