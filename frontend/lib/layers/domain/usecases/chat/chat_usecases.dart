import 'package:cinteraction_vc/layers/domain/usecases/chat/add_user_to_group.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/delete_chat.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/delete_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/download_media.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/edit_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details_by_participiant.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chats_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_messages.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_pagination_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_participants.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_users.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_users_pagination_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/leave_room.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/load_chats.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/load_users.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/message_seen.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/remove_user_from_group.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_chat_message_stream.dart';

import 'package:cinteraction_vc/layers/domain/usecases/chat/send_file.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_chat.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_participant.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_user_status.dart';

import '../../repos/chat_repo.dart';
import 'chat_initialize.dart';
import 'choose_file.dart';

class ChatUseCases {
  final ChatRepo repo;

  ChatUseCases({required this.repo})
      : chatInitialize = ChatInitialize(repo: repo),
        sendMessage = SendMessage(repo: repo),
        getParticipantsStream = GetParticipantsStream(repo: repo),
        getMessageStream = GetMessagesStream(repo: repo),
        setCurrentParticipant = SetCurrentParticipant(repo: repo),
        messageSeen = MessageSeen(repo: repo),
        getUsersStream = GetUsersStream(repo: repo),
        sendFile = SendFile(repo: repo),
        chooseFile = ChooseFile(repo: repo),
        getChatsStream = GetChatsStream(repo: repo),
        loadChats = LoadChats(repo: repo),
        loadUsers = LoadUsers(repo: repo),
        setCurrentChat = SetCurrentChat(repo: repo),
        getChatDetails = GetChatDetails(repo: repo),
        getChatDetailsByParticipiant = GetChatDetailsByParticipiant(repo: repo),
        getChatDetailsStream = GetChatDetailsStream(repo: repo),
        getPaginationStream = GetPaginationStream(repo: repo),
        getUsersPaginationStream = GetUsersPaginationStream(repo: repo),
        sendMessageToChatStream = SendMessageToChatStream(repo: repo),
        chatDeleteMessage = DeleteMessage(repo: repo),
        chatEditMessage = EditMessage(repo: repo),
        addUserToGroup = AddUserToGroup(repo: repo),
        removeUserFromGroup = RemoveUserFromGroup(repo: repo),
        deleteChat = DeleteChat(repo: repo),
        downloadMedia = DownloadMedia(repo: repo),
        leaveRoom = LeaveRoom(repo: repo),
        setUserStatus = SetUserStatus(repo: repo);

  ChatInitialize chatInitialize;
  SendMessage sendMessage;
  GetParticipantsStream getParticipantsStream;
  GetMessagesStream getMessageStream;
  SetCurrentParticipant setCurrentParticipant;
  MessageSeen messageSeen;
  GetUsersStream getUsersStream;
  SendFile sendFile;
  ChooseFile chooseFile;
  GetChatsStream getChatsStream;
  SetCurrentChat setCurrentChat;
  GetChatDetails getChatDetails;
  GetChatDetailsStream getChatDetailsStream;
  SendMessageToChatStream sendMessageToChatStream;
  DeleteMessage chatDeleteMessage;
  EditMessage chatEditMessage;
  GetChatDetailsByParticipiant getChatDetailsByParticipiant;
  RemoveUserFromGroup removeUserFromGroup;
  AddUserToGroup addUserToGroup;
  DeleteChat deleteChat;
  LoadChats loadChats;
  LoadUsers loadUsers;
  GetPaginationStream getPaginationStream;
  GetUsersPaginationStream getUsersPaginationStream;
  DownloadMedia downloadMedia;
  LeaveRoom leaveRoom;
  SetUserStatus setUserStatus;
}
