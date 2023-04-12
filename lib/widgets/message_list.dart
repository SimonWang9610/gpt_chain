import 'package:flutter/material.dart';
import 'package:gpt_chain/messages/ai.dart';
import 'package:gpt_chain/messages/human.dart';
import 'package:provider/provider.dart';
import 'package:gpt_chain/chains/single_chain.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  MessageModel? _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final model = context.read<SingleChain>().model;

    if (_model != model) {
      _model?.removeListener(_listen);
      _model = model;
      _model?.addListener(_listen);
    }
  }

  void _listen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _model != null && _model!.messages.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              reverse: true,
              itemCount: _model!.messages.length,
              itemBuilder: (_, index) {
                final message = _model!.getMessage(index);

                if (message is IntermediateMessage) {
                  return IntermediateMessageTile(message: message);
                } else if (message is AIMessage) {
                  return AIMessageTile(message: message);
                } else if (message is HumanMessage) {
                  return HumanMessageTile(message: message);
                } else {
                  throw Exception('Unknown message type');
                }
              },
            ),
          )
        : const Center(
            child: Text('Say something to the bot'),
          );
  }
}

class HumanMessageTile extends StatelessWidget {
  final HumanMessage message;
  const HumanMessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 0.5)),
            child: Text(
              message.content,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          child: Icon(Icons.person),
        )
      ],
    );
  }
}

class AIMessageTile extends StatelessWidget {
  final AIMessage message;
  const AIMessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(
            Icons.settings_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message.content,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class IntermediateMessageTile extends StatelessWidget {
  final IntermediateMessage message;
  const IntermediateMessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Flexible(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.yellow,
                  Colors.blue,
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: RichText(
              text: TextSpan(
                text: 'Using ',
                style: const TextStyle(color: Colors.black),
                children: [
                  WidgetSpan(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(message.tool.name),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '\n\nAction: ${message.content}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
