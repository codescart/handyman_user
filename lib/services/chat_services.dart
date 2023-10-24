import 'dart:io';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/model/contact_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/services/base_services.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

FirebaseFirestore fireStore = FirebaseFirestore.instance;
CollectionReference? userRef;
FirebaseStorage storage = FirebaseStorage.instance;

class ChatServices extends BaseService {
  ChatServices() {
    ref = fireStore.collection(MESSAGES_COLLECTION);
    userRef = fireStore.collection(USER_COLLECTION);
  }

  Query fetchChatListQuery({String? userId}) {
    return userRef!.doc(userId).collection(CONTACT_COLLECTION).orderBy("lastMessageTime", descending: true);
  }

  Query fetchChatList({String? userId}) {
    return userRef!;
  }

  Future<void> setUnReadStatusToTrue({required String senderId, required String receiverId, String? documentId}) async {
    chatServices.setUnreadCount(senderId: senderId, receiverId: receiverId, status: 1);
    chatServices.setOnlineCount(senderId: senderId, receiverId: receiverId, status: 1);

    final WriteBatch _batch = fireStore.batch();

    if (!(senderId == appStore.uid.validate())) {
      ref!.doc(receiverId).collection(senderId).where('isMessageRead', isEqualTo: false).get().then((value) {
        value.docs.forEach((element) {
          _batch.update(element.reference, {
            'isMessageRead': true,
          });
        });

        _batch.commit();
      });
    } else {
      ref!.doc(senderId).collection(receiverId).where('isMessageRead', isEqualTo: false).get().then((value) {
        value.docs.forEach((element) {
          _batch.update(element.reference, {
            'isMessageRead': true,
          });
        });
        _batch.commit();
      });
    }
  }

  Future<void> deleteSingleMessage({String? senderId, required String receiverId, String? documentId}) async {
    return ref!.doc(senderId).collection(receiverId).doc(documentId).delete().then((value) {
      log("====================== Message Deleted ======================");
    }).catchError((e) {
      throw language.somethingWentWrong;
    });
  }

  Query chatMessagesWithPagination({required String senderId, required String receiverUserId}) {
    return ref!.doc(senderId).collection(receiverUserId).orderBy("createdAt", descending: true);
  }

  Future<DocumentReference> addMessage(ChatMessageModel data) async {
    var doc = await ref!.doc(data.senderId).collection(data.receiverId!).add(data.toJson());
    doc.update({'uid': doc.id});
    return doc;
  }

