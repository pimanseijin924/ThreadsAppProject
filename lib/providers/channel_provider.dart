// providers/channels_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel_model.dart';

final channelListProvider = StreamProvider<List<Channel>>((ref) {
  return FirebaseFirestore.instance
      .collection('channels')
      .orderBy('preId', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList(),
      );
});
