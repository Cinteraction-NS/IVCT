
import '../../entities/chat_message.dart';
import '../../repos/conference_repo.dart';

class ConferenceMessageStream {

  ConferenceMessageStream({required  this.repo});

  final ConferenceRepo repo;


  Stream<List<ChatMessage>> call() {
    return repo.getConferenceMessagesStream();
  }
}
