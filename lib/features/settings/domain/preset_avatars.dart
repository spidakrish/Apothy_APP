import 'package:flutter/material.dart';

/// Preset avatar for user profile
/// Per Damien's spec: "non-human, non-sentient artwork"
/// These are abstract/celestial/nature themed avatars
class PresetAvatar {
  const PresetAvatar({
    required this.id,
    required this.name,
    required this.gradientColors,
    required this.icon,
  });

  /// Unique identifier for the avatar (stored in photoUrl as "preset:id")
  final String id;

  /// Human-readable name for the avatar
  final String name;

  /// Gradient colors for the avatar background
  final List<Color> gradientColors;

  /// Icon to display on the avatar
  final IconData icon;

  /// Creates the gradient for this avatar
  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      );

  /// Converts to photoUrl format for storage
  String toPhotoUrl() => 'preset:$id';

  /// Checks if a photoUrl is a preset avatar
  static bool isPresetUrl(String? photoUrl) {
    return photoUrl != null && photoUrl.startsWith('preset:');
  }

  /// Extracts preset ID from photoUrl
  static String? extractPresetId(String? photoUrl) {
    if (photoUrl == null || !photoUrl.startsWith('preset:')) {
      return null;
    }
    return photoUrl.substring(7); // Remove 'preset:' prefix
  }

  /// Gets a preset avatar by ID
  static PresetAvatar? fromId(String id) {
    try {
      return presetAvatars.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets a preset avatar from photoUrl
  static PresetAvatar? fromPhotoUrl(String? photoUrl) {
    final id = extractPresetId(photoUrl);
    if (id == null) return null;
    return fromId(id);
  }
}

/// Available preset avatars
/// Themed around celestial bodies, nature elements, and abstract concepts
/// All non-human, non-sentient per spec
const List<PresetAvatar> presetAvatars = [
  // Celestial themes
  PresetAvatar(
    id: 'aurora',
    name: 'Aurora',
    gradientColors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    icon: Icons.auto_awesome,
  ),
  PresetAvatar(
    id: 'cosmos',
    name: 'Cosmos',
    gradientColors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    icon: Icons.stars,
  ),
  PresetAvatar(
    id: 'nebula',
    name: 'Nebula',
    gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    icon: Icons.blur_on,
  ),
  PresetAvatar(
    id: 'moonlight',
    name: 'Moonlight',
    gradientColors: [Color(0xFF6366F1), Color(0xFF1E1B4B)],
    icon: Icons.nightlight_round,
  ),
  PresetAvatar(
    id: 'sunrise',
    name: 'Sunrise',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    icon: Icons.wb_twilight,
  ),
  PresetAvatar(
    id: 'ocean',
    name: 'Ocean',
    gradientColors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
    icon: Icons.waves,
  ),

  // Nature/Element themes
  PresetAvatar(
    id: 'forest',
    name: 'Forest',
    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
    icon: Icons.park,
  ),
  PresetAvatar(
    id: 'crystal',
    name: 'Crystal',
    gradientColors: [Color(0xFFA78BFA), Color(0xFFF0ABFC)],
    icon: Icons.diamond,
  ),
  PresetAvatar(
    id: 'ember',
    name: 'Ember',
    gradientColors: [Color(0xFFEF4444), Color(0xFFF97316)],
    icon: Icons.local_fire_department,
  ),
  PresetAvatar(
    id: 'storm',
    name: 'Storm',
    gradientColors: [Color(0xFF475569), Color(0xFF1E293B)],
    icon: Icons.bolt,
  ),

  // Abstract themes
  PresetAvatar(
    id: 'prism',
    name: 'Prism',
    gradientColors: [Color(0xFFF472B6), Color(0xFF818CF8)],
    icon: Icons.change_history,
  ),
  PresetAvatar(
    id: 'void',
    name: 'Void',
    gradientColors: [Color(0xFF1F1F24), Color(0xFF0A0A0F)],
    icon: Icons.brightness_2,
  ),
];

/// Default avatar when none is selected
const PresetAvatar defaultAvatar = PresetAvatar(
  id: 'default',
  name: 'Default',
  gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  icon: Icons.person,
);
