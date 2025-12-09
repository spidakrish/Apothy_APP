# Apothy

Apothy AI Companion App - A Flutter-based mobile application with AI chat integration.

## AI Configuration - WHERE TO ADD API KEYS

**File:** `lib/core/config/ai_config.dart`

| Line | Variable | Current Value | What To Change |
|------|----------|---------------|----------------|
| **19** | `useMockResponses` | `true` | Change to `false` to enable real AI |
| **30** | `aiBaseUrl` | `'PLACEHOLDER_AI_BASE_URL'` | Your AI API base URL |
| **42** | `aiApiKey` | `'PLACEHOLDER_AI_API_KEY'` | Your AI API key |
| **55** | `defaultModel` | `'PLACEHOLDER_MODEL_ID'` | Your AI model ID |

### Quick Example

```dart
// lib/core/config/ai_config.dart

// Line 19 - Enable real AI (change from true to false)
static const bool useMockResponses = false;

// Line 30 - Set your API base URL
static const String aiBaseUrl = 'https://api.openai.com/v1';

// Line 42 - Set your API key
static const String aiApiKey = 'sk-your-api-key-here';

// Line 55 - Set your model
static const String defaultModel = 'gpt-4';
```

## Project Structure (AI-Related Files Only)

```
lib/
├── core/
│   ├── config/
│   │   └── ai_config.dart              # <-- API KEYS GO HERE
│   ├── constants/
│   │   └── api_constants.dart          # API endpoints (line 81: /ai/chat)
│   ├── error/
│   │   └── failures.dart               # AIFailure error types
│   └── services/
│       └── ai_service.dart             # AI HTTP client
└── features/
    └── chat/
        ├── data/
        │   ├── datasources/
        │   │   └── chat_local_datasource.dart
        │   └── repositories/
        │       └── chat_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── conversation.dart
        │   │   └── message.dart
        │   └── repositories/
        │       └── chat_repository.dart
        └── presentation/
            ├── chat_screen.dart
            └── providers/
                ├── ai_providers.dart   # AI Riverpod providers
                └── chat_providers.dart # Chat state with AI integration
```

## How AI Integration Works

1. User sends message in chat screen
2. Message saved to local Hive database
3. `AIChatService.getResponse()` called (in `lib/core/services/ai_service.dart`)
4. If `useMockResponses = true` (line 19): Returns mock response
5. If `useMockResponses = false`: Makes POST to `/ai/chat`
6. Response saved and displayed

## API Contract

### Request (POST /ai/chat)

```json
{
  "conversation_id": "uuid-string",
  "message": "user's message text",
  "history": [
    {"role": "user", "content": "previous message"},
    {"role": "assistant", "content": "previous response"}
  ],
  "style": "balanced",
  "temperature": 0.7,
  "max_tokens": 1024,
  "system_prompt": "You are Apothy...",
  "model": "your-model-id"
}
```

### Response (Required Format)

```json
{
  "response": "AI generated text here",
  "conversation_id": "optional-string",
  "tokens_used": 150
}
```

**Required field:** `response` (string)
**Optional fields:** `conversation_id`, `tokens_used`

## Running the App

```bash
flutter pub get
flutter run
flutter analyze
```

## Architecture

- **State Management:** Riverpod
- **Local Storage:** Hive
- **HTTP Client:** Dio
- **Error Handling:** fpdart (Either type)
