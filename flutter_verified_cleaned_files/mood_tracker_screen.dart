// lib/mood_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'ai_service.dart';
import 'analytics_screen.dart';
import 'mood_entry.dart';
import 'mood_data_service.dart';

// Keep all your existing ML classes (MoodPredictionModel, etc.) exactly the same
class MoodPredictionModel {
  static MoodPrediction predictNextMoodAdvanced(List<MoodEntry> history) {
    if (history.length < 3) {
      return MoodPrediction(
        prediction: 3.0,
        confidence: 0.3,
        confidenceInterval: [2.5, 3.5],
        methodology: 'Insufficient data - using baseline',
        uncertaintyFactors: ['Limited historical data']);
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
      (finalPrediction + margin).clamp(1.0, 5.0)];
    
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
      uncertaintyFactors: uncertaintyFactors);
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
        recommendedAction: 'Continue tracking mood patterns');
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
      recommendedAction: recommendedAction);
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

// UPDATED: Mood Tracker Screen with Provider integration
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
  
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'label': 'Great', 'color': Color(0xFF00BCD4), 'value': 5},
    {'emoji': '🙂', 'label': 'Good', 'color': Color(0xFF26C6DA), 'value': 4},
    {'emoji': '😐', 'label': 'Okay', 'color': Color(0xFF4FC3F7), 'value': 3},
    {'emoji': '😔', 'label': 'Low', 'color': Color(0xFF29B6F6), 'value': 2},
    {'emoji': '😢', 'label': 'Bad', 'color': Color(0xFF0277BD), 'value': 1}];

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_onNotesChanged);
    _initializeData();
  }

  // UPDATED: Initialize data using Provider
  Future<void> _initializeData() async {
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    await moodService.initialize();
    _updatePredictions();
  }

  // UPDATED: Update predictions using Provider data
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

  // UPDATED: Save mood entry using Provider
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
      aiPredictedTrigger: _predictMoodTrigger());
    
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
                        style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        'Data synced to Analytics. Total entries: ${moodService.moodHistory.length}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)))]))]),
            backgroundColor: moods[selectedMood!]['color'],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4)));
        
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
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodDataService>(
      builder: (context, moodService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'AI Mood Intelligence',
              style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (moodService.hasData)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyticsScreen(moodHistory: moodService.moodHistory)));
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        const Icon(Icons.analytics, color: Colors.white),
                        if (moodService.moodHistory.length >= 3)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration()))]))),
              const SizedBox(width: 8)],
            flexibleSpace: Container(
              decoration: BoxDecoration(),Color(0xFF00BCD4)])))),
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(),Color(0xFF00BCD4)],
                stops: [0.0, 0.4])),
            child: Column(
              children: [
                // Header with real data
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      const Text(
                        'Advanced AI Mood Analysis',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(
                        'Machine Learning algorithms with confidence intervals, anomaly detection, and ensemble predictions',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      // Real data indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${moodService.moodHistory.length} real entries • Live analytics',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500))),
                      if (moodService.hasData && advancedPrediction != null) ...[
                        const SizedBox(height: 16),
                        
                        // Prediction display using real data
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3))),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'AI Prediction',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                        Text(
                                          '${advancedPrediction!.prediction.toStringAsFixed(1)}/5',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                        Text(
                                          '${(advancedPrediction!.confidence * 100).round()}% confident',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 10))])),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withOpacity(0.3)),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Confidence Range',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                        Text(
                                          '${advancedPrediction!.confidenceInterval[0].toStringAsFixed(1)}-${advancedPrediction!.confidenceInterval[1].toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                        Text(
                                          '95% interval',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 10))])),
                                  if (anomalyDetection != null && anomalyDetection!.hasAnomaly) ...[
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.white.withOpacity(0.3)),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Pattern Alert',
                                            style: TextStyle(
                                              color: Colors.orange.withOpacity(0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                          Icon(
                                            _getAnomalyIcon(anomalyDetection!.severity),
                                            color: _getAnomalyColor(anomalyDetection!.severity),
                                            size: 20),
                                          Text(
                                            anomalyDetection!.severity.name.toUpperCase(),
                                            style: TextStyle(
                                              color: _getAnomalyColor(anomalyDetection!.severity),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold))]))]]),
                              
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  advancedPrediction!.methodology,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.8)),
                                  textAlign: TextAlign.center))]))]])),
                
                // Rest of your UI remains exactly the same...
                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(),borderRadius: BorderRadius.circular(32)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced anomaly warning using real data
                          if (anomalyDetection != null && anomalyDetection!.hasAnomaly) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getAnomalyColor(anomalyDetection!.severity).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getAnomalyColor(anomalyDetection!.severity).withOpacity(0.3))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getAnomalyIcon(anomalyDetection!.severity),
                                        color: _getAnomalyColor(anomalyDetection!.severity),
                                        size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pattern Alert: ${anomalyDetection!.severity.name.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getAnomalyColor(anomalyDetection!.severity)))]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Detected: ${anomalyDetection!.anomalyType}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2D3748),
                                      fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Recommendation: ${anomalyDetection!.recommendedAction}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4A5568)))])),
                            const SizedBox(height: 24)],
                          
                          // Mood Selection
                          Row(
                            children: [
                              const Text(
                                'Select your mood:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A365D))),
                              const Spacer(),
                              if (advancedPrediction != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        size: 16,
                                        color: Color(0xFF00BCD4)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'AI suggests: ${advancedPrediction!.prediction.toStringAsFixed(1)} ±${((advancedPrediction!.confidenceInterval[1] - advancedPrediction!.confidenceInterval[0]) / 2).toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF00BCD4),
                                          fontWeight: FontWeight.w500))]))]),
                          const SizedBox(height: 20),
                          
                          // Rest of your mood selection UI...
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8))]),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.85),
                              itemCount: moods.length,
                              itemBuilder: (context, index) {
                                final mood = moods[index];
                                final isSelected = selectedMood == index;
                                
                                bool isPredicted = false;
                                double predictionConfidence = 0.0;
                                if (advancedPrediction != null) {
                                  final predictedValue = advancedPrediction!.prediction.round();
                                  isPredicted = mood['value'] == predictedValue;
                                  predictionConfidence = advancedPrediction!.confidence;
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMood = index;
                                      aiInsight = null;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: isSelected ? mood['color'] : const Color(0xFFF0FDFF),
                                      border: Border.all(
                                        color: isPredicted 
                                            ? Colors.orange
                                            : isSelected 
                                                ? mood['color'] 
                                                : const Color(0xFFB2EBF2),
                                        width: isPredicted ? 3 : 2),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: mood['color'].withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6))] : isPredicted ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))] : null),
                                    child: Stack(
                                      children: [
                                        if (isPredicted && !isSelected)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(),child: Center(
                                                child: Text(
                                                  '${(predictionConfidence * 100).round()}',
                                                  style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold))))),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              mood['emoji'],
                                              style: TextStyle(
                                                fontSize: 28,
                                                shadows: isSelected ? [
                                                  const Shadow(
                                                    color: Colors.black26,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4)] : null)),
                                            const SizedBox(height: 6),
                                            Text(
                                              mood['label'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.white : const Color(0xFF0277BD)))])])));
                              })),
                          
                          if (selectedMood != null) ...[
                            const SizedBox(height: 32),
                            
                            // Notes section (keeping your existing UI)
                            const Text(
                              'Describe your feelings (AI will analyze):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A365D))),
                            const SizedBox(height: 16),
                            
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))]),
                              child: TextField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  hintText: 'What\'s contributing to this mood? AI will detect emotions, keywords, and sentiment...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFB2EBF2))),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: moods[selectedMood!]['color'], width: 2)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFB2EBF2))),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16)),
                                maxLines: 4)),
                            
                            // Real-time NLP Analysis (keeping your existing code)
                            if (additionalNotes?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF0F9FF), Color(0xFFE0F7FA)]),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF00BCD4).withOpacity(0.2))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF00BCD4),
                                          size: 16),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Real-time NLP Analysis',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0277BD)))]),
                                    const SizedBox(height: 12),
                                    
                                    // Sentiment Score
                                    Row(
                                      children: [
                                        const Text(
                                          'Sentiment: ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3748))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: currentSentiment >= 0 
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12)),
                                          child: Text(
                                            '${currentSentiment.toStringAsFixed(1)} (${currentSentiment >= 0 ? "Positive" : "Negative"})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: currentSentiment >= 0 
                                                  ? Colors.green[700]
                                                  : Colors.red[700])))]),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Top Emotions
                                    if (currentEmotionScores.isNotEmpty) ...[
                                      const Text(
                                        'Detected Emotions:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D3748))),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: currentEmotionScores.entries
                                            .where((e) => e.value > 0)
                                            .map((e) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8)),
                                                  child: Text(
                                                    '${e.key} (${(e.value * 100).toInt()}%)',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF00BCD4)))))
                                            .toList())],
                                    
                                    // Keywords
                                    if (currentKeywords.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Key Terms:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D3748))),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentKeywords.join(', '),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF4A5568)))]]))],
                            
                            const SizedBox(height: 32),
                            
                            // AI Analysis Button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8))]),
                                child: ElevatedButton.icon(
                                  onPressed: isAnalyzing ? null : _getAdvancedAIAnalysis,
                                  icon: isAnalyzing 
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                    : const Icon(Icons.psychology, size: 22),
                                  label: Text(
                                    isAnalyzing ? 'AI Processing...' : 'Advanced AI Analysis',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: moods[selectedMood!]['color'],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                    elevation: 0)))),
                            
                            // AI Insights Display
                            if (aiInsight != null) ...[
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      moods[selectedMood!]['color'].withOpacity(0.08),
                                      moods[selectedMood!]['color'].withOpacity(0.03)]),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: moods[selectedMood!]['color'].withOpacity(0.2),
                                    width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8))]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: moods[selectedMood!]['color'].withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12)),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: moods[selectedMood!]['color'],
                                            size: 20)),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Advanced AI Insights',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: moods[selectedMood!]['color'])),
                                            Text(
                                              'ML Pattern Analysis • NLP Processing • Predictive Modeling',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: moods[selectedMood!]['color'].withOpacity(0.7)))])]),
                                    const SizedBox(height: 16),
                                    Text(
                                      aiInsight!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2D3748),
                                        height: 1.5))]))],
                            
                            const SizedBox(height: 32),
                            
                            // Save Button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: moods[selectedMood!]['color'].withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8))]),
                                child: ElevatedButton.icon(
                                  onPressed: _saveMoodWithMLFeatures,
                                  icon: const Icon(Icons.save_alt),
                                  label: const Text(
                                    'Save with AI Analysis',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: moods[selectedMood!]['color'],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                    elevation: 0))))],
                          
                          const SizedBox(height: 20)]))))])));
      });
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
        return Colors.blue;
      case AnomalySeverity.moderate:
        return Colors.orange;
      case AnomalySeverity.severe:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // AI Analysis method - using real data from Provider
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

  // Build real history context from Provider data
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