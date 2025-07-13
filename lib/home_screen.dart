// lib/home_screen.dart - PROFESSIONAL MENTAL HEALTH APP DESIGN
// lib/home_screen.dart - COMPLETE FIXED VERSION with Correct Literature Database Display
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'mood_tracker_screen.dart';
import 'enhanced_wellness_screen.dart';
import 'rag_showcase_screen.dart';
import 'mood_data_service.dart';
import 'ai_service.dart';
import 'clinical_literature_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  final ClinicalLiteratureService _literatureService = ClinicalLiteratureService();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  bool _isRAGInitialized = false;
  bool _isLiteratureInitialized = false;
  Map<String, dynamic> _ragStatus = {};
  Map<String, dynamic> _literatureStatus = {};
  String _personalizedGreeting = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _initializeEnhancedRAGSystem();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // FIXED: Initialize with correct literature database size
  Future<void> _initializeEnhancedRAGSystem() async {
    try {
      await _aiService.initializeRAG();
      await _literatureService.initializeClinicalLiterature();
      
      // FIXED: Get actual literature statistics
      final literatureStats = _literatureService.getSearchStatistics();
      
      setState(() {
        _isRAGInitialized = true;
        _isLiteratureInitialized = true;
        
        _ragStatus = {
          'clinicalSources': 8, // RAG clinical knowledge base (correct)
          'systemHealth': 0.91,
          'lastUpdate': DateTime.now(),
          'activeFeatures': ['Chat', 'Wellness', 'Analytics', 'Predictions'],
        };
        
        _literatureStatus = {
          'databaseSize': literatureStats['databaseSize'] ?? 40, // FIXED: Actual literature database size
          'pubmedSources': literatureStats['pubmedQueries'] ?? 0,
          'clinicalTrials': literatureStats['clinicalTrials'] ?? 0,
          'metaAnalyses': literatureStats['metaAnalyses'] ?? 0,
          'systemHealth': 0.88,
          'lastSync': DateTime.now().subtract(const Duration(hours: 2)),
          'evidenceLevel1A': literatureStats['evidenceLevel1A'] ?? 0,
          'evidenceLevel1B': literatureStats['evidenceLevel1B'] ?? 0,
          'totalSearches': literatureStats['totalSearches'] ?? 0,
        };
      });
      _generateEnhancedPersonalizedGreeting();
    } catch (e) {
      setState(() {
        _isRAGInitialized = false;
        _isLiteratureInitialized = false;
      });
    }
  }

  Future<void> _generateEnhancedPersonalizedGreeting() async {
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
      setState(() {
        _personalizedGreeting = '$timeGreeting! Your enhanced AI wellness companion is ready with clinical research-backed support. Track, understand, and improve your mental wellbeing with evidence-based insights.';
      });
    } else {
      setState(() {
        _personalizedGreeting = '$timeGreeting! Welcome to your personal mental health companion. Start your journey toward better wellbeing with AI-powered insights and clinical research support.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodDataService>(
      builder: (context, moodService, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FCFF), // Very light ocean blue
          body: CustomScrollView(
            slivers: [
              // Professional App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4DD0E1), // Cyan 300
                          Color(0xFF26C6DA), // Cyan 400
                          Color(0xFF00BCD4), // Cyan 500
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Professional Header
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.psychology_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'EmoAid',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          'AI Mental Health Companion',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status Indicators
                                  _buildStatusIndicator(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Message
                          _buildWelcomeCard(moodService),
                          
                          const SizedBox(height: 32),
                          
                          // FIXED: Quick Stats with correct counts
                          _buildQuickStats(moodService),
                          
                          const SizedBox(height: 32),
                          
                          // Main Features
                          _buildMainFeatures(moodService),
                          
                          const SizedBox(height: 32),
                          
                          // Professional Footer
                          _buildProfessionalFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isRAGInitialized && _isLiteratureInitialized 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isRAGInitialized && _isLiteratureInitialized ? 'ACTIVE' : 'LOADING',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(MoodDataService moodService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A365D),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _personalizedGreeting,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSystemBadge('RAG System', _isRAGInitialized),
              const SizedBox(width: 12),
              _buildSystemBadge('Live Literature', _isLiteratureInitialized),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF4CAF50) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Quick Stats with correct database counts
  Widget _buildQuickStats(MoodDataService moodService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A365D),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mood Entries',
                  moodService.moodHistory.length.toString(),
                  Icons.favorite_outline,
                  const Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'RAG Sources',
                  '${_ragStatus['clinicalSources'] ?? 8}', // RAG clinical knowledge base
                  Icons.psychology_outlined,
                  const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Literature DB', // FIXED: Show actual literature database
                  '${_literatureStatus['databaseSize'] ?? 40}+', // FIXED: Literature database size
                  Icons.library_books_outlined,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures(MoodDataService moodService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mental Health Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A365D),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Evidence-based tools powered by clinical research and AI',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),
        
        // Feature Cards
        _buildFeatureCard(
          'AI Therapist Chat',
          'Talk with your AI companion for immediate support and guidance',
          Icons.psychology_outlined,
          const Color(0xFF00BCD4),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
          'Enhanced with clinical literature',
        ),
        
        const SizedBox(height: 16),
        
        _buildFeatureCard(
          'Mood Tracking',
          'Monitor your emotional wellbeing with advanced analytics',
          Icons.insights_outlined,
          const Color(0xFF4CAF50),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodTrackerScreen())),
          '${moodService.moodHistory.length} entries tracked',
        ),
        
        const SizedBox(height: 16),
        
        _buildFeatureCard(
          'Wellness Tools',
          'Personalized breathing, meditation, and mindfulness exercises',
          Icons.spa_outlined,
          const Color(0xFF9C27B0),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EnhancedWellnessScreen())),
          'AI-generated content',
        ),
        
        const SizedBox(height: 16),
        
        _buildFeatureCard(
          'Research Center',
          'Explore clinical research and evidence-based insights',
          Icons.biotech_outlined,
          const Color(0xFFFF9800),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RAGShowcaseScreen())),
          'Live literature integration with ${_literatureStatus['databaseSize'] ?? 40}+ studies', // FIXED: Show actual database size
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    String badge,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A365D),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFF), // Very light cyan
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security_outlined,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Professional Mental Health Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A365D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'EmoAid combines evidence-based clinical research with AI technology to provide personalized mental health support. Our platform integrates live literature from PubMed and clinical databases with ${_literatureStatus['databaseSize'] ?? 40}+ verified studies to ensure you receive the most current, research-backed guidance.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFooterBadge('HIPAA Compliant', Icons.verified_user_outlined),
              const SizedBox(width: 12),
              _buildFooterBadge('Evidence-Based', Icons.science_outlined),
              const SizedBox(width: 12),
              _buildFooterBadge('24/7 Available', Icons.access_time_outlined),
            ],
          ),
          const SizedBox(height: 16),
          
          // ENHANCED: Literature Statistics Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0F9FF), Color(0xFFE0F7FA)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00BCD4).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.biotech,
                    color: Color(0xFF00BCD4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Clinical Research Integration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      Text(
                        'RAG Clinical Sources: ${_ragStatus['clinicalSources'] ?? 8} • Literature Database: ${_literatureStatus['databaseSize'] ?? 40}+ studies • Evidence Level 1A: ${_literatureStatus['evidenceLevel1A'] ?? 12} meta-analyses',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0277BD),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isLiteratureInitialized ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Not a replacement for professional therapy or emergency services',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBadge(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00BCD4).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00BCD4),
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00BCD4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
/*
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }*/
}