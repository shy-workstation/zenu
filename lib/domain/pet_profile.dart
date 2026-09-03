import 'pet.dart';

/// Who the pet is and how it looks. Nothing here is earned or spent —
/// every colour, pattern, and accessory is the user's to pick freely.
class PetProfile {
  final PetSpecies? species;

  /// null = the species' own colour.
  final String? colorId;
  final PetPattern pattern;
  final Map<CosmeticSlot, String> worn;

  const PetProfile({
    this.species,
    this.colorId,
    this.pattern = PetPattern.plain,
    this.worn = const {},
  });

  bool get onboarded => species != null;

  PetColor get color =>
      PetColors.byId(colorId) ??
      PetColors.defaultFor(species ?? PetSpecies.miro);

  PetProfile copyWith({
    PetSpecies? species,
    String? colorId,
    bool clearColor = false,
    PetPattern? pattern,
    Map<CosmeticSlot, String>? worn,
  }) {
    return PetProfile(
      species: species ?? this.species,
      colorId: clearColor ? null : (colorId ?? this.colorId),
      pattern: pattern ?? this.pattern,
      worn: worn ?? this.worn,
    );
  }

  Map<String, dynamic> toJson() => {
        'species': species?.name,
        'colorId': colorId,
        'pattern': pattern.name,
        'worn': worn.map((slot, id) => MapEntry(slot.name, id)),
      };

  /// Tolerant of the earlier `game` blob: unknown keys (sparks, owned) are
  /// ignored, unknown cosmetic ids are dropped.
  factory PetProfile.fromJson(Map<String, dynamic> json) {
    PetSpecies? species;
    final speciesName = json['species'] as String?;
    if (speciesName != null) {
      for (final s in PetSpecies.values) {
        if (s.name == speciesName) species = s;
      }
    }
    var pattern = PetPattern.plain;
    final patternName = json['pattern'] as String?;
    for (final p in PetPattern.values) {
      if (p.name == patternName) pattern = p;
    }
    final worn = <CosmeticSlot, String>{};
    final wornJson = json['worn'];
    if (wornJson is Map) {
      wornJson.forEach((key, value) {
        for (final slot in CosmeticSlot.values) {
          if (slot.name == key &&
              value is String &&
              Cosmetics.byId(value)?.slot == slot) {
            worn[slot] = value;
          }
        }
      });
    }
    final colorId = json['colorId'] as String?;
    return PetProfile(
      species: species,
      colorId: PetColors.byId(colorId)?.id,
      pattern: pattern,
      worn: worn,
    );
  }
}
