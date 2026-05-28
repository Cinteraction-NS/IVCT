// ignore_for_file: prefer_const_constructors

import 'package:audioplayers/audioplayers.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/core/util/conf.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../cubit/chat/chat_cubit.dart';
import '../../../cubit/chat/chat_state.dart';
import '../../profile/ui/widget/user_image.dart';

class ChatsListView extends StatefulWidget {
  final ChatState state;

  const ChatsListView({Key? key, required this.state}) : super(key: key);

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  // int? selectedChat;
  late ScrollController _scrollController;
  int currentPage = 1;
  final int paginate = 20;
  bool isLoading = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.isWide) {
        _updateSelectedChat();
        context.read<ChatCubit>().setCurrentChat(widget.state.chats![0]);
      }
    });
  }

  @override
  void didUpdateWidget(ChatsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.chats!.length != oldWidget.state.chats!.length) {
      _updateSelectedChat();
    }
  }

  void _updateSelectedChat() {
    if (widget.state.chats != null && widget.state.chats!.isNotEmpty) {
      List<ChatDto> sortedChats = List.from(widget.state.chats!)
        ..sort((a, b) {
          DateTime? aTime = a.lastMessage?.createdAt ?? a.createdAt;
          DateTime? bTime = b.lastMessage?.createdAt ?? b.createdAt;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });

      // setState(() {
      //   selectedChat = sortedChats.first.id;
      // });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatCubit>().setCurrentChat(sortedChats.first);
        context.read<ChatCubit>().getChatDetails(sortedChats.first.id, 1);
      });
    } else {
      // setState(() {
      //   selectedChat = null;
      // });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading) {
      _loadMoreChats();
    }
  }

  Future<void> _loadMoreChats() async {
    if (isLoading || widget.state.pagination?.nextPageUrl == null) {
      // debugPrint("No more pages");
      return;
    }

    setState(() {
      isLoading = true;
      // debugPrint(" Pagination started - isLoading: $isLoading");
    });

    try {
      await context
          .read<ChatCubit>()
          .loadChats(widget.state.pagination!.currentPage + 1, 20);
    } catch (e) {}

    setState(() {
      isLoading = false;
      debugPrint("✅ Pagination finished - isLoading: $isLoading");
    });
  }

  void _deleteChat(int chatId) async {
    await context
        .read<ChatCubit>()
        .deleteChat(chatId, widget.state.chatDetails!.authUser.id);
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateSelectedChat();
    });
  }

  String formatTime(String? dateTime) {
    if (dateTime == null) return "";

    DateTime parsed = DateTime.parse(dateTime);
    DateTime now = DateTime.now();

    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime parsedDate = DateTime(parsed.year, parsed.month, parsed.day);

    if (parsedDate == today) {
      return "${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } else if (parsedDate == yesterday) {
      return "Yesterday";
    } else if (parsed.year == now.year) {
      return "${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.";
    } else {
      return "${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}";
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    List<ChatDto> sortedChats = List.from(widget.state.chats ?? [])
      ..sort((a, b) {
        if (a.haveUnread && !b.haveUnread) return -1;
        if (!a.haveUnread && b.haveUnread) return 1;

        DateTime? aTime = a.lastMessage?.createdAt ?? a.createdAt;
        DateTime? bTime = b.lastMessage?.createdAt ?? b.createdAt;

        return (bTime ?? DateTime(0)).compareTo(aTime ?? DateTime(0));
      });

    return widget.state.chats == null || widget.state.chats!.isEmpty
        ? Center(
            child: Text(
              'You still don\'t have any chats',
              style:
                  context.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ChatCubit>().loadChats(1, 20);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ChatCubit>().loadChats(1, 20, value.trim());
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedChats.length +
                      ((isLoading &&
                              widget.state.pagination?.nextPageUrl != null)
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index < sortedChats.length) {
                      var chat = sortedChats[index];
                      bool isSelected = chat.id == widget.state.currentChat?.id;

                      final allParticipants = [
                        ...?chat.chatParticipants,
                        if (chat.chatGroup && widget.state.chatDetails != null)
                          widget.state.chatDetails!.authUser,
                      ];
                      List<UserImageDto> userImages = allParticipants
                          .map((a) => a.getUserImageDTO())
                          .toList();
                      final unreadChats = sortedChats
                          .where((chat) => chat.haveUnread == true)
                          .toList();

                      print('Unread chats: ${unreadChats.length}');
                      for (var chat in unreadChats) {
                        print('Chat  with unread: $chat');
                      }
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            await context.read<ChatCubit>().chatSeen(chat.id);
                            await context
                                .read<ChatCubit>()
                                .getChatDetails(chat.id, 1);
                            await context
                                .read<ChatCubit>()
                                .setCurrentChat(chat);
                          },
                          child: Slidable(
                            key: Key(chat.id.toString()),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                              dragDismissible: false,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    _showRemoveDialog(
                                        chat.id, context, _deleteChat);
                                  },
                                  backgroundColor: ColorConstants.kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue[100]
                                    : Colors.white,
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      UserImage.medium(userImages),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chat.getChatName(),
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              chat.lastMessage?.message
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? chat.lastMessage!.message!
                                                  : (chat.lastMessage
                                                                  ?.filePath !=
                                                              null &&
                                                          chat
                                                              .lastMessage!
                                                              .filePath!
                                                              .isNotEmpty
                                                      ? "File"
                                                      : "No messages"),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: chat.haveUnread == true
                                                    ? Colors.black87
                                                    : Colors.black54,
                                                fontWeight:
                                                    chat.haveUnread == true
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            formatTime(chat
                                                .lastMessage?.createdAt!
                                                .toIso8601String()),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                          if (isSelected)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: ColorConstants
                                                    .kPrimaryColor,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _showRemoveDialog(chat.id,
                                                      context, _deleteChat),
                                            ),
                                          if (chat.haveUnread)
                                            Icon(
                                              Icons.mark_chat_unread,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (chat.isOnline && !chat.chatGroup)
                                    Positioned(
                                      left: 35,
                                      top: 35,
                                      child: ClipOval(
                                        child: Container(
                                          width: 10.0,
                                          height: 10.0,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

void _showRemoveDialog(int chatId, context, Function(int) deleteChat) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Remove Conversation"),
        content: const Text(
          "Are you sure you want to delete this conversation?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              deleteChat(chatId);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}
