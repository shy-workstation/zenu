import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/pet.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../pet/pet_view.dart';
import '../zenu_theme.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final game = care.state.game;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.v2Wardrobe,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: ZenuColors.sparks),
                    const SizedBox(width: 5),
                    Text(
                      '${game.sparks}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PetView(
            species: game.species ?? PetSpecies.miro,
            mood: PetMood.content,
            worn: game.worn,
            size: 170,
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.86,
              children: [
                for (final cosmetic in Cosmetics.catalog)
                  _CosmeticTile(care: care, cosmetic: cosmetic, l10n: l10n),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 18, color: ZenuColors.sparks),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.v2WardrobeHint,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmeticTile extends StatelessWidget {
  final CareService care;
  final Cosmetic cosmetic;
  final AppLocalizations l10n;

  const _CosmeticTile({
    required this.care,
    required this.cosmetic,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = care.state.game;
    final owned = game.ownedCosmetics.contains(cosmetic.id);
    final wearing = game.worn[cosmetic.slot] == cosmetic.id;
    final affordable = care.canAfford(cosmetic);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        if (owned) {
          await care.wearCosmetic(cosmetic.id);
        } else {
          final bought = await care.buyCosmetic(cosmetic.id);
          if (bought) await care.wearCosmetic(cosmetic.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: owned
              ? theme.cardTheme.color
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            width: 2.5,
            color: wearing ? ZenuColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              size: 34,
              color: owned
                  ? ZenuColors.primary
                  : theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: affordable ? 0.8 : 0.45),
            ),
            const SizedBox(height: 7),
            Text(
              _name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            if (wearing)
              Text(
                l10n.v2Wearing,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: ZenuColors.primary,
                ),
              )
            else if (owned)
              Text(
                l10n.v2Owned,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 11, color: ZenuColors.sparks),
                  const SizedBox(width: 3),
                  Text(
                    '${cosmetic.cost}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (cosmetic.id) {
        'cozyScarf' => Icons.checkroom,
        'roundGlasses' => Icons.visibility_outlined,
        'leafCrown' => Icons.eco_outlined,
        'nightCap' => Icons.nightlight_outlined,
        'tinyMug' => Icons.coffee_outlined,
        'starCharm' => Icons.star_outline,
        _ => Icons.card_giftcard,
      };

  String get _name => switch (cosmetic.id) {
        'cozyScarf' => l10n.v2CosmeticCozyScarf,
        'roundGlasses' => l10n.v2CosmeticRoundGlasses,
        'leafCrown' => l10n.v2CosmeticLeafCrown,
        'nightCap' => l10n.v2CosmeticNightCap,
        'tinyMug' => l10n.v2CosmeticTinyMug,
        'starCharm' => l10n.v2CosmeticStarCharm,
        _ => cosmetic.id,
      };
}
