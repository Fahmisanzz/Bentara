import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/profile/models/user_profile_model.dart';
import 'package:bentara/features/auth/models/user_model.dart';
import 'package:bentara/features/history/models/conversation_model.dart';
import 'package:bentara/features/history/models/message_model.dart';

void main() {
  group('Profile & Auth Model Tests', () {
    test('UserProfileModel serializes and deserializes with avatarUrl', () {
      final model = UserProfileModel(
        id: 'user_123',
        name: 'Fahmi Testing',
        role: 'tuli',
        avatarUrl: '/data/user/0/avatar.jpg',
        totalSessions: 5,
        totalMessages: 20,
      );

      final json = model.toJson();
      expect(json['id'], 'user_123');
      expect(json['name'], 'Fahmi Testing');
      expect(json['role'], 'tuli');
      expect(json['avatar_url'], '/data/user/0/avatar.jpg');
      expect(json['total_sessions'], 5);
      expect(json['total_messages'], 20);

      final restored = UserProfileModel.fromJson(json);
      expect(restored.id, model.id);
      expect(restored.name, model.name);
      expect(restored.role, model.role);
      expect(restored.avatarUrl, model.avatarUrl);
      expect(restored.totalSessions, model.totalSessions);
      expect(restored.totalMessages, model.totalMessages);
    });

    test('UserModel copyWith and avatarUrl handling', () {
      final user = UserModel(
        id: 'user_abc',
        email: 'test@bentara.id',
        name: 'Andro',
        role: UserRole.dengar,
        avatarUrl: null,
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(
        name: 'Andro Updated',
        avatarUrl: 'https://example.com/avatar.png',
      );

      expect(updated.id, 'user_abc');
      expect(updated.name, 'Andro Updated');
      expect(updated.avatarUrl, 'https://example.com/avatar.png');
      expect(updated.role, UserRole.dengar);

      final json = updated.toJson();
      final restored = UserModel.fromJson(json);
      expect(restored.name, 'Andro Updated');
      expect(restored.avatarUrl, 'https://example.com/avatar.png');
    });
  });

  group('History & Conversation Offline Model Tests', () {
    test('ConversationModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final convo = ConversationModel(
        id: 'convo_001',
        userId: 'user_123',
        title: 'Halo dokter, saya pusing...',
        context: 'hospital',
        startedAt: now,
      );

      final json = convo.toJson();
      expect(json['id'], 'convo_001');
      expect(json['title'], 'Halo dokter, saya pusing...');
      expect(json['context'], 'hospital');

      final restored = ConversationModel.fromJson(json);
      expect(restored.id, convo.id);
      expect(restored.title, convo.title);
      expect(restored.context, convo.context);
      expect(restored.userId, convo.userId);
    });

    test('MessageModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final msg = MessageModel(
        id: 'msg_001',
        conversationId: 'convo_001',
        senderType: 'tuli',
        inputType: 'sign',
        originalText: '0_halo',
        processedText: 'Halo',
        outputText: 'Halo',
        createdAt: now,
      );

      final json = msg.toJson();
      expect(json['id'], 'msg_001');
      expect(json['sender_type'], 'tuli');
      expect(json['input_type'], 'sign');
      expect(json['output_text'], 'Halo');

      final restored = MessageModel.fromJson(json);
      expect(restored.id, msg.id);
      expect(restored.conversationId, msg.conversationId);
      expect(restored.senderType, msg.senderType);
      expect(restored.outputText, msg.outputText);
    });
  });
}
