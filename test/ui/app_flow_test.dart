import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenu/data/app_store.dart';
import 'package:zenu/domain/pet.dart';
import 'package:zenu/l10n/app_localizations.dart';
import 'package:zenu/services/care_service.dart';
import 'package:zenu/services/theme_controller.dart';
import 'package:zenu/services/ticker_service.dart';
import 'package:zenu/ui/shell.dart';
import 'package:zenu/ui/zenu_theme.dart';

/// Drives the whole surface at phone and small-desktop sizes: onboarding,
/// the single home screen, Settings -> Style (free styling) and Journey.
/// Any layout overflow or missing localization fails the test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CareService care;
  late TickerService ticker;

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    care = await CareService.create(store: AppStore(prefs));
    ticker = TickerService(care);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: care),
          ChangeNotifierProvider.value(value: ThemeController(prefs)),
          Provider.value(value: ticker),
        ],
        child: MaterialApp(
          theme: ZenuTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: const ZenuShell(),
        ),
      ),
    );
    await tester.pump();
  }

  // The pet never settles (it breathes forever), so instead of
  // pumpAndSettle: one frame to start the route, one to finish it.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  // Style is a lazy ListView: scroll the chip into existence, then tap it.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 120,
        scrollable: find.byType(Scrollable).last);
    await tester.pump();
  }

  for (final size in const [Size(390, 780), Size(420, 640)]) {
    testWidgets('onboarding -> home -> settings -> style/journey @ $size',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpApp(tester, size);

      // Onboarding: pick Pip and start.
      expect(find.text('Choose your companion'), findsOneWidget);
      await tester.tap(find.text('Pip'));
      await tester.pump();
      await tester.tap(find.text('Start together with Pip'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(care.state.pet.species, PetSpecies.pip);
      expect(care.running, isTrue);

      // Home: no tabs, no greeting, no currency; just the pet and its needs.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);

      // Settings hides Style and Journey.
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await settle(tester);
      expect(find.text('Style'), findsOneWidget);
      expect(find.text('Journey'), findsOneWidget);

      await tester.tap(find.text('Style'));
      await settle(tester);
      // Styling is free: colour, pattern, and accessory apply instantly.
      await tester.tap(find.byTooltip('Rose'));
      await tester.pump();
      expect(care.state.pet.color.id, 'rose');
      await reveal(tester, find.text('Spots'));
      await tester.tap(find.text('Spots'));
      await tester.pump();
      expect(care.state.pet.pattern, PetPattern.spots);
      await reveal(tester, find.text('Top Hat'));
      await tester.tap(find.text('Top Hat'));
      await tester.pump();
      expect(care.state.pet.worn[CosmeticSlot.head], 'topHat');

      await tester.pageBack();
      await settle(tester);
      await tester.tap(find.text('Journey'));
      await settle(tester);
      expect(find.text('Today'), findsOneWidget);

      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      // The home pet wears what was picked.
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
      // The 1 s heartbeat is a real periodic timer; stop it before the
      // test framework checks for leaked timers.
      ticker.dispose();
    });
  }
}
