# Apothy - App Store Connect Metadata

This document contains all required metadata for Apple App Store submission.

---

## 1. APP INFORMATION

### App Name (30 characters max)
```
Apothy
```

### Subtitle (30 characters max)
```
Your AI Companion for Thought
```

### Primary Category
```
Lifestyle
```

### Secondary Category (Optional)
```
Health & Fitness
```

---

## 2. APP DESCRIPTION (4,000 characters max)

```
Apothy is your personal AI companion designed to help you reflect, explore, and express yourself through meaningful conversation.

THOUGHTFUL CONVERSATIONS
Chat naturally with an AI that listens without judgment. Whether you're processing thoughts, brainstorming ideas, or simply need someone to talk to, Apothy is here for you.

KEY FEATURES

- Voice Input: Speak your thoughts instead of typing with built-in speech-to-text
- Dark Mode Design: A calming, eye-friendly interface for any time of day
- Complete Privacy: Your conversations stay on your device with secure local storage
- Gamification: Earn XP, unlock achievements, and build streaks as you engage
- Customizable Experience: Adjust text size and conversation style to your preference
- Chat History: Revisit past conversations organized by date

YOUR PROGRESS, YOUR WAY
Track your journey with XP points and achievements. Build daily streaks and watch your progress grow. Apothy celebrates your consistency without pressuring you.

PRIVACY FIRST
We believe your thoughts are yours alone. Apothy stores conversations locally on your device with encryption. No data mining. No manipulation. Just genuine support.

DESIGNED FOR WELLBEING
Unlike social media designed to keep you scrolling, Apothy is built to help you feel better. Have a meaningful conversation, then get back to your life.

PERFECT FOR
- Daily reflection and journaling
- Processing thoughts and emotions
- Creative brainstorming
- Exploring ideas out loud
- Building a consistent mindfulness practice

Download Apothy today and discover a new way to connect with yourself.
```

**Character Count: ~1,580 characters**

---

## 3. PROMOTIONAL TEXT (170 characters max)

*Can be updated without app submission*

```
Chat with an AI companion that listens without judgment. Reflect, explore, and express yourself through meaningful conversation.
```

**Character Count: 130 characters**

---

## 4. KEYWORDS (100 characters max, comma-separated, no spaces after commas)

```
ai companion,journal,mental health,reflection,mindfulness,chat,wellness,therapy,diary,self-care
```

**Character Count: 96 characters**

---

## 5. SUPPORT & PRIVACY URLS

### Support URL
```
https://www.apothyai.com/support
```

### Privacy Policy URL
```
https://www.apothyai.com/privacy
```

### Terms of Service URL (Optional but recommended)
```
https://www.apothyai.com/terms
```

### Marketing URL (Optional)
```
https://www.apothyai.com
```

---

## 6. APP REVIEW INFORMATION

### Demo Account Credentials

**Email:**
```
demo@apothyai.com
```

**Password:**
```
ApothyDemo2024!
```

> **Note:** Ensure this demo account is created in your backend before submission.
> The demo account should have:
> - Some existing chat history (3-5 conversations)
> - Some earned achievements
> - A streak history

### Review Notes

```
IMPORTANT INFORMATION FOR REVIEWERS:

1. AUTHENTICATION
   - The app supports Email/Password, Apple Sign-In, and Google Sign-In
   - Use the demo account provided above to test all features
   - For Apple Sign-In testing, you may use your own Apple ID

2. SPEECH RECOGNITION
   - The app uses on-device speech recognition
   - Microphone permission is required only when using voice input
   - Tap the microphone icon in the chat input to activate

3. CORE FUNCTIONALITY
   - This is an AI chat companion app for personal reflection
   - Send messages to receive AI-generated responses
   - All conversations are stored locally on the device

4. GAMIFICATION
   - Navigate to the Dashboard tab to view XP, streak, and achievements
   - XP is earned by sending messages and receiving responses
   - Achievements unlock automatically based on activity

5. SETTINGS
   - Profile: Change display name and avatar
   - Appearance: Adjust text size
   - Content: Change conversation style
   - Data: Clear chat history or reset app

6. PRIVACY
   - No tracking or analytics
   - Conversations stored locally with encryption
   - Users can delete all data from Settings

Contact: support@apothyai.com
```

---

## 7. AGE RATING QUESTIONNAIRE

Answer these questions in App Store Connect:

### Made for Kids
```
No
```

### Cartoon or Fantasy Violence
```
None
```

### Realistic Violence
```
None
```

### Sexual Content or Nudity
```
None
```

### Profanity or Crude Humor
```
None
```

### Alcohol, Tobacco, or Drug Use or References
```
None
```

### Simulated Gambling
```
None
```

### Horror/Fear Themes
```
None
```

### Mature/Suggestive Themes
```
None
```

### Medical/Treatment Information
```
None
```
*Note: Apothy is NOT a medical device and does not provide medical advice*

### Unrestricted Web Access
```
No
```

### Gambling and Contests
```
No
```

**Expected Age Rating: 4+**

---

