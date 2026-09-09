import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bentara/features/communication/models/chat_message_model.dart';
import 'package:bentara/features/communication/models/context_preset.dart';
import 'package:bentara/features/communication/providers/communication_provider.dart';
import 'package:bentara/features/communication/services/stt_service.dart';
import 'package:bentara/features/communication/services/tts_service.dart';
import 'package:bentara/features/communication/services/context_translation_service.dart';
import 'package:bentara/features/communication/data/conversation_repository.dart';
import 'package:bentara/features/communication/presentation/screens/communication_screen.dart';
import 'package:bentara/features/communication/presentation/widgets/voice_recording_bar.dart';

// -------------------------------------------------------------
// Test Mocks
// -------------------------------------------------------------
class TestSTTService implements ISTTService {
  bool _isListening = false;
  bool shouldGrantPermission = true;
  Function(String text)? onResultCallback;
  Function(double soundLevel)? onSoundLevelCallback;
  int startListeningCalls = 0;
  int stopListeningCalls = 0;
  int cancelListeningCalls = 0;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async => shouldGrantPermission;

  @override
  Future<bool> hasPermission() async => shouldGrantPermission;

  @override
  Future<void> startListening({
    required Function(String text) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    _isListening = true;
    startListeningCalls++;
    onResultCallback = onResult;
    onSoundLevelCallback = onSoundLevelChange;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    stopListeningCalls++;
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    cancelListeningCalls++;
  }

  void simulateSpeech(String words) {
    onResultCallback?.call(words);
  }

  void simulateSoundLevel(double level) {
    onSoundLevelCallback?.call(level);
  }
}

class TestTTSService implements ITTSService {
  String? lastSpokenText;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> speak(String text) async {
    lastSpokenText = text;
  }
  @override
  Future<void> stop() async {}
  @override
  Future<void> setLanguage(String langCode) async {}
  @override
  Future<void> setSpeechRate(double rate) async {}
}

class TestTranslationService implements IContextTranslationService {
  @override
  Future<String> translateContext({required String rawText, required ContextPreset preset}) async {
    return rawText;
  }
}

class TestConversationRepository implements IConversationRepository {
  final List<ChatMessageModel> savedMessages = [];

  @override
  Future<String> saveConversation(String title, String userId, {String? contextStr, String? id}) async {
    return id ?? 'convo_test_1';
  }

  @override
  Future<void> saveMessage(String conversationId, ChatMessageModel message) async {
    savedMessages.add(message);
  }

  @override
  Future<void> updateMessage(String conversationId, String messageId, String newText, {DateTime? updatedAt}) async {}

  @override
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId) async {
    return savedMessages;
  }
}

