import 'package:bentara/core/theme/app_colors.dart';
import 'package:bentara/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OnboardingScreen renders all visual elements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify BENTARA logo wordmark is rendered
    expect(find.text('BENTARA'), findsOneWidget);

    // Verify tagline is rendered
    expect(find.text('Menjembatani komunikasi, mendekatkan hati'), findsOneWidget);

    // Verify SIGN UP button
    expect(find.text('SIGN UP'), findsOneWidget);

    // Verify secondary link
    expect(find.text('Sudah punya akun sebelumnya?'), findsOneWidget);

    // Verify SIGN IN button
    expect(find.text('SIGN IN'), findsOneWidget);

    // Verify button colors
    final signUpButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('SIGN UP'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(signUpButton.style?.backgroundColor?.resolve({}), AppColors.primary);

    final signInButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('SIGN IN'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(signInButton.style?.backgroundColor?.resolve({}), AppColors.darkCharcoal);
  });
}
