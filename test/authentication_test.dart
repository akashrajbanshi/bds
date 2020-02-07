import 'package:bds/pages/authenticationpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {

    testWidgets('AuthenticationPage', (WidgetTester tester) async {
      /* FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
    GoogleSignInMock googleSignInMock = GoogleSignInMock();
    FacebookLoginMock facebookLoginMock = FacebookLoginMock();
    FirebaseMessagingMock firebaseMessagingMock = FirebaseMessagingMock();
    FirestoreMock firestoreMock = FirestoreMock();

    await tester.pumpWidget(AuthenticationPage(
        firebaseAuthMock,
        googleSignInMock,
        facebookLoginMock,
        firebaseMessagingMock,
        firestoreMock));*/

      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          home: AuthenticationPage(),
          navigatorObservers: [mockObserver],
        ),
      );


      var emailTextFieldKey = find.byKey(Key('email'));
      expect(emailTextFieldKey, findsOneWidget);
      await tester.tap(emailTextFieldKey);
      await tester.enterText(emailTextFieldKey, 'akashrajbanshi@hotmail.com');
      final TextField emailFormTextField =
          await tester.widget<TextField>(emailTextFieldKey);

      expect(emailFormTextField.controller.text, 'akashrajbanshi@hotmail.com');

      var passwordFieldKey = find.byKey(Key('password'));
      expect(passwordFieldKey, findsOneWidget);
      await tester.tap(passwordFieldKey);
      await tester.enterText(passwordFieldKey, 'password');
      final TextField passwordFormTextField =
          await tester.widget<TextField>(passwordFieldKey);

      expect(passwordFormTextField.controller.text, 'password');


      var loginButtonKey = find.byKey(Key('loginButton'));
      expect(loginButtonKey, findsOneWidget);

      var forgotPasswordButtonKey = find.byKey(Key('forgotLabel'));
      expect(forgotPasswordButtonKey,findsOneWidget);

      var googleButtonKey = find.byKey(Key('googleButton'));
      expect(googleButtonKey, findsOneWidget);

      var facebookButtonKey = find.byKey(Key('googleButton'));
      expect(facebookButtonKey, findsOneWidget);



      /*final GoogleSignInAccountMock googleSignInAccountMock =
        GoogleSignInAccountMock();
    final GoogleSignInAuthenticationMock googleSignInAuthenticationMock =
        GoogleSignInAuthenticationMock();

    test('signInWithGoogle returns a Firebase user', () {
      when(googleSignInMock.signIn()).thenAnswer((_) =>
          Future<GoogleSignInAccountMock>.value(googleSignInAccountMock));

      when(googleSignInAccountMock.authentication).thenAnswer((_) =>
          Future<GoogleSignInAuthenticationMock>.value(
              googleSignInAuthenticationMock));
    });*/
    });
}
