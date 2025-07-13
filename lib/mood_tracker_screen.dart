// lib/mood_tracker_screen.dart - MOBILE LAYOUT OPTIMIZED (Part 1)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'ai_service.dart';
import 'analytics_screen.dart';
import 'mood_entry.dart';
import 'mood_data_service.dart';
// REMOVED: import 'theme/app_theme.dart'; // Will use built-in colors for mobile

// Keep all your existing ML classes (MoodPredictionModel, etc.) exactly the same
class MoodPredictionModel {
  static MoodPrediction predictNextMoodAdvanced(List<MoodEntry> history) {
    if (history.length < 3) {
      return MoodPrediction(
        prediction: 3.0,
        confidence: 0.3,
        confidenceInterval: [2.5, 3.5],
        methodology: 'Insufficient data - using baseline',
        uncertaintyFactors: ['Limited historical data'],
      );
    }
    
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    final predictions = <double>[];
    
    for (int i = 0; i < min(7, history.length); i++) {
      double weight = pow(0.8, i).toDouble();
      weightedSum += history[i].mood * weight;
      totalWeight += weight;
    }
    double emaPredict = weightedSum / totalWeight;
    predictions.add(emaPredict);
    
    if (history.length >= 5) {
      double trendSum = 0.0;
      for (int i = 0; i < min(5, history.length - 1); i++) {
        trendSum += (history[i].mood - history[i + 1].mood);
      }
      double avgTrend = trendSum / min(5, history.length - 1);
      double trendPredict = history[0].mood + avgTrend;
      predictions.add(trendPredict.clamp(1.0, 5.0));
    }
    
    if (history.length >= 7) {
      final dayOfWeek = DateTime.now().weekday;
      final sameDayMoods = <double>[];
      
      for (int i = 0; i < history.length; i++) {
        if (history[i].timestamp.weekday == dayOfWeek) {
          sameDayMoods.add(history[i].mood.toDouble());
        }
        if (sameDayMoods.length >= 3) break;
      }
      
      if (sameDayMoods.isNotEmpty) {
        double seasonalPredict = sameDayMoods.reduce((a, b) => a + b) / sameDayMoods.length;
        predictions.add(seasonalPredict);
      }
    }
    
    final recoveryPredict = _analyzeRecoveryPattern(history);
    if (recoveryPredict != null) {
      predictions.add(recoveryPredict);
    }
    
    double finalPrediction = predictions.reduce((a, b) => a + b) / predictions.length;
    
    double variance = 0.0;
    for (double pred in predictions) {
      variance += pow(pred - finalPrediction, 2);
    }
    variance /= predictions.length;
    double stdDev = sqrt(variance);
    
    double confidence = 1.0 - (stdDev / 2.0);
    confidence *= (min(history.length, 10) / 10.0);
    confidence = confidence.clamp(0.2, 0.95);
    
    double margin = stdDev * 1.96;
    List<double> confidenceInterval = [
      (finalPrediction - margin).clamp(1.0, 5.0),
      (finalPrediction + margin).clamp(1.0, 5.0),
    ];
    
    List<String> uncertaintyFactors = [];
    if (history.length < 10) uncertaintyFactors.add('Limited historical data');
    if (stdDev > 1.0) uncertaintyFactors.add('High prediction variance');
    if (_hasRecentAnomalies(history)) uncertaintyFactors.add('Recent mood anomalies detected');
    if (_hasInconsistentPatterns(history)) uncertaintyFactors.add('Inconsistent mood patterns');
    
    String methodology = 'Ensemble: ${predictions.length} methods (EMA';
    if (predictions.length > 1) methodology += ', Trend';
    if (predictions.length > 2) methodology += ', Seasonal';
    if (predictions.length > 3) methodology += ', Recovery';
    methodology += ')';
    
    return MoodPrediction(
      prediction: finalPrediction.clamp(1.0, 5.0),
      confidence: confidence,
      confidenceInterval: confidenceInterval,
      methodology: methodology,
      uncertaintyFactors: uncertaintyFactors,
    );
  }

  static double? _analyzeRecoveryPattern(List<MoodEntry> history) {
    if (history.length < 5) return null;
    
    for (int i = 0; i < min(3, history.length - 2); i++) {
      if (history[i].mood <= 2) {
        for (int j = i + 1; j < history.length - 1; j++) {
          if (history[j].mood <= 2 && j < history.length - 1) {
            double recoveryIncrease = history[j - 1].mood.toDouble() - history[j].mood.toDouble();
            if (recoveryIncrease > 0) {
              return (history[i].mood.toDouble() + recoveryIncrease).clamp(1.0, 5.0);
            }
          }
        }
      }
    }
    return null;
  }

