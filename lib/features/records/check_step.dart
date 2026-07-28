class CheckStep {
  final String id, title, value, notes;
  final bool done;
  const CheckStep({required this.id, required this.title, this.done = false, this.value = '', this.notes = ''});
  CheckStep copyWith({String? title, bool? done, String? value, String? notes}) => CheckStep(
    id: id, title: title ?? this.title, done: done ?? this.done, value: value ?? this.value, notes: notes ?? this.notes);
  factory CheckStep.fromJson(Map<String, dynamic> j) => CheckStep(id: j['id'], title: j['title'], done: j['done'] ?? false, value: j['value'] ?? '', notes: j['notes'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done, 'value': value, 'notes': notes};
}
