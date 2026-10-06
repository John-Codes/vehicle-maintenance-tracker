class CheckStep {
  final String id;
  final String title;
  final String value;
  final String notes;
  final String description;
  final bool done;
  final bool notApplicable;
  const CheckStep({required this.id, required this.title, this.value = '', this.notes = '', this.description = '', this.done = false, this.notApplicable = false});
  CheckStep copyWith({String? title, String? value, String? notes, String? description, bool? done, bool? notApplicable}) => CheckStep(
      id: id,
      title: title ?? this.title,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      done: done ?? this.done,
      notApplicable: notApplicable ?? this.notApplicable);
  factory CheckStep.fromJson(Map j) => CheckStep(
      id: j['id'],
      title: j['title'],
      value: j['value'] ?? '',
      notes: j['notes'] ?? '',
      description: j['description'] ?? '',
      done: j['done'] ?? false,
      notApplicable: j['not_applicable'] ?? false);
  Map toJson() => {'id': id, 'title': title, 'value': value, 'notes': notes, 'description': description, 'done': done, 'not_applicable': notApplicable};
}
