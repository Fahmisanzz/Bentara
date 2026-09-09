import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/communication/models/chat_message_model.dart';
import 'package:bentara/features/communication/presentation/widgets/context_message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ContextMessageBubble menu tap opens EditMessageDialog', (WidgetTester tester) async {
    final message = ChatMessageModel(
      id: 'msg_1',
      text: 'Saya mau pergi ke kampus',
      sender: SenderType.userTuli,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      sourceType: SourceType.textInput,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ContextMessageBubble(message: message),
          ),
        ),
      ),
    );

    // Find PopupMenuButton icon
    final popupIcon = find.byIcon(Icons.more_horiz_rounded);
    expect(popupIcon, findsOneWidget);

    await tester.tap(popupIcon);
    await tester.pumpAndSettle();

    // Tap "Edit Pesan"
    final editOption = find.text('Edit Pesan');
    expect(editOption, findsOneWidget);

    await tester.tap(editOption);
    await tester.pumpAndSettle();

    // Verify Edit dialog appears
    expect(find.text('Edit Pesan'), findsWidgets);
    expect(find.text('Saya mau pergi ke kampus'), findsWidgets);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('ContextMessageBubble long-press opens EditMessageDialog', (WidgetTester tester) async {
    final message = ChatMessageModel(
      id: 'msg_2',
      text: 'Pesan untuk di-long-press',
      sender: SenderType.userTuli,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      sourceType: SourceType.textInput,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ContextMessageBubble(message: message),
          ),
        ),
      ),
    );

    // Long press the bubble
    await tester.longPress(find.text('Pesan untuk di-long-press'));
    await tester.pumpAndSettle();

    // Verify Edit dialog appears
    expect(find.text('Edit Pesan'), findsWidgets);
    expect(find.text('Pesan untuk di-long-press'), findsWidgets);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });
}
