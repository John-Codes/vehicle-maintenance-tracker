class DoneEvent {
  final String at;
  final double? lat, lng, accuracy;
  const DoneEvent({required this.at, this.lat, this.lng, this.accuracy});
  factory DoneEvent.fromJson(Map j) => DoneEvent(
        at: '${j['at'] ?? ''}',
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        accuracy: (j['accuracy'] as num?)?.toDouble(),
      );
  Map<String, dynamic> toJson() => {'at': at, 'lat': lat, 'lng': lng, 'accuracy': accuracy};
}
