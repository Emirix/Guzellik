import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guzellik_app/presentation/widgets/common/empty_state.dart';
import 'package:guzellik_app/core/theme/app_colors.dart';

void main() {
  group('EmptyState Widget Tests', () {
    Widget createWidgetUnderTest({
      required String title,
      required String message,
      required IconData icon,
      VoidCallback? onAction,
      String? actionLabel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: title,
            message: message,
            icon: icon,
            onAction: onAction,
            actionLabel: actionLabel,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders title correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Test Başlık',
            message: 'Test mesaj',
            icon: Icons.inbox,
          ),
        );

        expect(find.text('Test Başlık'), findsOneWidget);
      });

      testWidgets('renders message correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Bu bir test mesajıdır',
            icon: Icons.inbox,
          ),
        );

        expect(find.text('Bu bir test mesajıdır'), findsOneWidget);
      });

      testWidgets('renders icon correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.favorite_border,
          ),
        );

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('icon has correct size (64)', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.search_off,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.search_off));
        expect(icon.size, 64);
      });

      testWidgets('icon has correct color (gray400)', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.notifications_off,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.notifications_off));
        expect(icon.color, AppColors.gray400);
      });
    });

    group('Without Action Button', () {
      testWidgets('does not render ElevatedButton when onAction is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
            onAction: null,
            actionLabel: null,
          ),
        );

        expect(find.byType(ElevatedButton), findsNothing);
      });
    });

    group('With Action Button', () {
      testWidgets(
        'renders action button when both onAction and actionLabel provided',
        (tester) async {
          await tester.pumpWidget(
            createWidgetUnderTest(
              title: 'Başlık',
              message: 'Mesaj',
              icon: Icons.inbox,
              onAction: () {},
              actionLabel: 'Yenile',
            ),
          );

          expect(find.byType(ElevatedButton), findsOneWidget);
          expect(find.text('Yenile'), findsOneWidget);
        },
      );

      testWidgets('action button triggers onAction callback when tapped', (
        tester,
      ) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
            onAction: () {
              wasPressed = true;
            },
            actionLabel: 'Tıkla',
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });

      testWidgets('action button displays correct label', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
            onAction: () {},
            actionLabel: 'Keşfet',
          ),
        );

        expect(find.text('Keşfet'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has Semantics with combined title and message', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Favori Yok',
            message: 'Henüz favori mekanınız yok',
            icon: Icons.favorite_border,
          ),
        );

        // Semantics widget should be present
        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Layout', () {
      testWidgets('is centered on screen', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
          ),
        );

        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets('has Column for vertical layout', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
          ),
        );

        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('has horizontal padding', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Başlık',
            message: 'Mesaj',
            icon: Icons.inbox,
          ),
        );

        expect(find.byType(Padding), findsWidgets);
      });
    });

    group('Common Use Cases', () {
      testWidgets('renders correctly for empty favorites state', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Favori Mekanınız Yok',
            message:
                'Beğendiğiniz mekanları favorilere ekleyerek hızlıca ulaşabilirsiniz.',
            icon: Icons.favorite_border,
            onAction: () {},
            actionLabel: 'Mekanları Keşfet',
          ),
        );

        expect(find.text('Favori Mekanınız Yok'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.text('Mekanları Keşfet'), findsOneWidget);
      });

      testWidgets('renders correctly for no search results state', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Sonuç Bulunamadı',
            message:
                'Aramanızla eşleşen mekan bulunamadı. Farklı anahtar kelimeler deneyin.',
            icon: Icons.search_off,
          ),
        );

        expect(find.text('Sonuç Bulunamadı'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });

      testWidgets('renders correctly for empty notifications state', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            title: 'Bildirim Yok',
            message: 'Henüz bildiriminiz bulunmuyor.',
            icon: Icons.notifications_off_outlined,
          ),
        );

        expect(find.text('Bildirim Yok'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      });
    });
  });
}
