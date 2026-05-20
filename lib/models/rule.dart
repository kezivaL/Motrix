class Rule {
  final String kerusakanId;
  final List<String> gejalaIds;

  Rule({
    required this.kerusakanId,
    required this.gejalaIds,
  });
  Map<String, dynamic> toJson() {
  return {
    'kerusakanId': kerusakanId,
    'gejalaIds': gejalaIds,
  };
}

factory Rule.fromJson(Map<String, dynamic> json) {
  return Rule(
    kerusakanId: json['kerusakanId'],
    gejalaIds: List<String>.from(json['gejalaIds']),
  );
}
}