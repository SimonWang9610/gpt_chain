import 'package:flutter/material.dart';
import 'package:gpt_chain/messages/history.dart';
import 'package:gpt_chain/messages/system.dart';
import 'package:gpt_chain/tools/api_tool.dart';
import 'package:gpt_chain/tools/google_search.dart';
import 'package:gpt_chain/widgets/chat_input.dart';
import 'package:gpt_chain/widgets/message_list.dart';
import 'package:provider/provider.dart';
import 'package:gpt_chain/chains/single_chain.dart';

import '../key.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final HistoryContext history = HistoryContext();
  final ApiTool apiTool = const ApiTool(
    name: 'AjaxWeaver Database',
    description: 'Useful for querying employees\' information',
    endpoint: 'http://127.0.0.1:3000/profile',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  );

  final googleSearch = const GoogleSearch(
    cx: 'd4d1702f42b034b9c',
    key: googleSearchKey,
  );

  late final SystemContext system = SystemContext(
    tools: [apiTool, googleSearch],
    role:
        'You are the data administrator for AjaxWeaver Inc. You are responsible for the data, e.g., employee information/occupation, customer information, etc.',
    rules: '''
    1. When you are not sure your answer/thoughts, you should first try to use tools to help you.
    2. If no tools are available, you could request more information from users.
    ''',
  );

  late final SingleChain chain = SingleChain(
    apiKey: apiKey,
    history: history,
    system: system,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjaxWeaver Chatbot'),
      ),
      body: ChangeNotifierProvider.value(
        value: chain,
        child: Column(
          children: const [
            Expanded(
              child: MessageList(),
            ),
            ChatTextInput(),
          ],
        ),
      ),
    );
  }
}
