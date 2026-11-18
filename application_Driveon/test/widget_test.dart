import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shows the login screen with login and register actions', (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await tester.pumpWidget(const MyApp());

    expect(find.text('DriveON'), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
    expect(find.text('Registrati'), findsOneWidget);
  });
}
