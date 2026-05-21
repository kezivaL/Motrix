class RuleGejala {
  final String gejalaId;
  final double bobotPakar;

  RuleGejala({
    required this.gejalaId,
    required this.bobotPakar,
  });

  Map<String, dynamic> toJson() {
    return {
      'gejalaId': gejalaId,
      'bobotPakar': bobotPakar,
    };
  }

  factory RuleGejala.fromJson(Map<String, dynamic> json) {
    return RuleGejala(
      gejalaId: json['gejalaId'] ?? json['gejala_id'] ?? '',
      bobotPakar: (json['bobotPakar'] ?? json['bobot_pakar'] ?? 0.8).toDouble(),
    );
  }
}

class Rule {
  final String kerusakanId;
  final List<RuleGejala> gejalaRules;

  Rule({
    required this.kerusakanId,
    List<RuleGejala>? gejalaRules,
    List<String>? gejalaIds,
  }) : gejalaRules = gejalaRules ??
            gejalaIds
                ?.map(
                  (id) => RuleGejala(
                    gejalaId: id,
                    bobotPakar: 0.8,
                  ),
                )
                .toList() ??
            [];

  List<String> get gejalaIds {
    return gejalaRules.map((e) => e.gejalaId).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'kerusakanId': kerusakanId,
      'gejalaRules': gejalaRules.map((e) => e.toJson()).toList(),
    };
  }

  factory Rule.fromJson(Map<String, dynamic> json) {
    if (json['gejalaRules'] != null) {
      return Rule(
        kerusakanId: json['kerusakanId'] ?? json['kerusakan_id'] ?? '',
        gejalaRules: (json['gejalaRules'] as List<dynamic>? ?? [])
            .map(
              (e) => RuleGejala.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList(),
      );
    }

    if (json['gejala_rules'] != null) {
      return Rule(
        kerusakanId: json['kerusakanId'] ?? json['kerusakan_id'] ?? '',
        gejalaRules: (json['gejala_rules'] as List<dynamic>? ?? [])
            .map(
              (e) => RuleGejala.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList(),
      );
    }

    return Rule(
      kerusakanId: json['kerusakanId'] ?? json['kerusakan_id'] ?? '',
      gejalaIds: List<String>.from(json['gejalaIds'] ?? json['gejala_ids'] ?? []),
    );
  }
}