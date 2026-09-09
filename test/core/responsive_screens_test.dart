import 'package:bentara/core/services/local_storage_service.dart';
import 'package:bentara/core/theme/app_theme.dart';
import 'package:bentara/features/auth/data/auth_repository.dart';
import 'package:bentara/features/auth/models/user_model.dart';
import 'package:bentara/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:bentara/features/auth/presentation/screens/login_screen.dart';
import 'package:bentara/features/auth/presentation/screens/register_screen.dart';
import 'package:bentara/features/auth/providers/auth_provider.dart';
import 'package:bentara/features/auth/providers/auth_state.dart';
import 'package:bentara/features/communication/data/conversation_repository.dart';
import 'package:bentara/features/communication/models/chat_message_model.dart';
import 'package:bentara/features/communication/models/context_preset.dart';
import 'package:bentara/features/communication/presentation/screens/communication_screen.dart';
import 'package:bentara/features/communication/presentation/widgets/voice_recording_bar.dart';
import 'package:bentara/features/communication/providers/communication_provider.dart';
import 'package:bentara/features/communication/services/context_translation_service.dart';
import 'package:bentara/features/communication/services/stt_service.dart';
import 'package:bentara/features/communication/services/tts_service.dart';
import 'package:bentara/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:bentara/features/history/models/conversation_model.dart';
import 'package:bentara/features/history/presentation/screens/history_screen.dart';
import 'package:bentara/features/history/providers/history_provider.dart';
import 'package:bentara/features/home/presentation/screens/home_screen.dart';
import 'package:bentara/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:bentara/features/profile/models/user_profile_model.dart';
import 'package:bentara/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:bentara/features/profile/presentation/screens/profile_screen.dart';
import 'package:bentara/features/profile/providers/profile_provider.dart';
import 'package:bentara/features/quick_communication/models/quick_phrase_model.dart';
import 'package:bentara/features/quick_communication/presentation/screens/quick_communication_screen.dart';
import 'package:bentara/features/quick_communication/providers/quick_communication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class DeviceConfig {
  final String name;
  final Size size;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;
  final double textScaleFactor;

  const DeviceConfig({
    required this.name,
    required this.size,
    this.padding = const EdgeInsets.only(top: 24.0, bottom: 34.0),
    this.viewInsets = EdgeInsets.zero,
    this.textScaleFactor = 1.0,
  });
}