  static bool _hasRecentAnomalies(List<MoodEntry> history) {
    if (history.length < 5) return false;
    
    List<double> recentMoods = history.take(3).map((e) => e.mood.toDouble()).toList();
    List<double> olderMoods = history.skip(3).take(5).map((e) => e.mood.toDouble()).toList();
    
    if (olderMoods.isEmpty) return false;
    
    double recentAvg = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
    double olderAvg = olderMoods.reduce((a, b) => a + b) / olderMoods.length;
    
    return (recentAvg - olderAvg).abs() > 1.5;
  }

  static bool _hasInconsistentPatterns(List<MoodEntry> history) {
    if (history.length < 6) return false;
    
    List<double> moods = history.take(6).map((e) => e.mood.toDouble()).toList();
    double variance = 0.0;
    double mean = moods.reduce((a, b) => a + b) / moods.length;
    
    for (double mood in moods) {
      variance += pow(mood - mean, 2);
    }
    variance /= moods.length;
    
    return sqrt(variance) > 1.2;
  }

  static AnomalyDetection detectAnomalousPatternAdvanced(List<MoodEntry> history) {
    if (history.length < 5) {
      return AnomalyDetection(
        hasAnomaly: false,
        severity: AnomalySeverity.none,
        anomalyType: 'Insufficient data',
        confidence: 0.0,
        recommendedAction: 'Continue tracking mood patterns',
      );
    }
    
    List<double> moods = history.take(5).map((e) => e.mood.toDouble()).toList();
    double mean = moods.reduce((a, b) => a + b) / moods.length;
    double variance = moods.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / moods.length;
    double stdDev = sqrt(variance);
    
    List<String> detectedAnomalies = [];
    double maxAnomalyScore = 0.0;
    
    for (double mood in moods.take(2)) {
      double zScore = (mood - mean).abs() / (stdDev + 0.1);
      if (zScore > 2.0) {
        detectedAnomalies.add('Statistical outlier');
        maxAnomalyScore = max(maxAnomalyScore, zScore / 3.0);
      }
    }
    
    if (history.length >= 3) {
      double recentAvg = history.take(2).map((e) => e.mood.toDouble()).reduce((a, b) => a + b) / 2;
      double olderAvg = history.skip(2).take(3).map((e) => e.mood.toDouble()).reduce((a, b) => a + b) / 3;
      double drop = olderAvg - recentAvg;
      
      if (drop > 2.0) {
        detectedAnomalies.add('Sudden mood drop');
        maxAnomalyScore = max(maxAnomalyScore, drop / 4.0);
      }
    }
    
    List<double> recentMoods = history.take(3).map((e) => e.mood.toDouble()).toList();
    if (recentMoods.every((mood) => mood <= 2)) {
      detectedAnomalies.add('Persistent low mood');
      maxAnomalyScore = max(maxAnomalyScore, 0.8);
    }
    
    if (stdDev > 1.5) {
      detectedAnomalies.add('High mood volatility');
      maxAnomalyScore = max(maxAnomalyScore, stdDev / 2.0);
    }
    
    AnomalySeverity severity;
    String recommendedAction;
    
    if (maxAnomalyScore < 0.3) {
      severity = AnomalySeverity.none;
      recommendedAction = 'Continue regular mood tracking';
    } else if (maxAnomalyScore < 0.6) {
      severity = AnomalySeverity.mild;
      recommendedAction = 'Consider self-care activities and stress management';
    } else if (maxAnomalyScore < 0.8) {
      severity = AnomalySeverity.moderate;
      recommendedAction = 'Focus on wellness tools and consider talking to someone';
    } else {
      severity = AnomalySeverity.severe;
      recommendedAction = 'Consider reaching out for professional support';
    }
    
    return AnomalyDetection(
      hasAnomaly: detectedAnomalies.isNotEmpty,
      severity: severity,
      anomalyType: detectedAnomalies.join(', '),
      confidence: maxAnomalyScore.clamp(0.0, 1.0),
      recommendedAction: recommendedAction,
    );
  }

  static bool detectAnomalousPattern(List<MoodEntry> history) {
    final advanced = detectAnomalousPatternAdvanced(history);
    return advanced.hasAnomaly;
  }
}

class MoodPrediction {
  final double prediction;
  final double confidence;
  final List<double> confidenceInterval;
  final String methodology;
  final List<String> uncertaintyFactors;

  MoodPrediction({
    required this.prediction,
    required this.confidence,
    required this.confidenceInterval,
    required this.methodology,
    required this.uncertaintyFactors,
  });
}

enum AnomalySeverity { none, mild, moderate, severe }

class AnomalyDetection {
  final bool hasAnomaly;
  final AnomalySeverity severity;
  final String anomalyType;
  final double confidence;
  final String recommendedAction;

  AnomalyDetection({
    required this.hasAnomaly,
    required this.severity,
    required this.anomalyType,
    required this.confidence,
    required this.recommendedAction,
  });
}

