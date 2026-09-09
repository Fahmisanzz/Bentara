import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bentara/features/communication/models/chat_message_model.dart';
import 'package:bentara/features/communication/models/context_preset.dart';
import 'package:bentara/features/communication/providers/communication_provider.dart';
import 'package:bentara/features/communication/services/stt_service.dart';
import 'package:bentara/features/communication/services/tts_service.dart';
import 'package:bentara/features/communication/services/context_translation_service.dart';
import 'package:bentara/features/communication/data/conversation_repository.dart';
import 'package:bentara/features/history/models/message_model.dart';

// Mock Services
class MockSTTService implements ISTTService {
  @override
  Future<bool> initialize() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  bool get isListening => false;
  @override
  Future<void> startListening({
    required Function(String text) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {}
  @override
  Future<void> stopListening() async {}
  @override
  Future<void> cancelListening() async {}
}

class MockTTSService implements ITTSService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> setLanguage(String langCode) async {}
  @override
  Future<void> setSpeechRate(double rate) async {}
}

class MockTranslationService implements IContextTranslationService {
  @override
  Future<String> translateContext({required String rawText, required ContextPreset preset}) async {
    return 'Hasil AI: $rawText';
  }
}

class MockConversationRepository implements IConversationRepository {
  final Map<String, List<ChatMessageModel>> messagesDb = {};

  @override
  Future<String> saveConversation(String title, String userId, {String? contextStr, String? id}) async {
    return id ?? 'convo_123';
  }

  @override
  Future<void> saveMessage(String conversationId, ChatMessageModel message) async {
    messagesDb.putIfAbsent(conversationId, () => []).add(message);
  }

  @override
  Future<void> updateMessage(String conversationId, String messageId, String newText, {DateTime? updatedAt}) async {
    final list = messagesDb[conversationId];
    if (list != null) {
      final index = list.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        list[index] = list[index].copyWith(
          text: newText,
          isEdited: true,
          updatedAt: updatedAt ?? DateTime.now(),
        );
      }
    }
  }

  @override
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId) async {
    return messagesDb[conversationId] ?? [];
  }
}

