import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/pet.dart';
import '../../domain/pet_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../pet/pet_view.dart';
import '../zenu_theme.dart';

class ChoosePetScreen extends StatefulWidget {
  const ChoosePetScreen({super.key});

  @override
  State<ChoosePetScreen> createState() => _ChoosePetScreenState();
}

class _ChoosePetScreenState extends State<ChoosePetScreen> {
  PetSpecies selected = PetSpecies.miro;

  static const names = {
    PetSpecies.miro: 'Miro',
    PetSpecies.pip: 'Pip',
    PetSpecies.luma: 'Luma',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.v2ChooseCompanionTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.v2ChooseCompanionSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final species in PetSpecies.values)
                      _petCard(species, l10n, theme),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () async {
                  final care = context.read<CareService>();
                  await care.choosePet(selected);
                  await care.refreshPermissionStatus(request: true);
                  await care.startSession();
                },
                child: Text(l10n.v2StartTogether(names[selected]!)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _petCard(PetSpecies species, AppLocalizations l10n, ThemeData theme) {
    final isSelected = species == selected;
    final blurb = switch (species) {
      PetSpecies.miro => l10n.v2BlurbMiro,
      PetSpecies.pip => l10n.v2BlurbPip,
      PetSpecies.luma => l10n.v2BlurbLuma,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => selected = species),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 3,
              color: isSelected ? ZenuColors.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              PetView(
                profile: PetProfile(species: species),
                mood: PetMood.content,
                size: 88,
                animated: isSelected,
                onTap: () => setState(() => selected = species),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      names[species]!,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      blurb,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