// Keep all your EmotionAnalyzer class exactly the same
class EmotionAnalyzer {
  static Map<String, double> analyzeEmotions(String? text) {
    if (text == null || text.isEmpty) {
      return {
        'joy': 0.0,
        'sadness': 0.0,
        'anger': 0.0,
        'fear': 0.0,
        'surprise': 0.0,
        'disgust': 0.0
      };
    }
    
    Map<String, List<String>> emotionKeywords = {
      'joy': ['happy', 'excited', 'great', 'amazing', 'wonderful', 'fantastic', 'good', 'smile', 'laugh'],
      'sadness': ['sad', 'depressed', 'down', 'cry', 'tears', 'lonely', 'hopeless', 'empty'],
      'anger': ['angry', 'mad', 'furious', 'irritated', 'frustrated', 'annoyed', 'rage'],
      'fear': ['scared', 'afraid', 'anxious', 'worried', 'nervous', 'panic', 'terrified'],
      'surprise': ['surprised', 'shocked', 'amazed', 'astonished', 'unexpected'],
      'disgust': ['disgusted', 'sick', 'revolted', 'appalled', 'repulsed']
    };
    
    Map<String, double> scores = {};
    String lowerText = text.toLowerCase();
    
    emotionKeywords.forEach((emotion, keywords) {
      double score = 0.0;
      for (String keyword in keywords) {
        if (lowerText.contains(keyword)) {
          score += 1.0;
        }
      }
      scores[emotion] = score / keywords.length;
    });
    
    return scores;
  }
  
  static List<String> extractKeywords(String? text) {
    if (text == null || text.isEmpty) return [];
    
    List<String> stopWords = ['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might', 'must', 'can', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them', 'my', 'your', 'his', 'her', 'its', 'our', 'their'];
    
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .take(5)
        .toList();
  }
  
  static double calculateSentiment(String? text) {
    if (text == null || text.isEmpty) return 0.0;
    
    Map<String, double> positiveWords = {
      'good': 1.0, 'great': 2.0, 'excellent': 2.0, 'amazing': 2.0, 'wonderful': 2.0,
      'happy': 1.5, 'joy': 1.5, 'love': 1.5, 'like': 0.5, 'enjoy': 1.0, 'excited': 1.5
    };
    
    Map<String, double> negativeWords = {
      'bad': -1.0, 'terrible': -2.0, 'awful': -2.0, 'hate': -2.0, 'sad': -1.5,
      'angry': -1.5, 'frustrated': -1.0, 'annoyed': -1.0, 'worried': -1.0, 'anxious': -1.5
    };
    
    double score = 0.0;
    String lowerText = text.toLowerCase();
    
    positiveWords.forEach((word, value) {
      if (lowerText.contains(word)) score += value;
    });
    
    negativeWords.forEach((word, value) {
      if (lowerText.contains(word)) score += value;
    });
    
    return score.clamp(-5.0, 5.0);
  }
}

// MOBILE OPTIMIZED: Mood Tracker Screen
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int? selectedMood;
  String? additionalNotes;
  bool isAnalyzing = false;
  String? aiInsight;
  Map<String, double> currentEmotionScores = {};
  double currentSentiment = 0.0;
  List<String> currentKeywords = [];
  
  MoodPrediction? advancedPrediction;
  AnomalyDetection? anomalyDetection;
  
  final TextEditingController _notesController = TextEditingController();
  final AIService _aiService = AIService();
  
