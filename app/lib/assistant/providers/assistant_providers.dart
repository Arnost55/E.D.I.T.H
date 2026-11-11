import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import 'dart:math';

import '../../../core/providers/app_providers.dart';

/// AI Provider types available
enum AIProviderType {
  mock('Mock (Offline)', 'Built-in simulated responses'),
  openai('OpenAI', 'GPT-4, GPT-3.5 Turbo'),
  anthropic('Anthropic', 'Claude 3 Opus, Sonnet, Haiku'),
  ollama('Ollama (Local)', 'Llama 3, Mistral, CodeLlama'),
  helpex('HelpeX', 'On-device AI assistant');

  const AIProviderType(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// AI Provider configuration
class AIProviderConfig {
  const AIProviderConfig({
    required this.type,
    this.apiKey = '',
    this.baseUrl = '',
    this.model = '',
    this.enabled = false,
  });

  final AIProviderType type;
  final String apiKey;
  final String baseUrl;
  final String model;
  final bool enabled;

  AIProviderConfig copyWith({
    AIProviderType? type,
    String? apiKey,
    String? baseUrl,
    String? model,
    bool? enabled,
  }) {
    return AIProviderConfig(
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// AI Engine status
class AIEngineStatus {
  const AIEngineStatus({
    this.activeProvider = AIProviderType.mock,
    this.isConnected = false,
    this.isProcessing = false,
    this.latencyMs = 0,
    this.tokensPerSecond = 0.0,
    this.errorMessage,
  });

  final AIProviderType activeProvider;
  final bool isConnected;
  final bool isProcessing;
  final int latencyMs;
  final double tokensPerSecond;
  final String? errorMessage;

  AIEngineStatus copyWith({
    AIProviderType? activeProvider,
    bool? isConnected,
    bool? isProcessing,
    int? latencyMs,
    double? tokensPerSecond,
    String? errorMessage,
  }) {
    return AIEngineStatus(
      activeProvider: activeProvider ?? this.activeProvider,
      isConnected: isConnected ?? this.isConnected,
      isProcessing: isProcessing ?? this.isProcessing,
      latencyMs: latencyMs ?? this.latencyMs,
      tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Chat message model
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.provider,
    this.latencyMs,
    this.tokensUsed,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final AIProviderType? provider;
  final int? latencyMs;
  final int? tokensUsed;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? timestamp,
    AIProviderType? provider,
    int? latencyMs,
    int? tokensUsed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      provider: provider ?? this.provider,
      latencyMs: latencyMs ?? this.latencyMs,
      tokensUsed: tokensUsed ?? this.tokensUsed,
    );
  }
}

enum ChatRole { user, assistant, system }

/// Notifier for managing chat messages
class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcome = ChatMessage(
      id: 'welcome',
      role: ChatRole.assistant,
      content: 'E.D.I.T.H. systems online. How can I assist you today?',
      timestamp: DateTime.now(),
      provider: AIProviderType.mock,
    );
    state = [welcome];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void replaceMessage(String id, ChatMessage newMessage) {
    final index = state.indexWhere((m) => m.id == id);
    if (index != -1) {
      final updated = [...state];
      updated[index] = newMessage;
      state = updated;
    }
  }

  void updateLastMessage(ChatMessage message) {
    if (state.isEmpty) return;
    final updated = [...state];
    updated[updated.length - 1] = message;
    state = updated;
  }

  void clearMessages() {
    state = [];
    _addWelcomeMessage();
  }
}

/// Notifier for AI provider configuration
class AIProviderConfigNotifier extends StateNotifier<Map<AIProviderType, AIProviderConfig>> {
  AIProviderConfigNotifier() : super({
    for (final type in AIProviderType.values)
      type: AIProviderConfig(type: type, enabled: type == AIProviderType.mock),
  }) {
    state[AIProviderType.mock] = state[AIProviderType.mock]!.copyWith(enabled: true);
  }

  void updateConfig(AIProviderType type, AIProviderConfig config) {
    state = {...state, type: config};
  }

  void toggleProvider(AIProviderType type) {
    final current = state[type]!;
    state = {...state, type: current.copyWith(enabled: !current.enabled)};
  }

  void setActiveProvider(AIProviderType type) {
    for (final key in state.keys) {
      state[key] = state[key]!.copyWith(enabled: key == type);
    }
    state = {...state};
  }
}

/// Notifier for AI engine status
class AIEngineStatusNotifier extends StateNotifier<AIEngineStatus> {
  final Ref _ref;
  Timer? _simulationTimer;
  final _random = Random();

  AIEngineStatusNotifier(this._ref) : super(const AIEngineStatus()) {
    _startSimulation();
  }

  void _startSimulation() {
    _ref.listen(simulationConfigProvider, (prev, next) {
      if (next.simulateAIEngine && next.enabled) {
        _simulationTimer?.cancel();
        _simulationTimer = Timer.periodic(
          Duration(milliseconds: next.updateIntervalMs),
          (_) => _simulateEngineUpdate(),
        );
      } else {
        _simulationTimer?.cancel();
        _simulationTimer = null;
        state = state.copyWith(isConnected: false, isProcessing: false);
      }
    });

    // Initial check
    final config = _ref.read(simulationConfigProvider);
    if (config.simulateAIEngine && config.enabled) {
      _simulateEngineUpdate();
    }
  }

  void _simulateEngineUpdate() {
    state = state.copyWith(
      isConnected: true,
      latencyMs: 50 + _random.nextInt(100),
      tokensPerSecond: 20.0 + _random.nextDouble() * 30,
    );
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void setActiveProvider(AIProviderType provider) {
    state = state.copyWith(activeProvider: provider);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

/// Mock AI response generator
class MockAIProvider {
  static final _responses = [
    'I understand. Let me analyze that for you.',
    'Processing request... Accessing E.D.I.T.H. knowledge base.',
    'Affirmative. Initiating protocol.',
    'Scan complete. No anomalies detected.',
    'I\'ve retrieved the relevant data. Here\'s what I found:',
    'Calculating optimal response... Done.',
    'Security protocols engaged. Your request has been logged.',
    'Connecting to satellite uplink... Connection established.',
    'Threat assessment: Negative. Environment secure.',
    'System diagnostics nominal. All subsystems operational.',
    'Query processed. Would you like me to elaborate?',
    'Executing command sequence... Complete.',
  ];

  static final _random = Random();

  static String generateResponse(String input) {
    // Simple keyword-based responses
    final lower = input.toLowerCase();

    if (lower.contains('status') || lower.contains('system')) {
      return 'All systems nominal. Battery: 87%. Connectivity: Secure. Vision: Active. Protection: Standby.';
    }
    if (lower.contains('threat') || lower.contains('danger') || lower.contains('alert')) {
      return 'Threat assessment initiated. Scanning sectors... No immediate threats detected. Perimeter secure.';
    }
    if (lower.contains('vision') || lower.contains('camera') || lower.contains('see')) {
      return 'Vision system online. Object detection: 3 targets tracked. HUD overlay: Active. Crosshair: Calibrated.';
    }
    if (lower.contains('protect') || lower.contains('shield') || lower.contains('defend')) {
      return 'Protection protocols engaged. Body sectors monitored. Kinetic barrier: Ready. EMP hardening: Active.';
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return 'Hello. E.D.I.T.H. at your service. How may I assist?';
    }
    if (lower.contains('help')) {
      return 'Available commands: System status, threat scan, vision analysis, protection mode, settings. What do you need?';
    }

    return _responses[_random.nextInt(_responses.length)];
  }

  static Future<ChatMessage> generateMockResponse(ChatMessage userMessage) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
    final response = generateResponse(userMessage.content);
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: response,
      timestamp: DateTime.now(),
      provider: AIProviderType.mock,
      latencyMs: 300 + _random.nextInt(500),
      tokensUsed: 20 + _random.nextInt(50),
    );
  }
}

/// Providers
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

final aiProviderConfigProvider = StateNotifierProvider<AIProviderConfigNotifier, Map<AIProviderType, AIProviderConfig>>((ref) {
  return AIProviderConfigNotifier();
});

final aiEngineStatusProvider = StateNotifierProvider<AIEngineStatusNotifier, AIEngineStatus>((ref) {
  return AIEngineStatusNotifier(ref);
});

/// Active provider (convenience)
final activeAIProviderProvider = Provider<AIProviderType>((ref) {
  final configs = ref.watch(aiProviderConfigProvider);
  return configs.entries.firstWhere((e) => e.value.enabled).key;
});

/// Mock AI provider instance
final mockAIProviderProvider = Provider<MockAIProvider>((ref) => MockAIProvider());