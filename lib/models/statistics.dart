class Statistics {
  final Map<String, int> dailyCompletions;
  final Map<String, int> weeklyCompletions;
  final Map<String, int> totalCompletions;
  final DateTime lastUpdate;
  DateTime? lastReset;

  Statistics({
    Map<String, int>? dailyCompletions,
    Map<String, int>? weeklyCompletions,
    Map<String, int>? totalCompletions,
    DateTime? lastUpdate,
    this.lastReset,
  }) : dailyCompletions = dailyCompletions ?? {},
       weeklyCompletions = weeklyCompletions ?? {},
       totalCompletions = totalCompletions ?? {},
       lastUpdate = lastUpdate ?? DateTime.now();

  Statistics copyWith({
    Map<String, int>? dailyCompletions,
    Map<String, int>? weeklyCompletions,
    Map<String, int>? totalCompletions,
    DateTime? lastUpdate,
  }) {
    return Statistics(
      dailyCompletions: dailyCompletions ?? this.dailyCompletions,
      weeklyCompletions: weeklyCompletions ?? this.weeklyCompletions,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyCompletions': dailyCompletions,
    'weeklyCompletions': weeklyCompletions,
    'totalCompletions': totalCompletions,
    'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    'lastReset': lastReset?.millisecondsSinceEpoch,
  };

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
      weeklyCompletions: Map<String, int>.from(json['weeklyCompletions'] ?? {}),
      totalCompletions: Map<String, int>.from(json['totalCompletions'] ?? {}),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastReset:
          json['lastReset'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['lastReset'])
              : null,
    );
  }

  void incrementCount(String reminderId, int count) {
    dailyCompletions[reminderId] = (dailyCompletions[reminderId] ?? 0) + count;
    weeklyCompletions[reminderId] =
        (weeklyCompletions[reminderId] ?? 0) + count;
    totalCompletions[reminderId] = (totalCompletions[reminderId] ?? 0) + count;
  }

  void removeReminderStats(String reminderId) {
    dailyCompletions.remove(reminderId);
    weeklyCompletions.remove(reminderId);
    totalCompletions.remove(reminderId);
  }

  void reset() {
    dailyCompletions.clear();
    weeklyCompletions.clear();
    totalCompletions.clear();
    lastReset = DateTime.now();
  }

  void resetDailyStats() {
    final today = _getDateKey(DateTime.now());
    final lastUpdateDay = _getDateKey(lastUpdate);

    if (today != lastUpdateDay) {
      dailyCompletions.clear();
    }
  }

  void resetWeeklyStats() {
    final currentWeek = _getWeekKey(DateTime.now());
    final lastUpdateWeek = _getWeekKey(lastUpdate);

    if (currentWeek != lastUpdateWeek) {
      weeklyCompletions.clear();
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getWeekKey(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    final weekNumber = (daysSinceStart / 7).ceil();
    return '${date.year}-W$weekNumber';
  }

  int getDailyTotal(String reminderId) => dailyCompletions[reminderId] ?? 0;
  int getWeeklyTotal(String reminderId) => weeklyCompletions[reminderId] ?? 0;
  int getOverallTotal(String reminderId) => totalCompletions[reminderId] ?? 0;
}
