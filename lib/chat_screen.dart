// lib/chat_screen.dart - MOBILE OPTIMIZED FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_service.dart';
import 'clinical_literature_service.dart';
import 'mood_data_service.dart';
import 'theme/app_theme.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  final ClinicalLiteratureService _literatureService = ClinicalLiteratureService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  
  bool _isTyping = false;
  bool _literatureValidationEnabled = false;
  bool _isValidatingWithLiterature = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _isTyping = true;
      });
      
      await _aiService.initializeRAG();
      
      try {
        await _literatureService.initializeClinicalLiterature();
        setState(() {
          _literatureValidationEnabled = true;
        });
        print('✅ Literature service initialized');
      } catch (e) {
        print('⚠️ Literature service failed, continuing without it: $e');
      }
      
      setState(() {
        _isInitialized = true;
        _isTyping = false;
      });
      
      print('✅ Chat services initialized successfully');
    } catch (e) {
      print('⚠️ Initialization error: $e');
      setState(() {
        _isInitialized = true;
        _isTyping = false;
      });
    }
  }

  void _addWelcomeMessage() {
    _addMessage(
      "Hi! I'm EmoAid, your AI mental health companion! 🤖💙\n\nI'm here to listen, support, and provide evidence-based guidance. I use advanced AI with clinical research to help you navigate your emotions and mental wellbeing.\n\nHow are you feeling today?",
      isUser: false,
      hasRAG: true,
      hasLiterature: false,
    );
  }

  void _addMessage(String text, {
    required bool isUser, 
    bool hasRAG = false, 
    bool hasLiterature = false,
    ClinicalLiteratureResult? literatureResult,
  }) {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text, 
        isUser: isUser, 
        hasRAG: hasRAG,
        hasLiterature: hasLiterature,
        literatureResult: literatureResult,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _addMessage(userMessage, isUser: true);
    _controller.clear();

    setState(() {
      _isTyping = true;
    });

    try {
      print('🚀 Sending message to AI: "$userMessage"');
      
      final aiResponse = await _aiService.getAIResponse(userMessage);
      
      print('✅ Received AI response: "${aiResponse.substring(0, min(50, aiResponse.length))}..."');
      
      setState(() {
        _isTyping = false;
      });
      
      bool hasRAG = aiResponse.contains('Enhanced with') || 
                   aiResponse.contains('Clinical insights') || 
                   aiResponse.contains('Personal patterns') ||
                   aiResponse.contains('🧠') ||
                   aiResponse.contains('🤖');
      
      bool hasLiterature = aiResponse.contains('Recent studies') ||
                          aiResponse.contains('Meta-analysis') ||
                          aiResponse.contains('Clinical trial') ||
                          aiResponse.contains('Literature');
      
      ClinicalLiteratureResult? literatureResult;
      if (_literatureValidationEnabled && _shouldValidateWithLiterature(userMessage)) {
        setState(() {
          _isValidatingWithLiterature = true;
        });
        
        try {
          literatureResult = await _literatureService.searchClinicalLiterature(
            _extractValidationQuery(userMessage),
            maxResults: 3,
          );
          
          if (literatureResult.studies.isNotEmpty) {
            hasLiterature = true;
          }
        } catch (e) {
          print('Literature validation error: $e');
        } finally {
          setState(() {
            _isValidatingWithLiterature = false;
          });
        }
      }
      
      _addMessage(
        aiResponse, 
        isUser: false, 
        hasRAG: hasRAG, 
        hasLiterature: hasLiterature,
        literatureResult: literatureResult,
      );
      
      if (literatureResult != null && literatureResult.studies.isNotEmpty) {
        _showLiteratureValidationResults(literatureResult);
      }
      
    } catch (e) {
      print('❌ Chat error: $e');
      setState(() {
        _isTyping = false;
      });
      
      _addMessage(
        "I'm experiencing some connectivity issues, but I'm still here for you! 💙\n\nThis might be a temporary problem with my AI processing. You can try:\n\n• Rephrasing your message\n• Waiting a moment and trying again\n• Continuing our conversation - I learn and improve\n\nYour mental health matters, and I want to support you the best I can. What would you like to talk about?", 
        isUser: false,
        hasRAG: true,
      );
    }
  }

  bool _shouldValidateWithLiterature(String message) {
    final lowerMessage = message.toLowerCase();
    final clinicalKeywords = [
      'research', 'study', 'evidence', 'clinical', 'trial', 'treatment',
      'therapy', 'medication', 'effectiveness', 'efficacy'
    ];
    
    return clinicalKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  String _extractValidationQuery(String message) {
    final lowerMessage = message.toLowerCase();
    
    List<String> conditions = [];
    if (lowerMessage.contains('anxiety')) conditions.add('anxiety');
    if (lowerMessage.contains('depression')) conditions.add('depression');
    if (lowerMessage.contains('stress')) conditions.add('stress');
    if (lowerMessage.contains('ptsd')) conditions.add('ptsd');
    
    List<String> treatments = [];
    if (lowerMessage.contains('cbt') || lowerMessage.contains('cognitive')) treatments.add('CBT');
    if (lowerMessage.contains('mindfulness')) treatments.add('mindfulness');
    if (lowerMessage.contains('therapy')) treatments.add('therapy');
    
    String query = '';
    if (conditions.isNotEmpty) query += conditions.join(' ');
    if (treatments.isNotEmpty) query += ' ${treatments.join(' ')}';
    if (query.isEmpty) query = 'mental health treatment';
    
    return query;
  }

  void _showLiteratureValidationResults(ClinicalLiteratureResult result) {
    final screenSize = MediaQuery.of(context).size;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenSize.width * 0.95,
          height: screenSize.height * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science,
                      color: AppTheme.primaryCyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Research Validation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Evidence Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${result.studies.length} relevant studies',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.evidenceSummary,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Studies List Header
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Supporting Studies:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Studies List
              Expanded(
                child: ListView.separated(
                  itemCount: result.studies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final study = result.studies[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryCyan.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            study.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  study.journal,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                study.year.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  study.evidenceLevel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryCyan,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodDataService>(
      builder: (context, moodService, child) {
        return Scaffold(
          // Fix keyboard overflow issue
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'EmoAid Chat',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      if (_isInitialized)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _literatureValidationEnabled ? Icons.science : Icons.psychology,
                                size: 12,
                                color: Colors.white
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _literatureValidationEnabled ? 'Enhanced AI' : 'Smart AI',
                                style: const TextStyle(fontSize: 8, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            actions: [
              if (_literatureValidationEnabled)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _literatureValidationEnabled = !_literatureValidationEnabled;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _literatureValidationEnabled 
                                ? 'Literature validation enabled'
                                : 'Literature validation disabled',
                            style: const TextStyle(fontSize: 13),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _literatureValidationEnabled ? Icons.science : Icons.science_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: _showRAGInfoDialog,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.info, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: Column(
              children: [
                // Status header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _isInitialized 
                                ? 'AI companion ready with clinical insights'
                                : 'Initializing AI services...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_literatureValidationEnabled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'RESEARCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Messages area - Fixed for keyboard handling
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundCyan,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            itemCount: _messages.length + 
                                      (_isTyping ? 1 : 0) + 
                                      (_isValidatingWithLiterature ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == 0 && _isValidatingWithLiterature) {
                                return _buildMobileLiteratureValidationIndicator();
                              }
                              if (index == 0 && _isTyping || 
                                  (_isValidatingWithLiterature && index == 1 && _isTyping)) {
                                return _buildMobileTypingIndicator();
                              }
                              
                              final messageIndex = _isTyping && _isValidatingWithLiterature ? index - 2 : 
                                                 _isTyping || _isValidatingWithLiterature ? index - 1 : index;
                              final message = _messages[messageIndex];
                              return MobileChatBubble(message: message);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Input area - Fixed keyboard handling
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundCyan,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryCyan.withOpacity(0.3),
                                ),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: TextField(
                                controller: _controller,
                                focusNode: _textFieldFocusNode,
                                decoration: InputDecoration(
                                  hintText: _isInitialized 
                                      ? 'Share your thoughts...'
                                      : 'AI is getting ready...',
                                  hintStyle: const TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: (_) => _sendMessage(),
                                enabled: _isInitialized && !_isTyping,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: IconButton(
                              onPressed: (_isTyping || !_isInitialized) ? null : _sendMessage,
                              icon: Icon(
                                _isTyping ? Icons.hourglass_empty : Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
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

  Widget _buildMobileLiteratureValidationIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 16,
              child: Icon(
                Icons.science,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: const Color(0xFF8E24AA).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF8E24AA),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Checking clinical research...',
                  style: TextStyle(
                    color: Color(0xFF8E24AA),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 16,
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: AppTheme.primaryCyan.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRAGInfoDialog() {
    final screenSize = MediaQuery.of(context).size;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryCyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enhanced AI Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This chat uses advanced AI with enhanced features:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      _buildMobileRAGFeature(
                        Icons.psychology,
                        'Clinical Knowledge',
                        'Evidence-based mental health research and interventions',
                      ),
                      const SizedBox(height: 16),
                      _buildMobileRAGFeature(
                        Icons.memory,
                        'Personal Learning',
                        'Remembers your conversations and adapts to your needs',
                      ),
                      const SizedBox(height: 16),
                      _buildMobileRAGFeature(
                        Icons.trending_up,
                        'Vector Similarity',
                        'Advanced matching with clinical research database',
                      ),
                      if (_literatureValidationEnabled) ...[
                        const SizedBox(height: 16),
                        _buildMobileRAGFeature(
                          Icons.science,
                          'Live Research',
                          'Real-time validation with current clinical studies',
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🎯 Look for enhanced indicators in responses: 🤖 for AI insights, 🧠 for clinical knowledge, and 📚 for research validation!',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileRAGFeature(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryCyan, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }
}

// Message data model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasRAG;
  final bool hasLiterature;
  final ClinicalLiteratureResult? literatureResult;
  final DateTime timestamp;

  ChatMessage({
    required this.text, 
    required this.isUser, 
    this.hasRAG = false,
    this.hasLiterature = false,
    this.literatureResult,
    required this.timestamp,
  });
}

// Mobile optimized Chat Bubble widget
class MobileChatBubble extends StatelessWidget {
  final ChatMessage message;

  const MobileChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.8;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              decoration: BoxDecoration(
                gradient: message.hasLiterature
                    ? const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      )
                    : message.hasRAG
                        ? AppTheme.primaryGradient
                        : null,
                color: (message.hasRAG || message.hasLiterature) ? null : AppTheme.primaryCyan,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 16,
                child: Icon(
                  message.hasLiterature ? Icons.science : 
                  message.hasRAG ? Icons.auto_awesome : Icons.psychology,
                  color: Colors.white,
                  size: message.hasLiterature ? 14 : 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxBubbleWidth,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? AppTheme.primaryGradient
                    : null,
                color: message.isUser ? null : AppTheme.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: message.isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: message.isUser ? null : Border.all(
                  color: message.hasLiterature
                      ? const Color(0xFF8E24AA).withOpacity(0.4)
                      : message.hasRAG 
                          ? AppTheme.primaryCyan.withOpacity(0.3)
                          : AppTheme.primaryCyan.withOpacity(0.2),
                  width: message.hasLiterature ? 2 : 1,
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhancement indicators
                  if (!message.isUser && message.hasLiterature) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E24AA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.science,
                            size: 12,
                            color: Color(0xFF8E24AA),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Research Validated',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8E24AA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (message.literatureResult != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${message.literatureResult!.studies.length})',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8E24AA),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else if (!message.isUser && message.hasRAG) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppTheme.primaryCyan,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'AI Enhanced',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  
                  // Literature validation link
                  if (!message.isUser && 
                      message.literatureResult != null && 
                      message.literatureResult!.studies.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showMobileLiteratureDetails(context, message.literatureResult!),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E24AA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF8E24AA).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.science,
                              size: 14,
                              color: Color(0xFF8E24AA),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'View ${message.literatureResult!.studies.length} studies',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Color(0xFF8E24AA),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppTheme.primaryCyanLight,
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMobileLiteratureDetails(BuildContext context, ClinicalLiteratureResult result) {
    final screenSize = MediaQuery.of(context).size;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenSize.width * 0.95,
          height: screenSize.height * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.science,
                    color: Color(0xFF8E24AA),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Supporting Research',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Evidence Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E24AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Evidence Summary: ${result.evidenceSummary}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Studies Header
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Supporting Studies:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Studies List
              Expanded(
                child: ListView.separated(
                  itemCount: result.studies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final study = result.studies[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            study.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${study.journal} (${study.year}) - ${study.evidenceLevel}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E24AA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep the original ChatBubble class for compatibility
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MobileChatBubble(message: message);
  }

  void _showLiteratureDetails(BuildContext context, ClinicalLiteratureResult result) {
    return;
  }
}