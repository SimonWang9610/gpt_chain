import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_chain/messages/history.dart';
import 'package:gpt_chain/messages/system.dart';
import 'package:gpt_chain/tools/api_tool.dart';
import 'package:gpt_chain/tools/duck_duck_go_search.dart';
import 'package:gpt_chain/tools/google_search.dart';
import 'package:gpt_chain/tools/search_tool.dart';
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
  final ajaxWeaver = const AjaxWeaverTool();

  final googleSearch = const GoogleSearch(
    authentication: GoogleSearchAuthentication(
      cx: googleCx,
      key: googleSearchKey,
    ),
  );

  final duckSearch = const DuckDuckGoSearch();

  late final SystemContext system = SystemContext(
    tools: [ajaxWeaver, googleSearch, duckSearch],
    role:
        'You are a auto search engine, you can help users to search information online or retrieve information from AjaxWeaver database.',
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

class AjaxWeaverTool extends SearchTool {
  const AjaxWeaverTool({
    super.description =
        'useful for querying employees\' information in AjaxWeaver Inc.',
    super.name = 'AjaxWeaver Database',
    super.endpoint = '127.0.0.1:3000',
    super.method = 'GET',
    super.path = '/profile',
    super.headers = const {
      'Content-Type': 'application/json',
    },
    super.useHttps = false,
  });

  @override
  List<dynamic> parseSearchResults(String body) {
    final data = json.decode(body) as Map<String, dynamic>;

    return [data];
  }
}
