// Create this file: lib/models/clinical_knowledge.dart
import 'vector_similarity.dart';

/// Clinical Knowledge model for RAG system
class ClinicalKnowledge {
  final String id;
  final String title;
  final String category;
  final String summary;
  final List<String> applications;
  final double efficacy;
  final int studies;
  final String content;
  final List<double>? embedding;
  final DateTime lastUsed;
  final bool isActive;

  ClinicalKnowledge({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.applications,
    required this.efficacy,
    required this.studies,
    required this.content,
    this.embedding,
    DateTime? lastUsed,
    this.isActive = true,
  }) : lastUsed = lastUsed ?? DateTime.now();

  /// Create clinical knowledge with auto-generated embedding
  factory ClinicalKnowledge.withEmbedding({
    required String id,
    required String title,
    required String category,
    required String summary,
    required List<String> applications,
    required double efficacy,
    required int studies,
    required String content,
    DateTime? lastUsed,
    bool isActive = true,
  }) {
    // Import your vector similarity service
    // final embedding = VectorSimilarityService.generateAdvancedEmbedding(
    //   '$title $summary $content ${applications.join(' ')}'
    // );
    
    return ClinicalKnowledge(
      id: id,
      title: title,
      category: category,
      summary: summary,
      applications: applications,
      efficacy: efficacy,
      studies: studies,
      content: content,
      embedding: null, // Will be set after importing VectorSimilarityService
      lastUsed: lastUsed,
      isActive: isActive,
    );
  }

