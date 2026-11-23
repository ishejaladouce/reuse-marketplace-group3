import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reuse_marketplace/core/utils/validators.dart';
import 'package:reuse_marketplace/core/widgets/app_text_field.dart';

void main() {
  late TextEditingController controller;
  late GlobalKey<FormState> formKey;

  setUp(() {
    controller = TextEditingController();
    formKey = GlobalKey<FormState>();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpField(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: controller,
              validator: Validators.email,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows its label and hint', (tester) async {
    await pumpField(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('you@example.com'), findsOneWidget);
  });

  testWidgets('shows an error message for an invalid email', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('shows no error for a valid email', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextFormField), 'ishejaladouce@gmail.com');
    final isValid = formKey.currentState!.validate();
    await tester.pump();

    expect(isValid, isTrue);
    expect(find.text('Please enter a valid email address'), findsNothing);
  });
}