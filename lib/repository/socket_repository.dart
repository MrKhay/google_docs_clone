import 'package:google_docs_clone/client/socket_client.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

 // called to join room
  void joinRoom(String documentId) {
    _socketClient.emit(kJoin, documentId);
  }

// called when typing
  void typing(Map<String, dynamic> data) {
    _socketClient.emit(kTyping, data);
  }

 // call when change in document content
  void changeListener(Function(Map<String, dynamic>) func) {
    _socketClient.on(kChanges, (data) => func(data));
  }

// call to save document
  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit(kSave, data);
  }

// called to get updated document title
  void updatedDocumentTitle(Function(Map<String, dynamic>) func) {
    _socketClient.on(kUpdatedTitle, (data) => func(data));
  }

// called when updating document title
  void updatingTitle(Map<String, dynamic> data) {
    _socketClient.emit(kUpdatingTitle, data);
  }

// called when living room
  void existingRoom(Map<String, dynamic> data) {
    _socketClient.emit(kLivingRoom, data);
  }
}