  Future<void> addMessageToDb({required DocumentReference senderRef, required ChatMessageModel chatData, required UserData sender, UserData? receiverUser, File? image}) async {
    String imageUrl = '';

    if (image != null) {
      String fileName = basename(image.path);
      Reference storageRef = storage.ref().child("$CHAT_DATA_IMAGES/${getStringAsync(USER_ID)}/$fileName");

      UploadTask uploadTask = storageRef.putFile(image);

      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;

          // fileList.removeWhere((element) => element.id == senderRef.id);
        }).catchError((e) {
          log(e);
        });
      }).catchError((e) {
        log(e);
      });
    }

    updateChatDocument(senderRef, image: image, imageUrl: imageUrl);

    userRef!.doc(chatData.senderId).update({"lastMessageTime": Timestamp.fromDate(chatData.createdAtTime!.toDate()).millisecondsSinceEpoch});
    addToContacts(
      senderId: chatData.senderId,
      receiverId: chatData.receiverId,
      receiverName: receiverUser!.displayName.validate(),
      senderName: sender.displayName.validate(),
    );

    DocumentReference receiverDoc = await ref!.doc(chatData.receiverId).collection(chatData.senderId!).add(chatData.toJson());

    updateChatDocument(receiverDoc, image: image, imageUrl: imageUrl);

    userRef!.doc(chatData.receiverId).update({"lastMessageTime": Timestamp.fromDate(chatData.createdAtTime!.toDate()).millisecondsSinceEpoch});
  }

  DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
    Map<String, dynamic> sendData = {'id': data.id};

    if (image != null) {
      sendData.putIfAbsent('photoUrl', () => imageUrl);
    }
    log(sendData);
    data.update(sendData);

    log("Data $sendData");
    return null;
  }

  addToContacts({String? senderId, String? receiverId, String? senderName, String? receiverName}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime, receiverName: receiverName);
    await addToReceiverContacts(senderId, receiverId, currentTime, senderName: senderName);
  }

  DocumentReference getContactsDocument({String? of, String? forContact}) {
    return userRef!.doc(of).collection(CONTACT_COLLECTION).doc(forContact);
  }

  Future<void> addToSenderContacts(String? senderId, String? receiverId, currentTime, {String? receiverName}) async {
    DocumentSnapshot senderSnapshot = await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      ContactModel receiverContact = ContactModel(uid: receiverId, addedOn: currentTime, searchParam: receiverName.setSearchParam());

      await getContactsDocument(of: senderId, forContact: receiverId).set(receiverContact.toJson());
    }
  }

  Future<void> addToReceiverContacts(String? senderId, String? receiverId, currentTime, {String? senderName}) async {
    DocumentSnapshot receiverSnapshot = await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      ContactModel senderContact = ContactModel(uid: senderId, addedOn: currentTime, searchParam: senderName.setSearchParam());
      await getContactsDocument(of: receiverId, forContact: senderId).set(senderContact.toJson());
    }
  }

  Stream<int> getUnReadCount({required String senderId, required String receiverId, String? documentId}) {
    if (!(senderId == appStore.uid.validate())) {
      return ref!.doc(receiverId).collection(senderId).where('isMessageRead', isEqualTo: false).where('receiverId', isEqualTo: senderId).snapshots().map((event) => event.docs.length).handleError((e) => 0);
    }
    return ref!.doc(senderId).collection(receiverId).where('isMessageRead', isEqualTo: false).where('receiverId', isEqualTo: senderId).snapshots().map((event) => event.docs.length).handleError((e) => 0);
  }

  Stream<QuerySnapshot> fetchLastMessageBetween({required String senderId, required String receiverId}) {
    return ref!.doc(senderId.toString()).collection(receiverId.toString()).orderBy("createdAt", descending: false).snapshots();
  }

  Future<void> clearAllMessages({String? senderId, required String receiverId}) async {
    final WriteBatch _batch = fireStore.batch();

    log("senderId $senderId}");
    log("receiverId $receiverId}");

    ref!.doc(senderId).collection(receiverId).get().then((value) {
      log(value.docs.length);
      value.docs.forEach((document) {
        log(document.reference);
        _batch.delete(document.reference);
      });

      return _batch.commit();
    }).catchError(log);
  }

  Future<void> setUnreadCount({required String receiverId, required String senderId, required int status}) async {
    /// if status is 0 = Unread and 1 = Read.
    getContactsDocument(of: senderId, forContact: receiverId).update({"unReadFromUser": status});
  }

  Future<void> setOnlineCount({required String receiverId, required String senderId, required int status}) async {
    /// if status is 0 = Online and 1 = Offline
    getContactsDocument(of: senderId, forContact: receiverId).update({"isOnline": status});
  }

  Stream<int> getUnreadNewChatCount() {
    return userRef!.doc(appStore.uid).collection(CONTACT_COLLECTION).where('unReadFromUser', isEqualTo: 0).snapshots().map((event) => event.docs.length).handleError((e) => 0);
  }

  Stream<UserData> getReceiverUserIsOnline({required String receiverUserId, required String senderId}) {
    return userRef!.doc(receiverUserId).collection(CONTACT_COLLECTION).doc(senderId).snapshots().map((event) => UserData.fromJson(event.data() as Map<String, dynamic>));
  }
}
