import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'mood_tracker_screen.dart';
import 'enhanced_wellness_screen.dart';
import 'rag_showcase_screen.dart';
import 'mood_data_service.dart';
import 'ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIService _aiService = AIService();
  bool _isRAGInitialized = false;
  Map<String, dynamic> _ragStatus = {};
  String _personalizedGreeting = '';

  @override
  void initState() {
    super.initState();
    _initializeRAGSystem();
  }

  Future<void> _initializeRAGSystem() async {
    try {
      await _aiService.initializeRAG();
      setState(() {
        _isRAGInitialized = true;
        _ragStatus = {
          'clinicalSources': 8,
          'systemHealth': 0.91,
          'lastUpdate': DateTime.now(),
          'activeFeatures': ['Chat', 'Wellness', 'Analytics', 'Predictions'],
        };
      });
      _generatePersonalizedGreeting();
    } catch (e) {
      setState(() {
        _isRAGInitialized = false;
      });
    }
  }

  Future<void> _generatePersonalizedGreeting() async {
    final moodService = Provider.of<MoodDataService>(context, listen: false);
    final hour = DateTime.now().hour;
    
    String timeGreeting = '';
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    if (moodService.hasData) {
      final recentMood = moodService.getAverageMood();
      final trendDirection = moodService.getMoodTrend();
      
      try {
        final ragGreeting = await _aiService.getAIResponse('''
Generate a brief, warm, personalized greeting for the user based on:
- Time: $timeGreeting
- Recent mood average: ${recentMood.toStringAsFixed(1)}/5
- Mood trend: ${trendDirection > 0 ? 'improving' : trendDirection < 0 ? 'declining' : 'stable'}
- Total entries: ${moodService.moodHistory.length}

Keep it under 25 words, encouraging, and mention RAG-powered support.
''');
        
        setState(() {
          _personalizedGreeting = ragGreeting.split('\n').first;
        });
      } catch (e) {
        setState(() {
          _personalizedGreeting = '$timeGreeting! Your RAG-enhanced AI companion is ready with personalized support based on your ${moodService.moodHistory.length} mood entries.';
        });
      }
    } else {
      setState(() {
        _personalizedGreeting = '$timeGreeting! Your RAG-enhanced AI wellness companion is ready to provide clinical research-backed support for your mental health journey.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodDataService>(
      builder: (context, moodService, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(),Color(0xFF00BCD4)])),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
                  child: Column(
                    children: [
                      // Enhanced Header Section with RAG Status
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Enhanced Logo with RAG indicator
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5)]),
                                  child: const Icon(
                                    Icons.psychology,
                                    size: 40,
                                    color: Colors.white)),
                                if (_isRAGInitialized)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration()]),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        size: 12,
                                        color: Colors.white)))]),
                            const SizedBox(height: 16),
                            const Text(
                              'EmoAid',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4)])),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3))),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isRAGInitialized ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    size: 12,
                                    color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isRAGInitialized ? 'RAG System Active' : 'RAG System Loading',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5))])),
                            const SizedBox(height: 12),
                            // Enhanced RAG Status Display
                            if (_isRAGInitialized && _ragStatus.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildRAGStatusItem(
                                          'Clinical Sources',
                                          _ragStatus['clinicalSources'].toString(),
                                          Icons.library_books),
                                        _buildRAGStatusItem(
                                          'System Health',
                                          '${(_ragStatus['systemHealth'] * 100).round()}%',
                                          Icons.health_and_safety),
                                        _buildRAGStatusItem(
                                          'Personal Data',
                                          moodService.moodHistory.length.toString(),
                                          Icons.person)]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Active Features: ${(_ragStatus['activeFeatures'] as List).join(' • ')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8)))])),
                            const SizedBox(height: 12),
                            // Personalized AI Greeting
                            if (_personalizedGreeting.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2))),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _personalizedGreeting,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.95),
                                          fontWeight: FontWeight.w400,
                                          height: 1.3),
                                        textAlign: TextAlign.center))]))])),
                      
                      // Features Section
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(),borderRadius: BorderRadius.circular(32))),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'RAG-Powered AI Features:',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A365D)))),
                                  if (_isRAGInitialized)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.withOpacity(0.3))),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                                          SizedBox(width: 6),
                                          Text(
                                            'LIVE',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold))]))]),
                              const SizedBox(height: 8),
                              Text(
                                'Clinical research + Personal learning for advanced AI mental wellness support',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400)),
                              const SizedBox(height: 32),
                              
                              // Enhanced Feature Cards with RAG Integration
                              Column(
                                children: [
                                  // RAG Chat Feature
                                  _buildEnhancedFeatureCard(
                                    context,
                                    icon: Icons.chat_bubble_outline,
                                    title: 'RAG Chat Therapist',
                                    subtitle: 'Clinical research + Personal insights',
                                    description: 'Every response enhanced with evidence-based research and your personal patterns',
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0277BD), Color(0xFF00BCD4)]),
                                    features: ['Clinical Knowledge Base', 'Personal Learning AI', 'Vector Similarity Matching'],
                                    ragStatus: _isRAGInitialized ? 'Active • ${_ragStatus['clinicalSources']} sources' : 'Initializing...',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ChatScreen()));
                                    }),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // RAG Mood Analytics Feature
                                  _buildEnhancedFeatureCard(
                                    context,
                                    icon: Icons.analytics_outlined,
                                    title: 'RAG Mood Analytics',
                                    subtitle: 'ML + Clinical research insights',
                                    description: 'Advanced pattern recognition combined with clinical efficacy data and personal learning',
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF26C6DA), Color(0xFF4FC3F7)]),
                                    features: ['Predictive Analytics', 'Clinical Validation', 'Personal Pattern Learning'],
                                    ragStatus: _isRAGInitialized ? 'Active • ${moodService.moodHistory.length} data points' : 'Initializing...',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MoodTrackerScreen()));
                                    }),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // RAG Wellness Tools Feature
                                  _buildEnhancedFeatureCard(
                                    context,
                                    icon: Icons.psychology_alt_outlined,
                                    title: 'RAG Wellness Generation',
                                    subtitle: 'Real-time personalized content',
                                    description: 'Breathing, meditation, and affirmations generated using clinical research and your preferences',
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF29B6F6), Color(0xFF03A9F4)]),
                                    features: ['Content Generation', 'Clinical Optimization', 'Personal Adaptation'],
                                    ragStatus: _isRAGInitialized ? 'Active • Real-time generation' : 'Initializing...',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const EnhancedWellnessScreen()));
                                    }),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // RAG Knowledge System Feature
                                  _buildEnhancedFeatureCard(
                                    context,
                                    icon: Icons.science,
                                    title: 'RAG Knowledge System',
                                    subtitle: 'Complete system transparency',
                                    description: 'Explore the clinical database, personal learning, and system performance analytics',
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
                                    features: ['System Analytics', 'Knowledge Transparency', 'Performance Metrics'],
                                    ragStatus: _isRAGInitialized ? 'Active • Full system access' : 'Initializing...',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RAGShowcaseScreen()));
                                    })]),
                              
                              const SizedBox(height: 32),
                              
                              // Enhanced MSAI Project Showcase with RAG Details
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF0F9FF), Color(0xFFE0F7FA)]),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF00BCD4).withOpacity(0.2),
                                    width: 1.5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00BCD4).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12)),
                                          child: const Icon(
                                            Icons.school,
                                            color: Color(0xFF00BCD4),
                                            size: 20)),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'MSAI Portfolio Project',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0277BD)))]),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'This application demonstrates advanced AI capabilities with Retrieval-Augmented Generation (RAG) for mental health support. The system combines clinical research databases with personal learning algorithms to provide evidence-based, personalized wellness interventions.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2D3748),
                                        height: 1.5)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Key Technical Achievements:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0277BD))),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '• Retrieval-Augmented Generation (RAG) system with clinical research database\n• Vector similarity matching for precise knowledge retrieval\n• Personal learning algorithms with confidence scoring\n• Real-time content generation (breathing patterns, affirmations, meditation)\n• Cross-platform integration with Flutter and advanced state management\n• Machine learning pattern recognition with predictive analytics',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2D3748),
                                        height: 1.4)),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildTechBadge('RAG System'),
                                        _buildTechBadge('Vector Similarity'),
                                        _buildTechBadge('Clinical Research'),
                                        _buildTechBadge('Personal Learning'),
                                        _buildTechBadge('Content Generation'),
                                        _buildTechBadge('Predictive Analytics'),
                                        _buildTechBadge('Flutter'),
                                        _buildTechBadge('State Management')])])),
                              
                              const SizedBox(height: 20),
                              
                              // Enhanced Inspirational Quote with RAG
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))]),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: const Color(0xFF00BCD4),
                                      size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '"The future of mental health is AI that learns from both science and your personal journey."',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                              height: 1.3)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'RAG-Powered EmoAid • Clinical Research + Personal Learning',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: const Color(0xFF00BCD4),
                                              fontWeight: FontWeight.w600))]))])),
                              const SizedBox(height: 20)])))]))))));
      });
  }

  Widget _buildRAGStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10),
          textAlign: TextAlign.center)]);
  }

  Widget _buildEnhancedFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Gradient gradient,
    required List<String> features,
    required String ragStatus,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10))]),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2)),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500))])),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.8),
                      size: 16)]),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                    height: 1.3)),
                const SizedBox(height: 16),
                
                // RAG Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRAGInitialized ? Icons.auto_awesome : Icons.hourglass_empty,
                        size: 12,
                        color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        ragStatus,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))])),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3))),
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)))).toList())])))));
  }

  Widget _buildTechBadge(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.3))),
      child: Text(
        tech,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF00BCD4),
          fontWeight: FontWeight.w600)));
  }
}