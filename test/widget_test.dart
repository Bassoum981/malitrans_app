import 'package:flutter_test/flutter_test.dart';

import 'package:mali_trans_app/app/app.dart';

void main() {
  testWidgets('affiche l’espace de connexion chauffeur', (tester) async {
    await tester.pumpWidget(MaliTransApp());

    expect(find.text('Espace chauffeur'), findsOneWidget);
    expect(find.text('Adresse email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('valide les champs de connexion', (tester) async {
    await tester.pumpWidget(MaliTransApp());

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Saisissez votre adresse email.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
  });
}
