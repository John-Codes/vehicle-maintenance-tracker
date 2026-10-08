/// Due rules per frequency: daily = not done today, weekly = not done this
/// ISO week, monthly = not done this calendar month, never done = always due.
bool isFrequencyDue({required String frequencyId, required String lastDoneAt, DateTime? now}) {
  if (lastDoneAt.isEmpty) return true;
  final done = DateTime.tryParse(lastDoneAt);
  if (done == null) return true;
  final ref = now ?? DateTime.now();
  switch (frequencyId) {
    case 'daily':
      return done.year != ref.year || done.month != ref.month || done.day != ref.day;
    case 'weekly':
      final a = _isoWeek(done), b = _isoWeek(ref);
      return a.year != b.year || a.week != b.week;
    case 'monthly':
      return done.year != ref.year || done.month != ref.month;
    default:
      return true;
  }
}

({int year, int week}) _isoWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final week = thursday.difference(DateTime(thursday.year, 1, 1)).inDays ~/ 7 + 1;
  return (year: thursday.year, week: week);
}