## 8. EXPORT COMPLIANCE

### Does your app use encryption?
```
Yes - Standard HTTPS only (exempt)
```

### ITSAppUsesNonExemptEncryption
```
NO (false)
```

Already configured in `ios/Runner/Info.plist`:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**Explanation:** The app uses only standard HTTPS for network communication, which is exempt from export compliance documentation requirements per [Apple's guidelines](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations).

---

## 9. APP PRIVACY LABELS

Configure these in App Store Connect under "App Privacy":

### Data Types Collected

#### 1. Contact Info - Email Address
- **Collected:** Yes
- **Purpose:** Account registration and authentication
- **Linked to User:** Yes
- **Used for Tracking:** No

#### 2. Identifiers - User ID
- **Collected:** Yes
- **Purpose:** App functionality (to identify user's own data)
- **Linked to User:** Yes
- **Used for Tracking:** No

#### 3. User Content - Other User Content
- **Collected:** Yes
- **Purpose:** App functionality (chat messages sent to AI backend for generating responses)
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Note:** Chat messages and conversation history are transmitted to the AI backend to generate personalized responses. Messages are also stored locally on device.

### Data NOT Collected (Important Declarations)
- Location Data: NOT COLLECTED
- Financial Info: NOT COLLECTED
- Health & Fitness: NOT COLLECTED
- Browsing History: NOT COLLECTED
- Search History: NOT COLLECTED
- Contacts: NOT COLLECTED
- Photos/Videos: NOT COLLECTED
- Audio Data: NOT COLLECTED (speech is processed on-device via Apple's Speech Recognition, not transmitted to Apothy servers)
- Sensitive Info: NOT COLLECTED
- Diagnostics: NOT COLLECTED

### Data Retention
```
Users can delete their data at any time through Settings > Data Management > Delete Account
```

### Important Note on Chat Data
When the AI backend is connected (production mode), the following data is transmitted:
- `conversation_id` - Unique identifier for the chat session
- `message` - The user's message content
- `history` - Previous messages in the conversation (up to 20 messages)
- `style` - User's preferred response style preference

This data is sent to: `https://xnfhbfcbpptm6bqdvs5gi6gimu0xiguq.lambda-url.ap-southeast-2.on.aws/ai/chat`

Ensure your Privacy Policy at https://www.apothyai.com/privacy accurately reflects this data transmission.

---

## 10. VERSION INFORMATION

### Version Number
```
1.0.0
```

### Build Number
```
1
```

### What's New in This Version
```
Initial release of Apothy - Your AI Companion for Thought

- Chat with an AI companion that listens without judgment
- Voice input with on-device speech recognition
- Secure local storage for complete privacy
- Earn XP and unlock achievements
- Build daily streaks
- Customizable text size and conversation style
- Dark mode interface designed for wellbeing
```

---

## 11. SCREENSHOTS REQUIRED

### iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max)
- 1290 x 2796 pixels
- Minimum 3 screenshots, maximum 10

### iPhone 6.5" (iPhone 11 Pro Max, XS Max)
- 1284 x 2778 pixels
- Minimum 3 screenshots, maximum 10

### iPhone 5.5" (iPhone 8 Plus, 7 Plus)
- 1242 x 2208 pixels
- Minimum 3 screenshots, maximum 10

### Suggested Screenshot Scenes
1. **Chat Interface** - Show a conversation in progress
2. **Dashboard** - Display XP, streak, and achievements
3. **Voice Input** - Show the speech recognition feature active
4. **Settings** - Show customization options
5. **Achievement Unlocked** - Show confetti celebration

---

## 12. APP ICON

Already configured in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Required sizes (all present):
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro @2x)
- 152x152 (iPad @2x)
- And various other sizes for Spotlight, Settings, etc.

---

## 13. TECHNICAL REQUIREMENTS

| Requirement | Status |
|-------------|--------|
| Xcode Version | 16.3 (Exceeds 15+ requirement) |
| iOS SDK | 18.4 (Exceeds iOS 17 requirement) |
| Minimum iOS Version | 13.0 |
| Device Support | iPhone, iPad |
| Orientations | Portrait, Landscape |

---

## 14. CHECKLIST BEFORE SUBMISSION

- [ ] Demo account created and functional in backend
- [ ] All screenshots captured
- [ ] Privacy Policy URL accessible and up-to-date
- [ ] Support URL functional
- [ ] Real Google OAuth credentials configured
- [ ] Real Apple Sign-In configured in Apple Developer Console
- [ ] AI backend connected and functional
- [ ] All placeholder values replaced
- [ ] App tested on physical device
- [ ] App Archive created and validated

---

## Sources & References

- [Creating Your Product Page - Apple Developer](https://developer.apple.com/app-store/product-page/)
- [App Store Optimization Guide 2025](https://www.mobiloud.com/blog/app-store-optimization)
- [App Privacy Details - Apple Developer](https://developer.apple.com/app-store/app-privacy-details/)
- [Export Compliance - Apple Developer](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations)
- [App Review Guidelines - Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
