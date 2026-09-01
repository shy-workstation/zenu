import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/care_service.dart';
import 'home/pet_home_screen.dart';
import 'journey/journey_screen.dart';
import 'onboarding/choose_pet_screen.dart';
import 'settings/settings_screen.dart';
import 'wardrobe/wardrobe_screen.dart';

class ZenuShell extends StatefulWidget {
  const ZenuShell({super.key});

  @override
  State<ZenuShell> createState() => _ZenuShellState();
}

class _ZenuShellState extends State<ZenuShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    if (!care.state.game.onboarded) {
      return const ChoosePetScreen();
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // TickerMode stops the offstage tabs' animations (IndexedStack
          // alone keeps hidden pets breathing at frame rate forever).
          for (final (i, screen) in const [
            PetHomeScreen(),
            WardrobeScreen(),
            JourneyScreen(),
            SettingsScreen(),
          ].indexed)
            TickerMode(enabled: i == _index, child: screen),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets),
            label: l10n.v2TabPet,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checkroom_outlined),
            selectedIcon: const Icon(Icons.checkroom),
            label: l10n.v2TabWardrobe,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.v2TabJourney,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.v2TabSettings,
          ),
        ],
      ),
    );
  }
}