const testDevices = [
  // 1. Small Phone
  DeviceConfig(
    name: 'Small Phone (360x640)',
    size: Size(360, 640),
    padding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  // 2. Standard Phone
  DeviceConfig(
    name: 'Standard Phone (360x800)',
    size: Size(360, 800),
    padding: EdgeInsets.only(top: 28, bottom: 24),
  ),
  // 3. Modern Phone
  DeviceConfig(
    name: 'Modern Phone (390x844)',
    size: Size(390, 844),
    padding: EdgeInsets.only(top: 44, bottom: 34),
  ),
  // 4. Large Phone
  DeviceConfig(
    name: 'Large Phone (412x915)',
    size: Size(412, 915),
    padding: EdgeInsets.only(top: 32, bottom: 48),
  ),
  // 5. Extra Tall Phone
  DeviceConfig(
    name: 'Extra Tall Phone (430x932)',
    size: Size(430, 932),
    padding: EdgeInsets.only(top: 48, bottom: 34),
  ),
  // 6. 3-Button Navigation (Zero Bottom Padding)
  DeviceConfig(
    name: '3-Button Navigation (360x800, bottom=0)',
    size: Size(360, 800),
    padding: EdgeInsets.only(top: 24, bottom: 0),
  ),
  // 7. Keyboard Active (viewInsets bottom=300)
  DeviceConfig(
    name: 'Keyboard Active (390x844, keyboard=300)',
    size: Size(390, 844),
    padding: EdgeInsets.only(top: 44, bottom: 0),
    viewInsets: EdgeInsets.only(bottom: 300),
  ),
  // 8. Large Accessibility Font Scale 1.5x
  DeviceConfig(
    name: 'Large Font 1.5x (360x800)',
    size: Size(360, 800),
    padding: EdgeInsets.only(top: 28, bottom: 24),
    textScaleFactor: 1.5,
  ),
  // 9. Extra Large Accessibility Font Scale 2.0x
  DeviceConfig(
    name: 'Large Font 2.0x (390x844)',
    size: Size(390, 844),
    padding: EdgeInsets.only(top: 44, bottom: 34),
    textScaleFactor: 2.0,
  ),
];

// --- MOCK SERVICES & REPOSITORIES ---
class MockLocalStorageService implements ILocalStorageService {
  final Map<String, String> _storage = {};
  @override
  Future<void> init() async {}
  @override
  Future<void> saveString(String key, String value) async => _storage[key] = value;
  @override
  String? getString(String key) => _storage[key];
  @override
  Future<void> remove(String key) async => _storage.remove(key);
  @override
  Future<void> clear() async => _storage.clear();
}

class MockAuthRepository implements IAuthRepository {
  final UserModel dummyUser = UserModel(
    id: 'test_user_1',
    email: 'fahmibachtyar@gmail.com',
    name: 'Fahmi',
    role: UserRole.tuli,
    createdAt: DateTime.now(),
  );

  @override
  Stream<sb.AuthState> get authStateChanges => const Stream.empty();
  @override
  Future<UserModel?> getCurrentUser() async => dummyUser;
  @override
  Future<UserModel> signInWithEmail(String email, String password) async => dummyUser;
  @override
  Future<UserModel> signUpWithEmail(String name, String email, String password, UserRole role) async => dummyUser;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> resetPassword(String email) async {}
}

class MockSTTService implements ISTTService {
  @override
  bool get isListening => false;
  @override
  Future<bool> initialize() async => true;
  @override
  Future<bool> hasPermission() async => true;
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

class MockContextTranslationService implements IContextTranslationService {
  @override
  Future<String> translateContext({required String rawText, required ContextPreset preset}) async => rawText;
}

class MockConversationRepository implements IConversationRepository {
  @override
  Future<String> saveConversation(String title, String userId, {String? contextStr, String? id}) async => 'c_1';
  @override
  Future<void> saveMessage(String conversationId, ChatMessageModel message) async {}
  @override
  Future<void> updateMessage(String conversationId, String messageId, String newText, {DateTime? updatedAt}) async {}
  @override
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId) async => [];
}

class MockAuthNotifier extends StateNotifier<AppAuthState> implements AuthNotifier {
  MockAuthNotifier() : super(const AuthInitial());
  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<void> signUp(String name, String email, String password, UserRole role) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> resetPassword(String email) async {}
}

class MockProfileNotifier extends StateNotifier<ProfileState> implements ProfileNotifier {
  MockProfileNotifier()
      : super(
          const ProfileState(
            profile: UserProfileModel(
              id: 'test_user_1',
              name: 'Fahmi Bachtyar',
              role: 'tuli',
              avatarUrl: null,
              totalSessions: 12,
              totalMessages: 45,
            ),
          ),
        );
  @override
  Future<void> loadProfile() async {}
  @override
  void reset() {}
  @override
  Future<bool> updateProfile({String? name, String? role, String? avatarUrl}) async => true;
}

class MockQuickCommNotifier extends StateNotifier<QuickCommunicationState>
    implements QuickCommunicationNotifier {
  MockQuickCommNotifier()
      : super(
          QuickCommunicationState(
            phrases: AsyncValue.data([
              QuickPhraseModel(
                id: 'p1',
                phrase: 'Tolong bantu saya',
                category: 'Umum',
                isEmergency: false,
                createdAt: DateTime.now(),
                isFavorite: true,
              ),
              QuickPhraseModel(
                id: 'p2',
                phrase: 'Berapa harganya?',
                category: 'Umum',
                isEmergency: false,
                createdAt: DateTime.now(),
                isFavorite: false,
              ),
            ]),
          ),
        );
  @override
  void setCategory(String? category) {}
  @override
  void setSearchQuery(String query) {}
  @override
  void toggleFavorite(String id) {}
  @override
  Future<void> speakPhrase(String phrase) async {}
}

class MockHistoryListNotifier extends StateNotifier<AsyncValue<List<ConversationModel>>>
    implements HistoryListNotifier {
  MockHistoryListNotifier()
      : super(
          AsyncValue.data([
            ConversationModel(
              id: 'c1',
              userId: 'u1',
              title: 'Percakapan di Rumah Sakit',
              context: 'Medis',
              startedAt: DateTime.now(),
            ),
          ]),
        );
  @override
  void reset() {}
  @override
  Future<void> loadHistory() async {}
  @override
  Future<bool> deleteConversation(String id) async => true;
}

final testOverrides = <Override>[
  localStorageProvider.overrideWithValue(MockLocalStorageService()),
  authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  sttServiceProvider.overrideWithValue(MockSTTService()),
  ttsServiceProvider.overrideWithValue(MockTTSService()),
  contextTranslationServiceProvider.overrideWithValue(MockContextTranslationService()),
  conversationRepositoryProvider.overrideWithValue(MockConversationRepository()),
  currentUserProvider.overrideWith(
    (ref) => UserModel(
      id: 'test_user_1',
      email: 'fahmibachtyar@gmail.com',
      name: 'Fahmi',
      role: UserRole.tuli,
      createdAt: DateTime.now(),
    ),
  ),
  authNotifierProvider.overrideWith((ref) => MockAuthNotifier()),
  profileNotifierProvider.overrideWith((ref) => MockProfileNotifier()),
  quickCommNotifierProvider.overrideWith((ref) => MockQuickCommNotifier()),
  historyListProvider.overrideWith((ref) => MockHistoryListNotifier()),
];

Widget createTestApp({
  required Widget child,
  required DeviceConfig device,
}) {
  return ProviderScope(
    overrides: testOverrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: device.size,
          padding: device.padding,
          viewInsets: device.viewInsets,
          textScaler: TextScaler.linear(device.textScaleFactor),
        ),
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RESPONSIVENESS & BOTTOM INSET MATRIX TESTS', () {
    for (final device in testDevices) {
      testWidgets('HomeScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('BENTARA'), findsWidgets);
        expect(find.text('MODE DARURAT'), findsOneWidget);
        expect(find.text('Menu Utama'), findsOneWidget);
        expect(find.text('Komunikasi\nLangsung'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('EmergencyScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const EmergencyScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mode Darurat'), findsOneWidget);
        expect(find.text('PILIH PESAN DARURAT'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('CommunicationScreen renders composer cleanly on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const CommunicationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Komunikasi Live'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byKey(const ValueKey('composer_mic_button')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('VoiceRecordingBar renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: VoiceRecordingBar(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Jeda'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('QuickCommunicationScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const QuickCommunicationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Komunikasi Cepat'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('HistoryScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const HistoryScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Riwayat Percakapan'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('ProfileScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const ProfileScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Profil Pengguna'), findsOneWidget);
        expect(find.text('Keluar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('EditProfileScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const EditProfileScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Edit Profil'), findsOneWidget);
        expect(find.text('Simpan Perubahan'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('OnboardingScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const OnboardingScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('BENTARA'), findsOneWidget);
        expect(find.text('SIGN UP'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('LoginScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('SIGN IN'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('RegisterScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('SIGN UP'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('ForgotPasswordScreen renders with zero overflow on ${device.name}', (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          createTestApp(
            device: device,
            child: const ForgotPasswordScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('LUPA\nPASSWORD'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
