class Statistics {
  final Map<String, int> dailyCompletions;
  final Map<String, int> weeklyCompletions;
  final Map<String, int> totalCompletions;
  final Map<String, int> monthlyCompletions; // Added missing field
  final DateTime lastUpdate;
  DateTime? lastReset;

  Statistics({
    Map<String, int>? dailyCompletions,
    Map<String, int>? weeklyCompletions,
    Map<String, int>? totalCompletions,
    Map<String, int>? monthlyCompletions, // Added parameter
    DateTime? lastUpdate,
    this.lastReset,
  }) : dailyCompletions = dailyCompletions ?? {},
       weeklyCompletions = weeklyCompletions ?? {},
       totalCompletions = totalCompletions ?? {},
       monthlyCompletions = monthlyCompletions ?? {}, // Initialize
       lastUpdate = lastUpdate ?? DateTime.now();

  Statistics copyWith({
    Map<String, int>? dailyCompletions,
    Map<String, int>? weeklyCompletions,
    Map<String, int>? totalCompletions,
    Map<String, int>? monthlyCompletions, // Added parameter
    DateTime? lastUpdate,
  }) {
    return Statistics(
      dailyCompletions: dailyCompletions ?? this.dailyCompletions,
      weeklyCompletions: weeklyCompletions ?? this.weeklyCompletions,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      monthlyCompletions: monthlyCompletions ?? this.monthlyCompletions, // Added
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyCompletions': dailyCompletions,
    'weeklyCompletions': weeklyCompletions,
    'totalCompletions': totalCompletions,
    'monthlyCompletions': monthlyCompletions, // Added
    'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    'lastReset': lastReset?.millisecondsSinceEpoch,
  };

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
      weeklyCompletions: Map<String, int>.from(json['weeklyCompletions'] ?? {}),
      totalCompletions: Map<String, int>.from(json['totalCompletions'] ?? {}),
      monthlyCompletions: Map<String, int>.from(json['monthlyCompletions'] ?? {}), // Added
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
    monthlyCompletions[reminderId] = (monthlyCompletions[reminderId] ?? 0) + count; // Added
  }

  // Added missing methods
  void addCompletion(String reminderId, DateTime timestamp) {
    incrementCount(reminderId, 1);
  }

  void incrementCompletion(String reminderId) {
    incrementCount(reminderId, 1);
  }

  void incrementDailyCompletion(String reminderId) {
    dailyCompletions[reminderId] = (dailyCompletions[reminderId] ?? 0) + 1;
  }

  void incrementWeeklyCompletion(String reminderId) {
    weeklyCompletions[reminderId] = (weeklyCompletions[reminderId] ?? 0) + 1;
  }

  void incrementMonthlyCompletion(String reminderId) {
    monthlyCompletions[reminderId] = (monthlyCompletions[reminderId] ?? 0) + 1;
  }

  int getTotalCompletions() {
    return totalCompletions.values.fold(0, (sum, count) => sum + count);
  }

  int getDailyTotal(DateTime date) {
    return dailyCompletions.values.fold(0, (sum, count) => sum + count);
  }

  int getCompletionCount(String reminderId) {
    return totalCompletions[reminderId] ?? 0;
  }

  int getDailyCompletionCount(String reminderId) {
    return dailyCompletions[reminderId] ?? 0;
  }

  double getCompletionRate(String reminderId) {
    final total = totalCompletions[reminderId] ?? 0;
    final target = 10; // Default target, should be configurable
    return target > 0 ? total / target : 0.0;
  }

  int getCurrentStreak() {
    // Simple implementation, can be enhanced
    return 0; // Placeholder
  }

  int getLongestStreak() {
    // Simple implementation, can be enhanced
    return 0; // Placeholder
  }

  void resetDailyCompletions() {
    dailyCompletions.clear();
  }

  void resetWeeklyCompletions() {
    weeklyCompletions.clear();
  }

  void resetMonthlyCompletions() {
    monthlyCompletions.clear();
  }

  void resetAll() {
    reset();
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

  int getDailyTotalForReminder(String reminderId) => dailyCompletions[reminderId] ?? 0;
  int getWeeklyTotal(String reminderId) => weeklyCompletions[reminderId] ?? 0;
  int getOverallTotal(String reminderId) => totalCompletions[reminderId] ?? 0;
}
