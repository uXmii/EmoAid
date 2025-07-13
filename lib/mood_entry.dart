class MoodEntry {
  final int mood;
  final String? notes;
  final String? aiInsight;
  final DateTime timestamp;
  final String moodLabel;
  final Map<String, double> emotionScores;
  final List<String> detectedKeywords;
  final double sentimentScore;
  final String aiPredictedTrigger;

  MoodEntry({
    required this.mood,
    this.notes,
    this.aiInsight,
    required this.timestamp,
    required this.moodLabel,
    required this.emotionScores,
    required this.detectedKeywords,
    required this.sentimentScore,
    required this.aiPredictedTrigger,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'notes': notes,
    'aiInsight': aiInsight,
    'timestamp': timestamp.toIso8601String(),
    'moodLabel': moodLabel,
    'emotionScores': emotionScores,
    'detectedKeywords': detectedKeywords,
    'sentimentScore': sentimentScore,
    'aiPredictedTrigger': aiPredictedTrigger,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    mood: json['mood'],
    notes: json['notes'],
    aiInsight: json['aiInsight'],
    timestamp: DateTime.parse(json['timestamp']),
    moodLabel: json['moodLabel'],
    emotionScores: Map<String, double>.from(json['emotionScores'] ?? {}),
    detectedKeywords: List<String>.from(json['detectedKeywords'] ?? []),
    sentimentScore: json['sentimentScore']?.toDouble() ?? 0.0,
    aiPredictedTrigger: json['aiPredictedTrigger'] ?? '',
  );
}