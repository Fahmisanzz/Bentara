import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/communication/models/chat_message_model.dart';
import 'package:bentara/features/communication/presentation/widgets/edit_message_dialog.dart';

void main() {
  testWidgets('EditMessageDialog renders title, preview, textfield, and buttons', (WidgetTester tester) async {
    final message = ChatMessageModel(
      id: 'msg_1',
      text: 'Saya mau pergi ke kampus',
      sender: SenderType.userTuli,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      sourceType: SourceType.textInput,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  EditMessageDialog.show(
                    context: context,
                    message: message,
                    onSave: (val) {},
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Tap button to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify elements
    expect(find.text('Edit Pesan'), findsOneWidget);
    expect(find.text('Saya mau pergi ke kampus'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });
}
