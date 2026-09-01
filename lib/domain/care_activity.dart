/// A wellness activity the pet mirrors: drink water, rest eyes, move,
/// stretch, strength. Activities are data, not a closed enum, so future
/// custom activities only need a new id + kind token.
class CareActivity {
  final String id;

  /// Semantic token driving icon, color, and copy. Equals [id] for built-ins.
  final String kind;

  final Duration interval;
  final bool enabled;

  /// Quantity captured on completion. [unit] empty means "no quantity" —
  /// completing is a simple check-off.
  final int goalQty;
  final int minQty;
  final int maxQty;
  final int stepQty;
  final String unit;

  const CareActivity({
    required this.id,
    required this.kind,
    required this.interval,
    this.enabled = true,
    this.goalQty = 1,
    this.minQty = 1,
    this.maxQty = 1,
    this.stepQty = 1,
    this.unit = '',
  });

  bool get hasQuantity => unit.isNotEmpty;

  CareActivity copyWith({Duration? interval, bool? enabled, int? goalQty}) {
    return CareActivity(
      id: id,
      kind: kind,
      interval: interval ?? this.interval,
      enabled: enabled ?? this.enabled,
      goalQty: goalQty ?? this.goalQty,
      minQty: minQty,
      maxQty: maxQty,
      stepQty: stepQty,
      unit: unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'intervalSec': interval.inSeconds,
        'enabled': enabled,
        'goalQty': goalQty,
        'minQty': minQty,
        'maxQty': maxQty,
        'stepQty': stepQty,
        'unit': unit,
      };

  factory CareActivity.fromJson(Map<String, dynamic> json) {
    final fallback = Activities.byId(json['id'] as String? ?? '');
    return CareActivity(
      id: json['id'] as String? ?? Activities.stretch.id,
      kind: json['kind'] as String? ?? fallback?.kind ?? Activities.stretch.kind,
      interval: Duration(
        seconds: (json['intervalSec'] as num?)?.toInt() ??
            fallback?.interval.inSeconds ??
            3600,
      ),
      enabled: json['enabled'] as bool? ?? true,
      goalQty: (json['goalQty'] as num?)?.toInt() ?? fallback?.goalQty ?? 1,
      minQty: (json['minQty'] as num?)?.toInt() ?? fallback?.minQty ?? 1,
      maxQty: (json['maxQty'] as num?)?.toInt() ?? fallback?.maxQty ?? 1,
      stepQty: (json['stepQty'] as num?)?.toInt() ?? fallback?.stepQty ?? 1,
      unit: json['unit'] as String? ?? fallback?.unit ?? '',
    );
  }
}

/// The five built-in activities and their defaults.
class Activities {
  static const water = CareActivity(
    id: 'water',
    kind: 'water',
    interval: Duration(minutes: 30),
    goalQty: 250,
    minQty: 50,
    maxQty: 1000,
    stepQty: 50,
    unit: 'ml',
  );

  static const eyeRest = CareActivity(
    id: 'eyeRest',
    kind: 'eyeRest',
    interval: Duration(minutes: 20),
  );

  static const move = CareActivity(
    id: 'move',
    kind: 'move',
    interval: Duration(minutes: 45),
  );

  static const stretch = CareActivity(
    id: 'stretch',
    kind: 'stretch',
    interval: Duration(minutes: 60),
  );

  static const strength = CareActivity(
    id: 'strength',
    kind: 'strength',
    interval: Duration(minutes: 90),
    goalQty: 10,
    minQty: 1,
    maxQty: 50,
    stepQty: 1,
    unit: 'reps',
  );

  static const List<CareActivity> defaults = [
    water,
    eyeRest,
    move,
    stretch,
    strength,
  ];

  static CareActivity? byId(String id) {
    for (final a in defaults) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Stable small index used to derive collision-free notification ids.
  static int notificationSlot(String id) {
    final index = defaults.indexWhere((a) => a.id == id);
    return index >= 0 ? index : defaults.length + (id.hashCode.abs() % 100);
  }
}
