import 'pet.dart';

/// Sparks earned per logged care moment. Gentle economy: earn only,
/// spend only in the wardrobe, nothing is ever taken away.
const int sparksPerCare = 5;

class GameState {
  final PetSpecies? species;
  final int sparks;
  final Set<String> ownedCosmetics;
  final Map<CosmeticSlot, String> worn;

  const GameState({
    this.species,
    this.sparks = 0,
    this.ownedCosmetics = const {},
    this.worn = const {},
  });

  bool get onboarded => species != null;

  GameState copyWith({
    PetSpecies? species,
    int? sparks,
    Set<String>? ownedCosmetics,
    Map<CosmeticSlot, String>? worn,
  }) {
    return GameState(
      species: species ?? this.species,
      sparks: sparks ?? this.sparks,
      ownedCosmetics: ownedCosmetics ?? this.ownedCosmetics,
      worn: worn ?? this.worn,
    );
  }

  Map<String, dynamic> toJson() => {
        'species': species?.name,
        'sparks': sparks,
        'owned': ownedCosmetics.toList(),
        'worn': worn.map((slot, id) => MapEntry(slot.name, id)),
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    PetSpecies? species;
    final speciesName = json['species'] as String?;
    if (speciesName != null) {
      for (final s in PetSpecies.values) {
        if (s.name == speciesName) species = s;
      }
    }
    final worn = <CosmeticSlot, String>{};
    final wornJson = json['worn'];
    if (wornJson is Map) {
      wornJson.forEach((key, value) {
        for (final slot in CosmeticSlot.values) {
          if (slot.name == key && value is String) worn[slot] = value;
        }
      });
    }
    return GameState(
      species: species,
      sparks: (json['sparks'] as num?)?.toInt() ?? 0,
      ownedCosmetics: ((json['owned'] as List?) ?? const [])
          .whereType<String>()
          .toSet(),
      worn: worn,
    );
  }
}