  // MOBILE OPTIMIZED: Mobile-friendly colors
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'label': 'Great', 'color': const Color(0xFF4CAF50), 'value': 5},
    {'emoji': '🙂', 'label': 'Good', 'color': const Color(0xFF8BC34A), 'value': 4},
    {'emoji': '😐', 'label': 'Okay', 'color': const Color(0xFFFF9800), 'value': 3},
    {'emoji': '😔', 'label': 'Low', 'color': const Color(0xFFFF5722), 'value': 2},
    {'emoji': '😢', 'label': 'Bad', 'color': const Color(0xFFF44336), 'value': 1},
  ];

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_onNotesChanged);
    _initializeData();
  }

  Future<void> _initializeData() async {
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    await moodService.initialize();
    _updatePredictions();
  }

  void _updatePredictions() {
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    if (moodService.hasData) {
      setState(() {
        advancedPrediction = MoodPredictionModel.predictNextMoodAdvanced(moodService.moodHistory);
        anomalyDetection = MoodPredictionModel.detectAnomalousPatternAdvanced(moodService.moodHistory);
      });
    }
  }

  void _onNotesChanged() {
    setState(() {
      additionalNotes = _notesController.text;
      currentEmotionScores = EmotionAnalyzer.analyzeEmotions(_notesController.text);
      currentSentiment = EmotionAnalyzer.calculateSentiment(_notesController.text);
      currentKeywords = EmotionAnalyzer.extractKeywords(_notesController.text);
    });
  }
  // CONTINUATION OF MOBILE MOOD TRACKER PART 2

  void _saveMoodWithMLFeatures() async {
    if (selectedMood == null) return;
    
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    
    final newEntry = MoodEntry(
      mood: moods[selectedMood!]['value'],
      notes: additionalNotes?.isNotEmpty == true ? additionalNotes : null,
      aiInsight: aiInsight,
      timestamp: DateTime.now(),
      moodLabel: moods[selectedMood!]['label'],
      emotionScores: currentEmotionScores,
      detectedKeywords: currentKeywords,
      sentimentScore: currentSentiment,
      aiPredictedTrigger: _predictMoodTrigger(),
    );
    
    try {
      await moodService.addMoodEntry(newEntry);
      _updatePredictions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood saved with advanced AI analysis! 🤖',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Data synced to Analytics. Total entries: ${moodService.moodHistory.length}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: moods[selectedMood!]['color'],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Reset form
        setState(() {
          selectedMood = null;
          additionalNotes = null;
          aiInsight = null;
          currentEmotionScores = {};
          currentSentiment = 0.0;
          currentKeywords = [];
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // MOBILE LAYOUT: Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenHeight < 700; // Detect smaller screens
    
    return Consumer<MoodDataService>(
      builder: (context, moodService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'AI Mood Intelligence',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 18 : 20, // MOBILE: Responsive font
              ),
            ),
            backgroundColor: const Color(0xFF00BCD4),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (moodService.hasData)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyticsScreen(moodHistory: moodService.moodHistory),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6), // MOBILE: Smaller padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.analytics, color: Colors.white, size: 20), // MOBILE: Smaller icon
                        if (moodService.moodHistory.length >= 3)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00BCD4),
                  Color(0xFFF8FCFF),
                ],
              ),
            ),
            child: Column(
              children: [
                // MOBILE OPTIMIZED: Compact header
                Padding(
                  padding: EdgeInsets.fromLTRB(16, isCompact ? 8 : 16, 16, isCompact ? 16 : 24), // MOBILE: Responsive padding
                  child: Column(
                    children: [
                      Text(
                        'Advanced AI Mood Analysis',
                        style: TextStyle(
                          fontSize: isCompact ? 20 : 24, // MOBILE: Responsive font
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isCompact ? 6 : 12), // MOBILE: Responsive spacing
                      Text(
                        'Machine Learning algorithms with confidence intervals and anomaly detection',
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 15, // MOBILE: Responsive font
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Real data indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // MOBILE: Smaller padding
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${moodService.moodHistory.length} entries • Live analytics',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11, // MOBILE: Smaller font
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // MOBILE OPTIMIZED: Compact prediction display
                      if (moodService.hasData && advancedPrediction != null) ...[
                        SizedBox(height: isCompact ? 10 : 16), // MOBILE: Responsive spacing
                        Container(
                          padding: EdgeInsets.all(isCompact ? 12 : 16), // MOBILE: Responsive padding
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              // MOBILE: Single row layout for predictions
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPredictionItem(
                                      'AI Prediction',
                                      '${advancedPrediction!.prediction.toStringAsFixed(1)}/5',
                                      '${(advancedPrediction!.confidence * 100).round()}% confident',
                                      isCompact,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: isCompact ? 30 : 35, // MOBILE: Responsive height
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  Expanded(
                                    child: _buildPredictionItem(
                                      'Range',
                                      '${advancedPrediction!.confidenceInterval[0].toStringAsFixed(1)}-${advancedPrediction!.confidenceInterval[1].toStringAsFixed(1)}',
                                      '95% interval',
                                      isCompact,
                                    ),
                                  ),
                                  if (anomalyDetection != null && anomalyDetection!.hasAnomaly) ...[
                                    Container(
                                      width: 1,
                                      height: isCompact ? 30 : 35, // MOBILE: Responsive height
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    Expanded(
                                      child: _buildAnomalyItem(anomalyDetection!, isCompact),
                                    ),
                                  ],
                                ],
                              ),
                              
                              SizedBox(height: isCompact ? 6 : 8), // MOBILE: Responsive spacing
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // MOBILE: Smaller padding
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  advancedPrediction!.methodology,
                                  style: TextStyle(
                                    fontSize: isCompact ? 8 : 9, // MOBILE: Smaller font
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // MOBILE OPTIMIZED: Scrollable content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FCFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24), // MOBILE: Smaller radius
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, isCompact ? 20 : 28, 16, 24), // MOBILE: Responsive padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MOBILE OPTIMIZED: Compact anomaly warning
                          if (anomalyDetection != null && anomalyDetection!.hasAnomaly) ...[
                            Container(
                              padding: EdgeInsets.all(isCompact ? 12 : 16), // MOBILE: Responsive padding
                              decoration: BoxDecoration(
                                color: _getAnomalyColor(anomalyDetection!.severity).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getAnomalyColor(anomalyDetection!.severity).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getAnomalyIcon(anomalyDetection!.severity),
                                        color: _getAnomalyColor(anomalyDetection!.severity),
                                        size: isCompact ? 16 : 18, // MOBILE: Responsive icon
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Pattern Alert: ${anomalyDetection!.severity.name.toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: isCompact ? 13 : 15, // MOBILE: Responsive font
                                            fontWeight: FontWeight.bold,
                                            color: _getAnomalyColor(anomalyDetection!.severity),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isCompact ? 6 : 8), // MOBILE: Responsive spacing
                                  Text(
                                    'Detected: ${anomalyDetection!.anomalyType}',
                                    style: TextStyle(
                                      fontSize: isCompact ? 12 : 13, // MOBILE: Responsive font
                                      color: const Color(0xFF1A365D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 4 : 6), // MOBILE: Responsive spacing
                                  Text(
                                    'Recommendation: ${anomalyDetection!.recommendedAction}',
                                    style: TextStyle(
                                      fontSize: isCompact ? 11 : 12, // MOBILE: Responsive font
                                      color: const Color(0xFF4A5568),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isCompact ? 16 : 24), // MOBILE: Responsive spacing
                          ],
                          
                          // MOBILE OPTIMIZED: Mood Selection Header
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Select your mood:',
                                  style: TextStyle(
                                    fontSize: isCompact ? 17 : 19, // MOBILE: Responsive font
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A365D),
                                  ),
                                ),
                              ),
                              if (advancedPrediction != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // MOBILE: Smaller padding
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        size: 12, // MOBILE: Smaller icon
                                        color: Color(0xFF00BCD4),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'AI: ${advancedPrediction!.prediction.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          fontSize: 10, // MOBILE: Smaller font
                                          color: Color(0xFF00BCD4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 14 : 18), // MOBILE: Responsive spacing
                          
                          // MOBILE OPTIMIZED: Mood Grid - Single row layout
                          Container(
                            padding: EdgeInsets.all(isCompact ? 14 : 18), // MOBILE: Responsive padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BCD4).withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(moods.length, (index) {
                                final mood = moods[index];
                                final isSelected = selectedMood == index;
                                
                                bool isPredicted = false;
                                if (advancedPrediction != null) {
                                  final predictedValue = advancedPrediction!.prediction.round();
                                  isPredicted = mood['value'] == predictedValue;
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMood = index;
                                      aiInsight = null;
                                    });
                                  },
                                  child: Container(
                                    width: screenWidth * 0.15, // MOBILE: Responsive width
                                    height: isCompact ? 65 : 75, // MOBILE: Responsive height
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected ? mood['color'] : const Color(0xFFF0FDFF),
                                      border: Border.all(
                                        color: isPredicted 
                                            ? const Color(0xFFFF9800)
                                            : isSelected 
                                                ? mood['color'] 
                                                : const Color(0xFF00BCD4).withOpacity(0.2),
                                        width: isPredicted ? 2 : isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: mood['color'].withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ] : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          mood['emoji'],
                                          style: TextStyle(fontSize: isCompact ? 20 : 24), // MOBILE: Responsive emoji
                                        ),
                                        SizedBox(height: isCompact ? 3 : 5), // MOBILE: Responsive spacing
                                        Text(
                                          mood['label'],
                                          style: TextStyle(
                                            fontSize: isCompact ? 9 : 10, // MOBILE: Smaller font
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF00BCD4),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          
                          if (selectedMood != null) ...[
                            SizedBox(height: isCompact ? 20 : 28), // MOBILE: Responsive spacing
                            
                            // MOBILE OPTIMIZED: Notes section
                            Text(
                              'Describe your feelings (AI will analyze):',
                              style: TextStyle(
                                fontSize: isCompact ? 15 : 17, // MOBILE: Responsive font
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A365D),
                              ),
                            ),
                            SizedBox(height: isCompact ? 10 : 14), // MOBILE: Responsive spacing
                            
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00BCD4).withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  hintText: 'What\'s contributing to this mood? AI will analyze emotions and keywords...',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: isCompact ? 12 : 13, // MOBILE: Responsive font
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: moods[selectedMood!]['color'], width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(isCompact ? 14 : 18), // MOBILE: Responsive padding
                                ),
                                maxLines: isCompact ? 3 : 4, // MOBILE: Responsive lines
                                style: TextStyle(fontSize: isCompact ? 13 : 14), // MOBILE: Responsive font
                              ),
                            ),
                            
                            // MOBILE OPTIMIZED: Real-time NLP Analysis
                            if (additionalNotes?.isNotEmpty == true) ...[
                              SizedBox(height: isCompact ? 14 : 18), // MOBILE: Responsive spacing
                              Container(
                                padding: EdgeInsets.all(isCompact ? 14 : 18), // MOBILE: Responsive padding
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF0FDFF), Color(0xFFE0F7FA)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF00BCD4).withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF00BCD4),
                                          size: 14, // MOBILE: Smaller icon
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Real-time NLP Analysis',
                                          style: TextStyle(
                                            fontSize: isCompact ? 12 : 13, // MOBILE: Responsive font
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF00BCD4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isCompact ? 8 : 10), // MOBILE: Responsive spacing
                                    
                                    // MOBILE: Compact sentiment and emotions
                                    _buildAnalysisRow('Sentiment', '${currentSentiment.toStringAsFixed(1)} (${currentSentiment >= 0 ? "Positive" : "Negative"})', currentSentiment >= 0, isCompact),
                                    
                                    if (currentEmotionScores.isNotEmpty) ...[
                                      SizedBox(height: isCompact ? 6 : 8),
                                      _buildEmotionsDisplay(isCompact),
                                    ],
                                    
                                    if (currentKeywords.isNotEmpty) ...[
                                      SizedBox(height: isCompact ? 6 : 8),
                                      _buildKeywordsDisplay(isCompact),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            
                            SizedBox(height: isCompact ? 20 : 28), // MOBILE: Responsive spacing
                            
                            // MOBILE OPTIMIZED: AI Analysis Button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: isAnalyzing ? null : _getAdvancedAIAnalysis,
                                  icon: isAnalyzing 
                                    ? SizedBox(
                                        width: isCompact ? 16 : 18, // MOBILE: Responsive size
                                        height: isCompact ? 16 : 18,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.psychology, size: isCompact ? 18 : 20), // MOBILE: Responsive icon
                                  label: Text(
                                    isAnalyzing ? 'AI Processing...' : 'Advanced AI Analysis',
                                    style: TextStyle(
                                      fontSize: isCompact ? 14 : 15, // MOBILE: Responsive font
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: moods[selectedMood!]['color'],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 24 : 28, // MOBILE: Responsive padding
                                      vertical: isCompact ? 12 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            
                            // MOBILE OPTIMIZED: AI Insights Display
                            if (aiInsight != null) ...[
                              SizedBox(height: isCompact ? 20 : 28), // MOBILE: Responsive spacing
                              Container(
                                padding: EdgeInsets.all(isCompact ? 16 : 20), // MOBILE: Responsive padding
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      moods[selectedMood!]['color'].withOpacity(0.08),
                                      moods[selectedMood!]['color'].withOpacity(0.03),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: moods[selectedMood!]['color'].withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6), // MOBILE: Smaller padding
                                          decoration: BoxDecoration(
                                            color: moods[selectedMood!]['color'].withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: moods[selectedMood!]['color'],
                                            size: isCompact ? 16 : 18, // MOBILE: Responsive icon
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Advanced AI Insights',
                                                style: TextStyle(
                                                  fontSize: isCompact ? 15 : 17, // MOBILE: Responsive font
                                                  fontWeight: FontWeight.bold,
                                                  color: moods[selectedMood!]['color'],
                                                ),
                                              ),
                                              Text(
                                                'ML Pattern Analysis • NLP Processing',
                                                style: TextStyle(
                                                  fontSize: isCompact ? 9 : 10, // MOBILE: Smaller font
                                                  color: moods[selectedMood!]['color'].withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isCompact ? 12 : 14), // MOBILE: Responsive spacing
                                    Text(
                                      aiInsight!,
                                      style: TextStyle(
                                        fontSize: isCompact ? 13 : 14, // MOBILE: Responsive font
                                        color: const Color(0xFF1A365D),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            SizedBox(height: isCompact ? 20 : 28), // MOBILE: Responsive spacing
                            
                            // MOBILE OPTIMIZED: Save Button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _saveMoodWithMLFeatures,
                                  icon: Icon(Icons.save_alt, size: isCompact ? 18 : 20), // MOBILE: Responsive icon
                                  label: Text(
                                    'Save with AI Analysis',
                                    style: TextStyle(
                                      fontSize: isCompact ? 14 : 15, // MOBILE: Responsive font
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: moods[selectedMood!]['color'],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 28 : 32, // MOBILE: Responsive padding
                                      vertical: isCompact ? 14 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          
                          SizedBox(height: isCompact ? 16 : 20), // MOBILE: Bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MOBILE HELPER METHODS:
  Widget _buildPredictionItem(String title, String value, String subtitle, bool isCompact) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isCompact ? 9 : 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isCompact ? 8 : 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnomalyItem(AnomalyDetection anomaly, bool isCompact) {
    return Column(
      children: [
        Text(
          'Alert',
          style: TextStyle(
            color: _getAnomalyColor(anomaly.severity).withOpacity(0.9),
            fontSize: isCompact ? 9 : 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          _getAnomalyIcon(anomaly.severity),
          color: _getAnomalyColor(anomaly.severity),
          size: isCompact ? 16 : 18,
        ),
        Text(
          anomaly.severity.name.toUpperCase(),
          style: TextStyle(
            color: _getAnomalyColor(anomaly.severity),
            fontSize: isCompact ? 8 : 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, String value, bool isPositive, bool isCompact) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isCompact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A365D),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isPositive 
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFFF44336).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 9 : 10,
              fontWeight: FontWeight.w500,
              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionsDisplay(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotions:',
          style: TextStyle(
            fontSize: isCompact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A365D),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: currentEmotionScores.entries
              .where((e) => e.value > 0)
              .map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${e.key} ${(e.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: isCompact ? 8 : 9,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildKeywordsDisplay(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keywords:',
          style: TextStyle(
            fontSize: isCompact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A365D),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          currentKeywords.join(', '),
          style: TextStyle(
            fontSize: isCompact ? 9 : 10,
            color: const Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  // Helper methods for anomaly display
  IconData _getAnomalyIcon(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.mild:
        return Icons.info_outline;
      case AnomalySeverity.moderate:
        return Icons.warning_amber;
      case AnomalySeverity.severe:
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getAnomalyColor(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.mild:
        return const Color(0xFF2196F3);
      case AnomalySeverity.moderate:
        return const Color(0xFFFF9800);
      case AnomalySeverity.severe:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  // Keep all your existing methods unchanged...
  Future<void> _getAdvancedAIAnalysis() async {
    if (selectedMood == null) return;
    
    setState(() {
      isAnalyzing = true;
    });
    
    try {
      final moodService = Provider.of<MoodDataService>(context, listen: false);
      
      String advancedContext = '''
ADVANCED AI MOOD ANALYSIS REQUEST

CURRENT ENTRY ANALYSIS:
- Selected Mood: ${moods[selectedMood!]['label']} (${moods[selectedMood!]['value']}/5)
- User Notes: ${additionalNotes?.isNotEmpty == true ? additionalNotes! : 'No additional notes provided'}
- Timestamp: ${DateTime.now().toString()}

NLP ANALYSIS RESULTS:
- Sentiment Score: ${currentSentiment.toStringAsFixed(2)} (Range: -5 to +5)
- Detected Emotions: ${currentEmotionScores.entries.where((e) => e.value > 0).map((e) => '${e.key}: ${(e.value * 100).toInt()}%').join(', ')}
- Extracted Keywords: ${currentKeywords.join(', ')}

ENHANCED MACHINE LEARNING INSIGHTS:
- Advanced AI Prediction: ${advancedPrediction?.prediction.toStringAsFixed(2) ?? 'N/A'}/5
- Prediction Confidence: ${advancedPrediction != null ? (advancedPrediction!.confidence * 100).round() : 0}%
- Confidence Interval: ${advancedPrediction != null ? '${advancedPrediction!.confidenceInterval[0].toStringAsFixed(1)}-${advancedPrediction!.confidenceInterval[1].toStringAsFixed(1)}' : 'N/A'}
- ML Methodology: ${advancedPrediction?.methodology ?? 'Insufficient data'}
- Uncertainty Factors: ${advancedPrediction?.uncertaintyFactors.join(', ') ?? 'None identified'}
- Anomaly Detection: ${anomalyDetection?.hasAnomaly == true ? '${anomalyDetection!.anomalyType} (${anomalyDetection!.severity.name})' : 'No anomalies detected'}
- Historical Data Points: ${moodService.moodHistory.length}

REAL HISTORICAL CONTEXT:
${moodService.hasData ? _buildRealHistoryContext(moodService.moodHistory) : 'No previous entries for pattern analysis'}

ADVANCED AI ANALYSIS REQUEST:
Please provide a comprehensive analysis integrating all available real data and advanced ML concepts.
''';
      
      final analysis = await _aiService.getAIResponse(advancedContext);
      
      setState(() {
        aiInsight = analysis;
        isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        aiInsight = _getAdvancedFallbackInsight();
        isAnalyzing = false;
      });
    }
  }

  String _buildRealHistoryContext(List<MoodEntry> history) {
    final recentEntries = history.take(10).toList();
    String context = "Real User Data Analysis:\n";
    
    List<double> moods = recentEntries.map((e) => e.mood.toDouble()).toList();
    double mean = moods.reduce((a, b) => a + b) / moods.length;
    double variance = moods.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / moods.length;
    double stdDev = sqrt(variance);
    
    context += "Statistical Summary: Mean=${mean.toStringAsFixed(2)}, StdDev=${stdDev.toStringAsFixed(2)}\n";
    
    if (advancedPrediction != null) {
      context += "Prediction Model: ${advancedPrediction!.methodology}\n";
      context += "Confidence: ${(advancedPrediction!.confidence * 100).round()}% (Range: ${advancedPrediction!.confidenceInterval[0].toStringAsFixed(1)}-${advancedPrediction!.confidenceInterval[1].toStringAsFixed(1)})\n";
    }
    
    for (int i = 0; i < min(5, recentEntries.length); i++) {
      // CONTINUATION AND COMPLETION OF MOBILE MOOD TRACKER

      final entry = recentEntries[i];
      context += "${i + 1}. ${entry.moodLabel} (${entry.mood}/5) - ${_formatDate(entry.timestamp)}";
      if (entry.sentimentScore != 0) {
        context += " | Sentiment: ${entry.sentimentScore.toStringAsFixed(1)}";
      }
      if (entry.detectedKeywords.isNotEmpty) {
        context += " | Keywords: ${entry.detectedKeywords.join(', ')}";
      }
      if (entry.aiPredictedTrigger.isNotEmpty) {
        context += " | Trigger: ${entry.aiPredictedTrigger}";
      }
      context += "\n";
    }
    
    return context;
  }

  String _getAdvancedFallbackInsight() {
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    
    String insight = "🤖 **ADVANCED AI/ML ANALYSIS REPORT** (Real Data)\n\n";
    
    if (advancedPrediction != null) {
      insight += "**🎯 Advanced ML Prediction Analysis:**\n";
      insight += "Ensemble prediction: ${advancedPrediction!.prediction.toStringAsFixed(1)}/5\n";
      insight += "Your selection: ${moods[selectedMood!]['value']}/5\n";
      insight += "Confidence: ${(advancedPrediction!.confidence * 100).round()}% (${advancedPrediction!.confidenceInterval[0].toStringAsFixed(1)}-${advancedPrediction!.confidenceInterval[1].toStringAsFixed(1)})\n";
      insight += "Methodology: ${advancedPrediction!.methodology}\n";
      
      double variance = (moods[selectedMood!]['value'] - advancedPrediction!.prediction).abs();
      if (variance < 0.5) {
        insight += "✅ High prediction accuracy: Model confidence validated\n";
      } else if (variance > advancedPrediction!.confidenceInterval[1] - advancedPrediction!.confidenceInterval[0]) {
        insight += "⚠️ Outside confidence interval: Unexpected factors may be influencing your mood\n";
      } else {
        insight += "📊 Within expected range: Normal prediction variance\n";
      }
      
      if (advancedPrediction!.uncertaintyFactors.isNotEmpty) {
        insight += "Uncertainty factors: ${advancedPrediction!.uncertaintyFactors.join(', ')}\n";
      }
      insight += "\n";
    }
    
    if (anomalyDetection != null && anomalyDetection!.hasAnomaly) {
      insight += "**🚨 Anomaly Detection Results (Real Data):**\n";
      insight += "Severity: ${anomalyDetection!.severity.name.toUpperCase()}\n";
      insight += "Pattern: ${anomalyDetection!.anomalyType}\n";
      insight += "Confidence: ${(anomalyDetection!.confidence * 100).round()}%\n";
      insight += "Recommendation: ${anomalyDetection!.recommendedAction}\n\n";
    }
    
    insight += "**📊 Real Data Summary:**\n";
    insight += "Total tracked entries: ${moodService.moodHistory.length}\n";
    insight += "Average mood: ${moodService.getAverageMood().toStringAsFixed(1)}/5\n";
    insight += "Most common mood: ${moodService.getMostCommonMood()}\n";
    insight += "Mood trend: ${moodService.getMoodTrend() > 0 ? 'Improving' : moodService.getMoodTrend() < 0 ? 'Declining' : 'Stable'}\n\n";
    
    insight += "**🔬 Analysis connected to real user data with ${moodService.moodHistory.length} authentic entries.**";
    
    return insight;
  }

  // Helper methods
  String _predictMoodTrigger() {
    if (currentKeywords.isEmpty) return "Unknown trigger";
    
    Map<String, String> triggerPatterns = {
      'work': 'Work-related stress',
      'tired': 'Fatigue/Sleep issues',
      'family': 'Family dynamics',
      'money': 'Financial concerns',
      'health': 'Health concerns',
      'relationship': 'Relationship issues',
      'stress': 'General stress',
      'anxiety': 'Anxiety response',
      'lonely': 'Social isolation',
      'overwhelmed': 'Overwhelm/Burnout'
    };
    
    for (String keyword in currentKeywords) {
      for (String pattern in triggerPatterns.keys) {
        if (keyword.toLowerCase().contains(pattern)) {
          return triggerPatterns[pattern]!;
        }
      }
    }
    
    return "Environmental/Contextual factors";
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "${difference} days ago";
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}