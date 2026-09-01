/// One logged care moment. Full timestamps (UTC epoch ms) so streaks,
/// charts, and the pet's state can all be derived later — history is
/// never pruned.
class CompletionEvent {
  final String activityId;
  final int atMs;
  final int qty;

  const CompletionEvent({
    required this.activityId,
    required this.atMs,
    this.qty = 1,
  });

  DateTime get at => DateTime.fromMillisecondsSinceEpoch(atMs, isUtc: true);

  Map<String, dynamic> toJson() => {'a': activityId, 't': atMs, 'q': qty};

  factory CompletionEvent.fromJson(Map<String, dynamic> json) {
    return CompletionEvent(
      activityId: json['a'] as String,
      atMs: (json['t'] as num).toInt(),
      qty: (json['q'] as num?)?.toInt() ?? 1,
    );
  }
}
