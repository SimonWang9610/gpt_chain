import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_chain/messages/ai.dart';
import 'package:gpt_chain/messages/helper.dart';
import 'package:gpt_chain/messages/history.dart';
import 'package:gpt_chain/messages/human.dart';
import 'package:gpt_chain/messages/system.dart';
import 'package:gpt_chain/utils/utils.dart';
import 'package:toy_gpt/toy_gpt.dart';

import '../tools/base_tool.dart';
import '../messages/base.dart';

class SingleChain with MessageQueue, ChangeNotifier {
  @override
  final HistoryContext history;
  final SystemContext system;
  final String apiKey;

  SingleChain({
    required this.apiKey,
    required this.history,
    required this.system,
    bool? verbose,
  }) : _verbose = verbose ?? true {
    OpenAI.instance.setAuth(apiKey);
  }

  final bool _verbose;

  @override
  bool get verbose => _verbose;

  @override
  List<BaseTool> get tools => system.tools;

  @override
  String get systemContext => '$system';

  bool _running = false;
  bool get running => _running;

  void run(String prompt) {
    final message = HumanMessage(prompt);
    enqueue(message);

    if (_running) {
      return;
    }

    _running = true;
    notifyListeners();
    _run().then((value) {
      _running = false;
      notifyListeners();
    });
  }

  Future<void> _run() async {
    while (_messageQueue.isNotEmpty) {
      final message = dequeue();

      AIMessage? aiMessage;

      try {
        aiMessage = await consume(message);
      } catch (e) {
        Log.e('Error while consuming message: $e');
      }

      if (aiMessage != null) {
        history.add(aiMessage);
        _model.push(aiMessage);
      }
    }

    _current = null;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}

mixin MessageQueue {
  List<BaseTool> get tools;
  bool get verbose;

  final List<HumanMessage> _messageQueue = [];

  final MessageModel _model = MessageModel();

  MessageModel get model => _model;

  HumanMessage? _current;

  void enqueue(HumanMessage message) {
    _messageQueue.add(message);
  }

  HumanMessage dequeue() {
    final msg = _messageQueue.removeAt(0);

    if (!msg.isIntermediate) {
      _current = msg;
      history.add(_current!);
    }

    _model.push(msg);

    return msg;
  }

  HistoryContext get history;

  AIMessage? serializeResponse(CompletionResponse response) {
    final output = response.choices.map((e) => e.body).join();

    Log.d('[original output]: $output');

    final serialized = SerializedMessage.fromOutput(output, tools);

    if (serialized.intermediateMessage != null) {
      enqueue(serialized.intermediateMessage!);
      return null;
    } else {
      return serialized.aiMessage!;
    }
  }

  String get systemContext;

  Future<AIMessage?> consume(HumanMessage message) async {
    final content = await buildPromptFromMessage(message, history.toString());

    // Log.d('[system]: $systemContext');
    Log.d('[content]: $content');

    final response = await CompletionTask.asyncChat(
      messages: [
        {
          'role': 'system',
          'content': systemContext,
        },
        {
          'role': 'user',
          'content': content,
        }
      ],
      params: params,
    ).then((response) {
      return serializeResponse(response);
    });

    return response;
  }

  ChatCompletionParams params = ChatCompletionParams(
    temperature: 1.0,
    maxTokens: 512,
    stops: ["</AI>"],
  );
}

class MessageModel with ChangeNotifier {
  final bool verbose;
  final List<Message> _messages;

  MessageModel({
    this.verbose = true,
  }) : _messages = [];

  void push(Message message) {
    if (message is IntermediateMessage && verbose) {
      _messages.insert(0, message);
    } else {
      _messages.insert(0, message);
    }

    Log.d('[NEW]: $message');

    notifyListeners();
  }

  List<Message> get messages => _messages;

  Message getMessage(int index) => _messages[index];
}
