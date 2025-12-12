#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// AI-powered translation script for Apothy app
///
/// Usage: `dart tool/generate_translations.dart <feature_name>`
/// Example: `dart tool/generate_translations.dart app`
///
/// Requires: ANTHROPIC_API_KEY environment variable
void main(List<String> args) async {
  // Validate arguments
  if (args.isEmpty) {
    printError('Usage: dart tool/generate_translations.dart <feature_name>');
    printError('Example: dart tool/generate_translations.dart app');
    exit(1);
  }

  final featureName = args[0];
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    printError('ANTHROPIC_API_KEY environment variable is not set');
    printError('Export your API key: export ANTHROPIC_API_KEY=your_key_here');
    exit(1);
  }

  // Define paths
  final arbDir = 'lib/l10n';
  final sourceFile = '$arbDir/${featureName}_en.arb';

  // Validate source file exists
  if (!File(sourceFile).existsSync()) {
    printError('Source file not found: $sourceFile');
    exit(1);
  }

  printInfo('Reading source file: $sourceFile');

  // Read and parse source file
  final sourceContent = File(sourceFile).readAsStringSync();
  final sourceJson = jsonDecode(sourceContent) as Map<String, dynamic>;

  // Extract translatable strings (exclude @ metadata)
  final translatableStrings = <String, String>{};
  final metadata = <String, dynamic>{};

  sourceJson.forEach((key, value) {
    if (key.startsWith('@')) {
      metadata[key] = value;
    } else {
      translatableStrings[key] = value.toString();
    }
  });

  printInfo('Found ${translatableStrings.length} translatable strings');

  // Target languages
  final targetLanguages = [
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'zh', 'name': 'Chinese (Mandarin)'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'th', 'name': 'Thai'},
    {'code': 'vi', 'name': 'Vietnamese'},
  ];

  // Generate translations for each target language
  for (final lang in targetLanguages) {
    final langCode = lang['code']!;
    final langName = lang['name']!;

    printInfo('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    printInfo('Translating to $langName ($langCode)...');

    try {
      final translations = await translateStrings(
        translatableStrings,
        langName,
        apiKey,
      );

      // Create target .arb file
      final targetFile = '$arbDir/${featureName}_$langCode.arb';
      final targetJson = <String, dynamic>{
        '@@locale': langCode,
        ...translations,
      };

      // Write to file with pretty formatting
      final encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(targetJson);
      File(targetFile).writeAsStringSync('$prettyJson\n');

      printSuccess('✓ Generated $targetFile');
    } catch (e) {
      printError('✗ Failed to translate to $langName: $e');
    }
  }

  printInfo('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  printSuccess('Translation generation complete!');
}

/// Translate strings using Claude API
Future<Map<String, String>> translateStrings(
  Map<String, String> strings,
  String targetLanguage,
  String apiKey,
) async {
  final client = HttpClient();

  try {
    // Prepare request
    final uri = Uri.parse('https://api.anthropic.com/v1/messages');
    final request = await client.postUrl(uri);

    // Set headers
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('x-api-key', apiKey);
    request.headers.set('anthropic-version', '2023-06-01');

    // Build translation prompt
    final prompt = buildTranslationPrompt(strings, targetLanguage);

    // Build request body
    final body = jsonEncode({
      'model': 'claude-sonnet-4-5-20250929',
      'max_tokens': 4096,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    });

    request.write(body);

    // Send request
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw Exception(
        'API request failed with status ${response.statusCode}: $responseBody',
      );
    }

    // Parse response
    final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;
    final content = responseJson['content'] as List<dynamic>;
    final textContent = content.first as Map<String, dynamic>;
    final translatedText = textContent['text'] as String;

    // Extract JSON from response (Claude may wrap it in markdown code blocks)
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(translatedText);
    final jsonStr = jsonMatch != null ? jsonMatch.group(1)! : translatedText;

    // Parse translations
    final translations = jsonDecode(jsonStr) as Map<String, dynamic>;
    return translations.map((key, value) => MapEntry(key, value.toString()));
  } finally {
    client.close();
  }
}

/// Build translation prompt for Claude
String buildTranslationPrompt(
  Map<String, String> strings,
  String targetLanguage,
) {
  final stringsJson = JsonEncoder.withIndent('  ').convert(strings);

  return '''
You are a professional translator for a mental health and wellness app called "Apothy".

Your task is to translate these UI strings from English to $targetLanguage.

CRITICAL REQUIREMENTS:
1. Maintain a warm, supportive, and compassionate tone appropriate for mental health
2. Keep ALL placeholders UNCHANGED (e.g., {count}, {name}, {date})
3. Ensure translations fit mobile UI constraints (keep them concise)
4. Use culturally appropriate phrasing for $targetLanguage speakers
5. Preserve the emotional intent and meaning of each string
6. For app/brand names like "Apothy" - keep them unchanged
7. Return ONLY valid JSON with the same keys, translated values

Source strings (English):
$stringsJson

Return the translations as a JSON object with the EXACT same keys, but with values translated to $targetLanguage.

Example format:
{
  "appName": "Apothy",
  "ok": "translated_text_here",
  "cancel": "translated_text_here"
}

Return ONLY the JSON object, no additional text or explanation.
''';
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Functions
// ═══════════════════════════════════════════════════════════════════════════

void printInfo(String message) {
  stdout.writeln('\x1B[34mℹ\x1B[0m $message');
}

void printSuccess(String message) {
  stdout.writeln('\x1B[32m$message\x1B[0m');
}

void printError(String message) {
  stderr.writeln('\x1B[31m✗ $message\x1B[0m');
}
