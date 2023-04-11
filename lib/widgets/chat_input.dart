import 'package:flutter/material.dart';
import 'package:gpt_chain/chains/single_chain.dart';
import 'package:provider/provider.dart';

class ChatTextInput extends StatefulWidget {
  const ChatTextInput({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatTextInput> createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: Theme.of(context).primaryColor,
              maxLines: null,
              focusNode: _focusNode,
              controller: _controller,
              decoration: InputDecoration(
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SendButton(
                      onSend: _sendMessage,
                      focusNode: _focusNode,
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                hintText: "Say hi to ChatGPT",
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    context.read<SingleChain>().run(_controller.text);
    _controller.clear();
    _focusNode.unfocus();
  }
}

class SendButton extends StatefulWidget {
  final VoidCallback? onSend;
  final FocusNode focusNode;
  const SendButton({
    super.key,
    this.onSend,
    required this.focusNode,
  });

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  bool _enabled = false;

  SingleChain? _chain;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_listen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chain = context.watch<SingleChain>();

    // if (_chain != chain) {
    //   _chain?.removeListener(_listen);
    //   _chain = chain;
    //   _chain?.addListener(_listen);
    // }
  }

  void _listen() {
    setState(() {
      _enabled = widget.focusNode.hasFocus && !(_chain?.running ?? false);
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chain!.running) {
      _enabled = false;
    }

    return IconButton(
      onPressed: _enabled ? widget.onSend : null,
      icon: _enabled
          ? Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                size: 20,
                color: Colors.white,
              ),
            )
          : (_chain!.running
              ? const CircularProgressIndicator.adaptive()
              : Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    size: 20,
                    color: Colors.white,
                  ),
                )),
    );
  }
}
