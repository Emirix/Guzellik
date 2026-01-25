import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guzellik_app/presentation/widgets/common/trust_badge.dart';
import 'package:guzellik_app/core/theme/app_colors.dart';

void main() {
  group('TrustBadge Widget Tests', () {
    Widget createWidgetUnderTest({
      required TrustBadgeType type,
      bool showLabel = true,
      double size = 24,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TrustBadge(type: type, showLabel: showLabel, size: size),
        ),
      );
    }

    group('Verified Badge', () {
      testWidgets('renders verified icon correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.verified),
        );

        expect(find.byIcon(Icons.verified), findsOneWidget);
      });

      testWidgets('displays "Onaylı Mekan" label when showLabel is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.verified, showLabel: true),
        );

        expect(find.text('Onaylı Mekan'), findsOneWidget);
      });

      testWidgets('hides label when showLabel is false', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            type: TrustBadgeType.verified,
            showLabel: false,
          ),
        );

        expect(find.text('Onaylı Mekan'), findsNothing);
        expect(find.byIcon(Icons.verified), findsOneWidget);
      });

      testWidgets('uses correct color for verified badge', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            type: TrustBadgeType.verified,
            showLabel: false,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
        expect(icon.color, AppColors.verifiedBadge);
      });
    });

    group('Popular Badge', () {
      testWidgets('renders star icon correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.popular),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('displays "En Çok Tercih Edilen" label', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.popular, showLabel: true),
        );

        expect(find.text('En Çok Tercih Edilen'), findsOneWidget);
      });

      testWidgets('uses correct color for popular badge', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.popular, showLabel: false),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(icon.color, AppColors.popularBadge);
      });
    });

    group('Hygiene Badge', () {
      testWidgets('renders health_and_safety icon correctly', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.hygiene),
        );

        expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
      });

      testWidgets('displays "Hijyen Onaylı" label', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.hygiene, showLabel: true),
        );

        expect(find.text('Hijyen Onaylı'), findsOneWidget);
      });

      testWidgets('uses correct color for hygiene badge', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.hygiene, showLabel: false),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.health_and_safety));
        expect(icon.color, AppColors.hygieneBadge);
      });
    });

    group('Size Tests', () {
      testWidgets('respects custom size when showLabel is false', (
        tester,
      ) async {
        const customSize = 32.0;
        await tester.pumpWidget(
          createWidgetUnderTest(
            type: TrustBadgeType.verified,
            showLabel: false,
            size: customSize,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
        expect(icon.size, customSize);
      });

      testWidgets('icon size is 0.8x of size when showLabel is true', (
        tester,
      ) async {
        const customSize = 30.0;
        await tester.pumpWidget(
          createWidgetUnderTest(
            type: TrustBadgeType.verified,
            showLabel: true,
            size: customSize,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
        expect(icon.size, customSize * 0.8);
      });
    });

    group('Container Styling', () {
      testWidgets('has Container with border when showLabel is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidgetUnderTest(type: TrustBadgeType.verified, showLabel: true),
        );

        // Should find a Container (the badge container)
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('renders only Icon when showLabel is false', (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            type: TrustBadgeType.verified,
            showLabel: false,
          ),
        );

        // Should NOT have Row (only icon)
        expect(find.byType(Row), findsNothing);
        expect(find.byIcon(Icons.verified), findsOneWidget);
      });
    });
  });
}