// -------------------------------------------------------------
// Tests
// -------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestSTTService mockStt;
  late TestTTSService mockTts;
  late TestTranslationService mockTranslation;
  late TestConversationRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockStt = TestSTTService();
    mockTts = TestTTSService();
    mockTranslation = TestTranslationService();
    mockRepo = TestConversationRepository();

    container = ProviderContainer(
      overrides: [
        sttServiceProvider.overrideWithValue(mockStt),
        ttsServiceProvider.overrideWithValue(mockTts),
        contextTranslationServiceProvider.overrideWithValue(mockTranslation),
        conversationRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CommunicationNotifier Voice Flow Logic Tests (WhatsApp Style)', () {
    test('TEST 4: Start Voice Recording initializes state and STT', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();

      final state = container.read(communicationNotifierProvider);
      expect(state.isListening, isTrue);
      expect(state.isRecordingPaused, isFalse);
      expect(state.recordingDurationSeconds, equals(0));
      expect(mockStt.startListeningCalls, equals(1));
    });

    test('TEST 5: Pause Voice Recording preserves text and pauses STT', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();
      mockStt.simulateSpeech('Halo selamat');

      await notifier.pauseVoiceRecording();

      final state = container.read(communicationNotifierProvider);
      expect(state.isListening, isTrue);
      expect(state.isRecordingPaused, isTrue);
      expect(state.currentRecognizedText, equals('Halo selamat'));
      expect(mockStt.stopListeningCalls, equals(1));
    });

    test('TEST 6: Resume Voice Recording restarts STT and appends speech seamlessly', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();
      mockStt.simulateSpeech('Halo');
      await notifier.pauseVoiceRecording();

      await notifier.resumeVoiceRecording();
      final stateAfterResume = container.read(communicationNotifierProvider);
      expect(stateAfterResume.isRecordingPaused, isFalse);
      expect(mockStt.startListeningCalls, equals(2));

      mockStt.simulateSpeech('pagi');
      final finalState = container.read(communicationNotifierProvider);
      expect(finalState.currentRecognizedText, equals('Halo pagi'));
    });

    test('TEST 7: Delete / Cancel Voice Recording cleans up all state to IDLE', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();
      mockStt.simulateSpeech('Pesan dibatalkan');

      await notifier.cancelVoiceRecording();

      final state = container.read(communicationNotifierProvider);
      expect(state.isListening, isFalse);
      expect(state.isRecordingPaused, isFalse);
      expect(state.recordingDurationSeconds, equals(0));
      expect(state.currentRecognizedText, isEmpty);
      expect(mockStt.cancelListeningCalls, equals(1));
    });

    test('TEST 8: Send Voice Recording sends message with userDengar & STT and resets completely', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();
      mockStt.simulateSpeech('Saya ingin memesan kopi');

      await notifier.sendVoiceRecording();

      final state = container.read(communicationNotifierProvider);
      // Verify state is completely reset to IDLE with no lingering text
      expect(state.isListening, isFalse);
      expect(state.isRecordingPaused, isFalse);
      expect(state.recordingDurationSeconds, equals(0));
      expect(state.currentRecognizedText, isEmpty);
      expect(state.isSendingVoice, isFalse);

      // Verify message was processed and saved
      expect(state.messages.length, equals(1));
      final sentMsg = state.messages.first;
      expect(sentMsg.text, equals('Saya ingin memesan kopi'));
      expect(sentMsg.sender, equals(SenderType.userDengar));
      expect(sentMsg.sourceType, equals(SourceType.stt));
      expect(mockRepo.savedMessages.length, equals(1));
    });

    test('TEST 9: Send Voice Recording with empty speech handles gracefully', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      await notifier.startVoiceRecording();
      // No speech simulated

      await notifier.sendVoiceRecording();

      final state = container.read(communicationNotifierProvider);
      expect(state.isListening, isFalse);
      expect(state.currentRecognizedText, isEmpty);
      expect(state.errorMessage, isNotNull);
      expect(state.messages, isEmpty);
    });

    test('TEST 10: Dispose cleanup cancels timers and STT', () async {
      final localContainer = ProviderContainer(
        overrides: [
          sttServiceProvider.overrideWithValue(mockStt),
          ttsServiceProvider.overrideWithValue(mockTts),
          contextTranslationServiceProvider.overrideWithValue(mockTranslation),
          conversationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      final notifier = localContainer.read(communicationNotifierProvider.notifier);
      await notifier.startVoiceRecording();

      localContainer.dispose();
      expect(mockStt.cancelListeningCalls, equals(1));
    });
  });

  group('UI Dynamic Composer & Voice UX Widget Tests', () {
    Widget createWidgetUnderTest() {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CommunicationScreen(),
        ),
      );
    }

    testWidgets('TEST 1 & 2 & 3: Dynamic Mic ↔ Send Button based on TextField content', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // TEST 1: TextField is empty -> Mic button is visible, Send button is not
      expect(find.byKey(const ValueKey('composer_mic_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('composer_send_button')), findsNothing);

      // TEST 2: User types "Halo" -> Mic morphs to Send button
      await tester.enterText(find.byType(TextField), 'Halo');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('composer_mic_button')), findsNothing);
      expect(find.byKey(const ValueKey('composer_send_button')), findsOneWidget);

      // TEST 3: User deletes text back to empty -> Send morphs back to Mic button
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('composer_mic_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('composer_send_button')), findsNothing);
    });

    testWidgets('TEST 4 & 7: Pressing Mic opens VoiceRecordingBar, Delete button cancels and resets UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap Mic button to start recording
      await tester.tap(find.byKey(const ValueKey('composer_mic_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // VoiceRecordingBar is now rendered
      expect(find.byType(VoiceRecordingBar), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('Jeda'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);

      // Tap Delete button
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // VoiceRecordingBar is gone and idle composer with Mic button returns
      expect(find.byType(VoiceRecordingBar), findsNothing);
      expect(find.byKey(const ValueKey('composer_mic_button')), findsOneWidget);
      expect(find.text('Mendengarkan...'), findsNothing);
    });

    testWidgets('TEST 5 & 6: Pause and Resume buttons toggle within VoiceRecordingBar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Start recording
      await tester.tap(find.byKey(const ValueKey('composer_mic_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "Jeda" (Pause)
      await tester.tap(find.text('Jeda'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Lanjut'), findsOneWidget);
      expect(container.read(communicationNotifierProvider).isRecordingPaused, isTrue);

      // Tap "Lanjut" (Resume)
      await tester.tap(find.text('Lanjut'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Jeda'), findsOneWidget);
      expect(container.read(communicationNotifierProvider).isRecordingPaused, isFalse);

      // Clean up timer by canceling recording before test ends
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('TEST 8: Send voice recording sends message and removes recording bar completely', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Start recording
      await tester.tap(find.byKey(const ValueKey('composer_mic_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate live recognized speech
      mockStt.simulateSpeech('Selamat siang');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Selamat siang'), findsOneWidget);

      // Tap Send button in VoiceRecordingBar
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify VoiceRecordingBar is closed, no "Mendengarkan..." lingering
      expect(find.byType(VoiceRecordingBar), findsNothing);
      expect(find.byKey(const ValueKey('composer_mic_button')), findsOneWidget);
      expect(find.text('Mendengarkan...'), findsNothing);

      // Verify chat bubble appears in message list
      expect(find.text('Teman Dengar'), findsOneWidget);
      expect(find.text('Selamat siang'), findsOneWidget);
    });
  });
}
