import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/pet.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../pet/pet_painter.dart';
import '../pet/pet_view.dart';
import '../zenu_theme.dart';

/// Dress the pet however you like. Everything is free and applies
/// instantly on the live preview; there is nothing to earn or unlock.
class StyleScreen extends StatelessWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final l10n = AppLocalizations.of(context)!;
    final pet = care.state.pet;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.v2Style)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        children: [
          Center(
            child: PetView(profile: pet, mood: PetMood.content, size: 190),
          ),
          _Section(l10n.v2Colour),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in PetColors.palette)
                _Swatch(
                  color: c,
                  label: _colorName(l10n, c.id),
                  selected: pet.color.id == c.id,
                  onTap: () => care.setPetColor(
                    c.id == PetColors.defaultFor(pet.species!).id
                        ? null
                        : c.id,
                  ),
                ),
            ],
          ),
          _Section(l10n.v2Pattern),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in PetPattern.values)
                ChoiceChip(
                  label: Text(_patternName(l10n, p)),
                  selected: pet.pattern == p,
                  onSelected: (_) => care.setPetPattern(p),
                ),
            ],
          ),
          for (final slot in CosmeticSlot.values) ...[
            _Section(_slotName(l10n, slot)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.v2None),
                  selected: pet.worn[slot] == null,
                  onSelected: (_) => care.clearSlot(slot),
                ),
                for (final c in Cosmetics.forSlot(slot))
                  ChoiceChip(
                    avatar: Icon(cosmeticIcon(c.id), size: 18),
                    label: Text(cosmeticName(l10n, c.id)),
                    selected: pet.worn[slot] == c.id,
                    onSelected: (_) => care.wearCosmetic(c.id),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _colorName(AppLocalizations l10n, String id) => switch (id) {
        'mint' => l10n.v2ColorMint,
        'sky' => l10n.v2ColorSky,
        'lilac' => l10n.v2ColorLilac,
        'peach' => l10n.v2ColorPeach,
        'rose' => l10n.v2ColorRose,
        'lemon' => l10n.v2ColorLemon,
        'aqua' => l10n.v2ColorAqua,
        'slate' => l10n.v2ColorSlate,
        _ => id,
      };

  String _patternName(AppLocalizations l10n, PetPattern p) => switch (p) {
        PetPattern.plain => l10n.v2PatternPlain,
        PetPattern.spots => l10n.v2PatternSpots,
        PetPattern.freckles => l10n.v2PatternFreckles,
        PetPattern.stripes => l10n.v2PatternStripes,
        PetPattern.heart => l10n.v2PatternHeart,
      };

  String _slotName(AppLocalizations l10n, CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.head => l10n.v2SlotHead,
        CosmeticSlot.face => l10n.v2SlotFace,
        CosmeticSlot.neck => l10n.v2SlotNeck,
        CosmeticSlot.charm => l10n.v2SlotCharm,
      };

  static IconData cosmeticIcon(String id) => switch (id) {
        'cozyScarf' => Icons.checkroom,
        'bowTie' => Icons.diamond_outlined,
        'bandana' => Icons.change_history,
        'bellCollar' => Icons.notifications_none,
        'roundGlasses' => Icons.visibility_outlined,
        'sunglasses' => Icons.wb_sunny_outlined,
        'monocle' => Icons.search,
        'eyePatch' => Icons.visibility_off_outlined,
        'leafCrown' => Icons.eco_outlined,
        'nightCap' => Icons.nightlight_outlined,
        'beanie' => Icons.ac_unit,
        'topHat' => Icons.theater_comedy_outlined,
        'hairBow' => Icons.card_giftcard,
        'halo' => Icons.brightness_1_outlined,
        'flowerClip' => Icons.local_florist_outlined,
        'tinyMug' => Icons.coffee_outlined,
        'starCharm' => Icons.star_outline,
        'heartCharm' => Icons.favorite_outline,
        'balloon' => Icons.celebration_outlined,
        'butterfly' => Icons.flutter_dash,
        _ => Icons.circle_outlined,
      };

  static String cosmeticName(AppLocalizations l10n, String id) => switch (id) {
        'cozyScarf' => l10n.v2CosmeticCozyScarf,
        'bowTie' => l10n.v2CosmeticBowTie,
        'bandana' => l10n.v2CosmeticBandana,
        'bellCollar' => l10n.v2CosmeticBellCollar,
        'roundGlasses' => l10n.v2CosmeticRoundGlasses,
        'sunglasses' => l10n.v2CosmeticSunglasses,
        'monocle' => l10n.v2CosmeticMonocle,
        'eyePatch' => l10n.v2CosmeticEyePatch,
        'leafCrown' => l10n.v2CosmeticLeafCrown,
        'nightCap' => l10n.v2CosmeticNightCap,
        'beanie' => l10n.v2CosmeticBeanie,
        'topHat' => l10n.v2CosmeticTopHat,
        'hairBow' => l10n.v2CosmeticHairBow,
        'halo' => l10n.v2CosmeticHalo,
        'flowerClip' => l10n.v2CosmeticFlowerClip,
        'tinyMug' => l10n.v2CosmeticTinyMug,
        'starCharm' => l10n.v2CosmeticStarCharm,
        'heartCharm' => l10n.v2CosmeticHeartCharm,
        'balloon' => l10n.v2CosmeticBalloon,
        'butterfly' => l10n.v2CosmeticButterfly,
        _ => id,
      };
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      );
}

class _Swatch extends StatelessWidget {
  final PetColor color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.top, color.bottom],
              ),
              border: Border.all(
                width: selected ? 3.5 : 0,
                color: selected ? ZenuColors.primary : Colors.transparent,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 20, color: PetPainter.ink)
                : null,
          ),
        ),
      ),
    );
  }
}