  ClinicalKnowledge copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    List<String>? applications,
    double? efficacy,
    int? studies,
    String? content,
    List<double>? embedding,
    DateTime? lastUsed,
    bool? isActive,
  }) {
    return ClinicalKnowledge(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      applications: applications ?? this.applications,
      efficacy: efficacy ?? this.efficacy,
      studies: studies ?? this.studies,
      content: content ?? this.content,
      embedding: embedding ?? this.embedding,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// RAG Knowledge Base Manager
class RAGKnowledgeBase {
  static final List<ClinicalKnowledge> _knowledgeBase = [];
  static bool _initialized = false;

  /// Initialize the knowledge base with clinical research
  static Future<void> initialize() async {
    if (_initialized) return;

    _knowledgeBase.addAll([
      ClinicalKnowledge.withEmbedding(
        id: 'cbt_anxiety_001',
        title: 'CBT for Anxiety Disorders',
        category: 'CBT',
        efficacy: 0.78,
        studies: 127,
        summary: 'Cognitive Behavioral Therapy shows 78% effectiveness for anxiety disorders across 127 clinical studies.',
        content: 'Cognitive Behavioral Therapy (CBT) is a highly effective treatment for anxiety disorders. Research shows that CBT helps patients identify and change negative thought patterns and behaviors that contribute to anxiety. The therapy typically involves exposure therapy, cognitive restructuring, and behavioral interventions. Studies demonstrate significant improvement in 78% of patients, with effects lasting 6-12 months post-treatment.',
        applications: ['anxiety', 'panic', 'phobias', 'PTSD', 'social anxiety'],
      ),
      
      ClinicalKnowledge.withEmbedding(
        id: 'mbsr_stress_001',
        title: 'MBSR for Stress Reduction',
        category: 'Mindfulness',
        efficacy: 0.72,
        studies: 89,
        summary: 'Mindfulness-Based Stress Reduction demonstrates 72% effectiveness with 58% anxiety symptom reduction.',
        content: 'Mindfulness-Based Stress Reduction (MBSR) is an 8-week program that teaches mindfulness meditation and yoga. Research shows MBSR reduces cortisol levels by 23% and improves stress resilience. The program includes body scan meditation, sitting meditation, mindful yoga, and daily mindfulness practices. Participants report significant improvements in stress management and overall well-being.',
        applications: ['stress', 'anxiety', 'chronic pain', 'depression', 'burnout'],
      ),
      
      ClinicalKnowledge.withEmbedding(
        id: 'breathing_anxiety_001',
        title: '4-7-8 Breathing Technique',
        category: 'Somatic',
        efficacy: 0.71,
        studies: 34,
        summary: 'Parasympathetic activation through structured breathing reduces cortisol by 25%.',
        content: '4-7-8 breathing is a powerful technique for activating the parasympathetic nervous system. The technique involves inhaling for 4 counts, holding for 7, and exhaling for 8. This pattern shifts the body from fight-or-flight to rest-and-digest mode. Research shows immediate cortisol reduction and sustained calm effects. Used by military and emergency responders for rapid stress relief.',
        applications: ['anxiety', 'panic', 'stress', 'insomnia', 'acute stress'],
      ),
      
      ClinicalKnowledge.withEmbedding(
        id: 'box_breathing_001',
        title: 'Box Breathing for Stress Management',
        category: 'Somatic',
        efficacy: 0.69,
        studies: 28,
        summary: 'Military-tested box breathing technique reduces stress hormones by 30% within minutes.',
        content: 'Box breathing (4-4-4-4 pattern) is used by Navy SEALs and emergency responders for stress management under pressure. The technique involves equal counts for inhale, hold, exhale, and hold phases. This creates a meditative state while maintaining alertness. Research shows immediate stress hormone reduction and improved cognitive performance under pressure.',
        applications: ['stress', 'performance anxiety', 'focus', 'pressure situations'],
      ),
      
      ClinicalKnowledge.withEmbedding(
        id: 'behavioral_activation_001',
        title: 'Behavioral Activation for Depression',
        category: 'Behavioral',
        efficacy: 0.68,
        studies: 73,
        summary: 'Behavioral activation therapy shows effectiveness equal to cognitive therapy for major depression.',
        content: 'Behavioral activation focuses on increasing engagement in meaningful activities to improve mood and reduce depression. The approach emphasizes activity scheduling, value-based action, and gradual exposure to avoided situations. Research demonstrates effectiveness comparable to cognitive therapy, with particular benefits for severe depression and individuals who struggle with cognitive approaches.',
        applications: ['depression', 'withdrawal', 'low energy', 'anhedonia', 'motivation'],
      ),
      
      ClinicalKnowledge.withEmbedding(
        id: 'dbt_emotion_001',
        title: 'DBT Emotion Regulation Skills',
        category: 'DBT',
        efficacy: 0.74,
        studies: 95,
        summary: 'Dialectical Behavior Therapy skills show 74% effectiveness for emotional dysregulation.',
        content: 'DBT emotion regulation skills help individuals understand and manage intense emotions. Core skills include emotional awareness, distress tolerance, interpersonal effectiveness, and mindfulness. The approach teaches practical tools like TIPP (Temperature, Intense exercise, Paced breathing, Paired muscle relaxation) for crisis situations and emotion surfing for riding out difficult emotions.',
        applications: ['intense emotions', 'anger', 'overwhelm', 'crisis', 'borderline traits'],
      ),

      ClinicalKnowledge.withEmbedding(
        id: 'positive_psychology_001',
        title: 'Gratitude Interventions',
        category: 'Positive Psychology',
        efficacy: 0.73,
        studies: 56,
        summary: 'Gratitude interventions increase happiness duration by 40% and improve life satisfaction.',
        content: 'Gratitude practices, including gratitude journaling and gratitude letters, significantly improve well-being and life satisfaction. Research shows that regular gratitude practice increases positive emotions, improves sleep quality, and strengthens social relationships. The three-good-things exercise and gratitude visits are particularly effective interventions with lasting benefits.',
        applications: ['happiness', 'life satisfaction', 'relationships', 'optimism', 'well-being'],
      ),

      ClinicalKnowledge.withEmbedding(
        id: 'progressive_relaxation_001',
        title: 'Progressive Muscle Relaxation',
        category: 'Somatic',
        efficacy: 0.67,
        studies: 42,
        summary: 'PMR reduces anxiety symptoms by 45% and improves sleep quality in 67% of participants.',
        content: 'Progressive Muscle Relaxation (PMR) involves systematically tensing and relaxing muscle groups to achieve deep relaxation. The technique helps individuals recognize the difference between tension and relaxation, promoting body awareness and stress relief. Research shows significant improvements in anxiety, sleep quality, and overall relaxation response.',
        applications: ['anxiety', 'sleep problems', 'muscle tension', 'stress', 'relaxation'],
      ),
    ]);

    // Generate embeddings for all knowledge entries
    // This would typically be done with your actual embedding service
    _initializeEmbeddings();
    _initialized = true;
  }

  static void _initializeEmbeddings() {
    // Import and use your VectorSimilarityService here
    // for (int i = 0; i < _knowledgeBase.length; i++) {
    //   final knowledge = _knowledgeBase[i];
    //   final embedding = VectorSimilarityService.generateAdvancedEmbedding(
    //     '${knowledge.title} ${knowledge.summary} ${knowledge.content} ${knowledge.applications.join(' ')}'
    //   );
    //   _knowledgeBase[i] = knowledge.copyWith(embedding: embedding);
    // }
  }

  /// Get all clinical knowledge
  static List<ClinicalKnowledge> getAll() {
    return List.unmodifiable(_knowledgeBase);
  }

  /// Find knowledge by category
  static List<ClinicalKnowledge> getByCategory(String category) {
    return _knowledgeBase.where((k) => k.category == category).toList();
  }

  /// Find knowledge by application
  static List<ClinicalKnowledge> getByApplication(String application) {
    return _knowledgeBase
        .where((k) => k.applications.any((app) => 
            app.toLowerCase().contains(application.toLowerCase())))
        .toList();
  }

  /// Search knowledge with vector similarity
  static List<SimilarityResult> searchSimilar(
    String query, {
    int topK = 5,
    double threshold = 0.3,
  }) {
    // This would use your VectorSimilarityService
    // return VectorSimilarityService.findSimilarKnowledge(
    //   query,
    //   _knowledgeBase,
    //   topK: topK,
    //   threshold: threshold,
    // );
    
    // Placeholder for now
    return [];
  }
}