void main() {
  group('ChatMessageModel & Validation Tests', () {
    test('Test 1: Pesan baru (< 3 jam) canBeEdited bernilai true', () {
      final message = ChatMessageModel(
        id: 'msg_1',
        text: 'Saya mau pergi ke pasar',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        sourceType: SourceType.textInput,
      );

      expect(message.canBeEdited, isTrue);
      expect(message.isEdited, isFalse);
      expect(message.updatedAt, isNull);
    });

    test('Test 2: Pesan 1 jam lalu canBeEdited bernilai true', () {
      final message = ChatMessageModel(
        id: 'msg_2',
        text: 'Pesan satu jam lalu',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        sourceType: SourceType.textInput,
      );

      expect(message.canBeEdited, isTrue);
    });

    test('Test 3: Pesan 2 jam 59 menit lalu canBeEdited bernilai true', () {
      final message = ChatMessageModel(
        id: 'msg_3',
        text: 'Pesan hampir 3 jam lalu',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 59)),
        sourceType: SourceType.textInput,
      );

      expect(message.canBeEdited, isTrue);
    });

    test('Test 4: Pesan melewati batas 3 jam (misal 3 jam 5 menit lalu) canBeEdited bernilai false', () {
      final message = ChatMessageModel(
        id: 'msg_4',
        text: 'Pesan lama',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
        sourceType: SourceType.textInput,
      );

      expect(message.canBeEdited, isFalse);
    });

    test('Test 5: Pesan milik Teman Dengar (< 3 jam) canBeEdited bernilai true (koreksi suara STT)', () {
      final message = ChatMessageModel(
        id: 'msg_5',
        text: 'Pesan dari teman dengar',
        sender: SenderType.userDengar,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        sourceType: SourceType.stt,
      );

      expect(message.canBeEdited, isTrue);
    });
  });

  group('CommunicationNotifier Edit Logic Tests', () {
    late ProviderContainer container;
    late MockConversationRepository mockRepo;

    setUp(() {
      mockRepo = MockConversationRepository();
      container = ProviderContainer(
        overrides: [
          sttServiceProvider.overrideWithValue(MockSTTService()),
          ttsServiceProvider.overrideWithValue(MockTTSService()),
          contextTranslationServiceProvider.overrideWithValue(MockTranslationService()),
          conversationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Test 6: Edit pesan baru berhasil dan memperbarui state & repository', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      final newMsg = ChatMessageModel(
        id: 'msg_to_edit',
        text: 'Halo saya mau ke toko',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        sourceType: SourceType.textInput,
      );

      notifier.state = notifier.state.copyWith(
        messages: [newMsg],
        activeConversationId: 'convo_test',
      );

      // Edit pesan
      final success = await notifier.editMessage('msg_to_edit', 'Halo saya mau ke pasar');

      expect(success, isTrue);
      final updatedState = container.read(communicationNotifierProvider);
      expect(updatedState.messages.first.text, 'Halo saya mau ke pasar');
      expect(updatedState.messages.first.isEdited, isTrue);
      expect(updatedState.messages.first.updatedAt, isNotNull);
      expect(updatedState.errorMessage, isNull);
    });

    test('Test 7: Edit pesan menjadi teks kosong ditolak', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      final newMsg = ChatMessageModel(
        id: 'msg_empty_test',
        text: 'Pesan valid',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        sourceType: SourceType.textInput,
      );

      notifier.state = notifier.state.copyWith(
        messages: [newMsg],
        activeConversationId: 'convo_test',
      );

      final success = await notifier.editMessage('msg_empty_test', '   ');

      expect(success, isFalse);
      final state = container.read(communicationNotifierProvider);
      expect(state.errorMessage, 'Pesan tidak boleh kosong.');
      expect(state.messages.first.text, 'Pesan valid');
      expect(state.messages.first.isEdited, isFalse);
    });

    test('Test 8: Edit pesan setelah lewat 3 jam ditolak oleh notifier', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      // Masukkan pesan manual berusia 4 jam lalu
      final oldMessage = ChatMessageModel(
        id: 'old_msg_1',
        text: 'Teks pesan 4 jam lalu',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        sourceType: SourceType.textInput,
      );

      notifier.state = notifier.state.copyWith(
        messages: [oldMessage],
        activeConversationId: 'convo_test',
      );

      final success = await notifier.editMessage('old_msg_1', 'Teks baru');

      expect(success, isFalse);
      final state = container.read(communicationNotifierProvider);
      expect(state.errorMessage, 'Pesan tidak dapat diedit karena batas waktu 3 jam telah berakhir.');
      expect(state.messages.first.text, 'Teks pesan 4 jam lalu');
      expect(state.messages.first.isEdited, isFalse);
    });

    test('Test 9: Edit pesan suara Teman Dengar (hasil STT salah tangkap) berhasil diperbarui', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      final dengarMessage = ChatMessageModel(
        id: 'dengar_msg_1',
        text: 'Saya mau makan obat',
        sender: SenderType.userDengar,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        sourceType: SourceType.stt,
      );

      notifier.state = notifier.state.copyWith(
        messages: [dengarMessage],
        activeConversationId: 'convo_test',
      );

      // Pengguna mengoreksi kata STT yang salah menjadi "Saya mau minum obat"
      final success = await notifier.editMessage('dengar_msg_1', 'Saya mau minum obat');

      expect(success, isTrue);
      final state = container.read(communicationNotifierProvider);
      expect(state.errorMessage, isNull);
      expect(state.messages.first.text, 'Saya mau minum obat');
      expect(state.messages.first.isEdited, isTrue);
      expect(state.messages.first.updatedAt, isNotNull);
    });

    test('Test 10: Edit pesan hasil AI Context Translation mempertahankan teks koreksi sebagai teks aktif', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      // Simulasikan pesan hasil AI context translation
      final aiMessage = ChatMessageModel(
        id: 'ai_msg_1',
        text: 'Saya ingin pergi ke rumah sakit sekarang.',
        originalText: 'rumah sakit pergi',
        contextualText: 'Saya ingin pergi ke rumah sakit sekarang.',
        appliedContext: ContextPreset.rumahSakit,
        isContextApplied: true,
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        sourceType: SourceType.textInput,
      );

      notifier.state = notifier.state.copyWith(
        messages: [aiMessage],
        activeConversationId: 'convo_test',
      );

      // Pengguna mengoreksi menjadi puskesmas
      final success = await notifier.editMessage('ai_msg_1', 'Saya ingin pergi ke puskesmas terdekat.');

      expect(success, isTrue);
      final state = container.read(communicationNotifierProvider);
      final updatedMsg = state.messages.first;

      expect(updatedMsg.text, 'Saya ingin pergi ke puskesmas terdekat.');
      expect(updatedMsg.isEdited, isTrue);
      expect(updatedMsg.originalText, 'rumah sakit pergi');
      expect(updatedMsg.appliedContext, ContextPreset.rumahSakit);
    });

    test('Test 11: Edit hasil gesture recognition BISINDO yang salah', () async {
      final notifier = container.read(communicationNotifierProvider.notifier);

      // Prediksi BISINDO salah: "Makan" padahal maksudnya "Telepon"
      final gestureMessage = ChatMessageModel(
        id: 'gesture_msg_1',
        text: 'Makan',
        sender: SenderType.userTuli,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        sourceType: SourceType.sign,
      );

      notifier.state = notifier.state.copyWith(
        messages: [gestureMessage],
        activeConversationId: 'convo_test',
      );

      final success = await notifier.editMessage('gesture_msg_1', 'Telepon');

      expect(success, isTrue);
      final updatedMsg = container.read(communicationNotifierProvider).messages.first;
      expect(updatedMsg.text, 'Telepon');
      expect(updatedMsg.isEdited, isTrue);
      expect(updatedMsg.sourceType, SourceType.sign);
    });
  });

  group('JSON Serialization & Backward Compatibility Tests', () {
    test('Test 12: ChatMessageModel serialization / deserialization roundtrip', () {
      final now = DateTime.now();
      final updated = now.add(const Duration(minutes: 10));

      final msg = ChatMessageModel(
        id: 'json_msg_1',
        text: 'Teks terkoreksi',
        originalText: 'Teks asli',
        contextualText: 'Teks konteks',
        appliedContext: ContextPreset.layananPublik,
        isContextApplied: true,
        sender: SenderType.userTuli,
        timestamp: now,
        sourceType: SourceType.textInput,
        isEdited: true,
        updatedAt: updated,
      );

      final json = msg.toJson();
      expect(json['is_edited'], isTrue);
      expect(json['updated_at'], updated.toIso8601String());

      final restored = ChatMessageModel.fromJson(json);
      expect(restored.id, msg.id);
      expect(restored.text, 'Teks terkoreksi');
      expect(restored.originalText, 'Teks asli');
      expect(restored.isEdited, isTrue);
      expect(restored.updatedAt?.toIso8601String(), updated.toIso8601String());
    });

    test('Test 13: Backward compatibility dengan pesan lama tanpa field is_edited/updated_at', () {
      final legacyJson = {
        'id': 'legacy_1',
        'output_text': 'Pesan dari versi aplikasi lama',
        'sender_type': 'tuli',
        'input_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Pastikan fromJson ChatMessageModel tidak throw exception dan fallback ke false & null
      final chatMsg = ChatMessageModel.fromJson(legacyJson);
      expect(chatMsg.id, 'legacy_1');
      expect(chatMsg.text, 'Pesan dari versi aplikasi lama');
      expect(chatMsg.isEdited, isFalse);
      expect(chatMsg.updatedAt, isNull);

      // Pastikan fromJson MessageModel history juga tidak throw exception
      final historyMsg = MessageModel.fromJson({
        'id': 'legacy_history_1',
        'conversation_id': 'convo_1',
        'sender_type': 'tuli',
        'input_type': 'text',
        'output_text': 'Riwayat lama',
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(historyMsg.isEdited, isFalse);
      expect(historyMsg.updatedAt, isNull);
    });
  });
}
