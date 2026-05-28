import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/chat/chat_cubit.dart';
import '../../../cubit/chat/chat_state.dart';
import '../../profile/ui/widget/user_image.dart';

class UsersListView extends StatefulWidget {
  final ChatState state;

  const UsersListView({Key? key, required this.state}) : super(key: key);

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  // int? selectedUserId;
  late ScrollController _scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.isWide) {
        _updateSelectedUser();
        context.read<ChatCubit>().setCurrentChat(widget.state.chats![0]);
      }
    });
  }

  @override
  void didUpdateWidget(UsersListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.users!.length != oldWidget.state.users!.length) {
      _updateSelectedUser();
    }
  }

  void _updateSelectedUser() {
    if (widget.state.users != null && widget.state.users!.isNotEmpty) {
      // setState(() {
      //   selectedUserId = int.parse(widget.state.users!.first.id);
      // });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatCubit>().getChatDetailsByParticipiant(
            int.parse(widget.state.users!.first.id), 1);
        context.read<ChatCubit>().setCurrentParticipant(widget.state.users![0]);
      });
    }
    // else {
    //   setState(() {
    //     selectedUserId = null;
    //   });
    // }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadMoreUsers() async {
    if (isLoading || widget.state.usersPagination!.links.next == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await context.read<ChatCubit>().loadUsers(
          widget.state.usersPagination!.meta.currentPage + 1,
          context.getCurrentUser!.companyId!,
          10);
    } catch (e) {
      debugPrint("⚠️ Greška pri učitavanju korisnika: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  final TextEditingController _searchController = TextEditingController();
  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return widget.state.users == null || widget.state.users!.isEmpty
        ? Center(
            child: Text(
              'No users found',
              style:
                  context.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          )
        : Column(children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ChatCubit>().loadUsers(
                                  1, 20, context.getCurrentUser!.companyId!);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    context
                        .read<ChatCubit>()
                        .loadUsers(1, 20, context.getCurrentUser!.companyId!);
                  },
                )),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.state.users!.length +
                    ((isLoading && widget.state.pagination?.nextPageUrl != null)
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index < widget.state.users!.length) {
                    var user = widget.state.users![index];
                    int userId = int.parse(user.id);
                    bool isSelected = userId ==
                        int.parse(widget.state.currentParticipant?.id ?? "-1");

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          // setState(() {
                          //   selectedUserId = userId;
                          // });
                          await context
                              .read<ChatCubit>()
                              .getChatDetailsByParticipiant(userId, 1);
                          await context
                              .read<ChatCubit>()
                              .setCurrentParticipant(user);
                          print('userEmail: ${user.email}');
                        },
                        child: Container(
                          color: isSelected ? Colors.blue[100] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Stack(
                                  children: [
                                    UserImage.medium([user.getUserImageDTO()]),
                                    Visibility(
                                      visible: user.online,
                                      child: Positioned(
                                        bottom: 2,
                                        right: 4,
                                        child: ClipOval(
                                          child: Container(
                                            width: 10.0,
                                            height: 10.0,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.titleMedium,
                                    ),
                                  ],
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
          ]);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
