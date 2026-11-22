import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'backend.dart';

/// پیاده‌سازی Firebase (Authentication + Cloud Firestore).
///
/// ساختار داده:
///   allowed_emails/{email}          فقط توسط مالک از کنسول ساخته می‌شود
///   users/{uid}                     {name, email}
///   chats/{chatId}                  {title, isGroup, memberIds, last*...}
///   chats/{chatId}/messages/{id}    {senderId, text, time, readBy}
class FirebaseBackend implements Backend {
  FirebaseBackend({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  bool get isDemo => false;

  static const String _notFamily = 'این حساب جزو اعضای خانواده نیست';

  Member _member(String id, String name) => Member(id: id, name: name);

  String _fallbackName(User user) {
    final display = user.displayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    final email = user.email ?? '';
    final local = email.split('@').first;
    return local.isEmpty ? 'عضو' : local;
  }

  Future<Member> _ensureProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final name = _fallbackName(user);
      await ref.set(<String, dynamic>{'name': name, 'email': user.email ?? ''});
      return _member(user.uid, name);
    }
    final name = (snap.data()?['name'] as String?) ?? _fallbackName(user);
    return _member(user.uid, name);
  }

  @override
  Stream<Member?> authChanges() async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield null;
        continue;
      }
      try {
        yield await _ensureProfile(user);
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          await _auth.signOut();
          yield null;
        } else {
          // بدون اینترنت: با اطلاعات محلی وارد می‌شویم.
          yield _member(user.uid, _fallbackName(user));
        }
      }
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'ایمیل معتبر نیست';
      case 'user-disabled':
        return 'این حساب غیرفعال شده است';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'ایمیل یا رمز عبور درست نیست';
      case 'too-many-requests':
        return 'تلاش‌های زیاد؛ کمی بعد دوباره امتحان کنید';
      case 'network-request-failed':
        return 'اتصال به اینترنت یا سرور برقرار نشد';
      default:
        return 'ورود انجام نشد';
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await _ensureProfile(user);
      }
    } on FirebaseAuthException catch (e) {
      throw BackendException(_authMessage(e));
    } on FirebaseException catch (e) {
      await _auth.signOut();
      throw BackendException(
        e.code == 'permission-denied'
            ? _notFamily
            : 'اتصال به سرور برقرار نشد',
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<List<Member>> watchMembers() {
    return _db.collection('users').snapshots().map(
          (s) => [
            for (final d in s.docs)
              _member(d.id, (d.data()['name'] as String?) ?? '؟'),
          ],
        );
  }

  ChatInfo _chatFrom(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return ChatInfo(
      id: d.id,
      title: (data['title'] as String?) ?? '',
      isGroup: (data['isGroup'] as bool?) ?? false,
      memberIds: List<String>.from(
          (data['memberIds'] as List<dynamic>?) ?? const <String>[]),
      lastText: (data['lastText'] as String?) ?? '',
      lastTime: (data['lastTime'] as Timestamp?)?.toDate(),
      lastSenderId: (data['lastSenderId'] as String?) ?? '',
      lastReadBy: List<String>.from(
          (data['lastReadBy'] as List<dynamic>?) ?? const <String>[]),
    );
  }

  @override
  Stream<List<ChatInfo>> watchChats(String myId) {
    return _db
        .collection('chats')
        .where('memberIds', arrayContains: myId)
        .snapshots()
        .map((s) => [for (final d in s.docs) _chatFrom(d)]);
  }

  @override
  Stream<List<Message>> watchMessages(String chatId, String myId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
        .snapshots(includeMetadataChanges: true)
        .map((s) {
      return [
        for (final d in s.docs)
          () {
            final data = d.data();
            final sender = (data['senderId'] as String?) ?? '';
            final readBy = List<String>.from(
                (data['readBy'] as List<dynamic>?) ?? const <String>[]);
            final MessageStatus status;
            if (d.metadata.hasPendingWrites) {
              status = MessageStatus.sending;
            } else if (readBy.any((u) => u != sender)) {
              status = MessageStatus.read;
            } else {
              status = MessageStatus.sent;
            }
            return Message(
              id: d.id,
              senderId: sender,
              text: (data['text'] as String?) ?? '',
              time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
              status: status,
              readBy: readBy,
            );
          }(),
      ];
    });
  }

  @override
  Future<void> sendMessage(String chatId, String myId, String text) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _db.batch();
    batch.set(msgRef, <String, dynamic>{
      'senderId': myId,
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'readBy': <String>[myId],
    });
    batch.update(chatRef, <String, dynamic>{
      'lastText': text.length > 200 ? text.substring(0, 200) : text,
      'lastTime': FieldValue.serverTimestamp(),
      'lastSenderId': myId,
      'lastReadBy': <String>[myId],
    });
    await batch.commit();
  }

  @override
  Future<void> markRead(
    String chatId,
    String myId,
    List<String> messageIds,
  ) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final batch = _db.batch();
    batch.update(chatRef, <String, dynamic>{
      'lastReadBy': FieldValue.arrayUnion(<String>[myId]),
    });
    for (final id in messageIds.take(400)) {
      batch.update(chatRef.collection('messages').doc(id), <String, dynamic>{
        'readBy': FieldValue.arrayUnion(<String>[myId]),
      });
    }
    await batch.commit();
  }

  @override
  Future<String> createChat({
    required String myId,
    required String title,
    required List<String> memberIds,
    required bool isGroup,
  }) async {
    final ids = <String>{...memberIds, myId}.toList()..sort();
    final DocumentReference<Map<String, dynamic>> ref;
    if (!isGroup && ids.length == 2) {
      ref = _db.collection('chats').doc(ids.join('_'));
      final existing = await ref.get();
      if (existing.exists) return ref.id;
    } else {
      ref = _db.collection('chats').doc();
    }
    await ref.set(<String, dynamic>{
      'title': isGroup ? title : '',
      'isGroup': isGroup,
      'memberIds': ids,
      'createdBy': myId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastText': '',
      'lastSenderId': '',
      'lastReadBy': <String>[],
    });
    return ref.id;
  }
}
