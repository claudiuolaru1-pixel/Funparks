import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsService {
  static final _db = FirebaseFirestore.instance;

  /// Firestore doc id for a reviewable item
  static String _docId(String parkId, String itemId) =>
      '${parkId}_$itemId';

  /// Stream of all comments for an item
  static Stream<List<ReviewComment>> commentsStream(
      String parkId, String itemId) {
    return _db
        .collection('reviews')
        .doc(_docId(parkId, itemId))
        .collection('comments')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ReviewComment.fromFirestore(d))
            .toList());
  }

  /// Stream of meta (average + count)
  static Stream<ReviewMeta> metaStream(String parkId, String itemId) {
    return _db
        .collection('reviews')
        .doc(_docId(parkId, itemId))
        .snapshots()
        .map((snap) {
      if (!snap.exists) return ReviewMeta(average: 0, count: 0);
      final data = snap.data() as Map<String, dynamic>;
      return ReviewMeta(
        average: (data['average'] as num?)?.toDouble() ?? 0,
        count: (data['count'] as num?)?.toInt() ?? 0,
      );
    });
  }

  /// Post or update a review (recalculates average atomically)
  static Future<void> postReview({
    required String parkId,
    required String itemId,
    required double rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    final docId = _docId(parkId, itemId);
    final reviewDoc = _db.collection('reviews').doc(docId);
    final commentDoc =
        reviewDoc.collection('comments').doc(user.uid);

    await _db.runTransaction((tx) async {
      final existingSnap = await tx.get(commentDoc);
      final metaSnap = await tx.get(reviewDoc);

      double oldRating = 0;
      bool isUpdate = false;
      if (existingSnap.exists) {
        oldRating =
            (existingSnap.data()?['rating'] as num?)?.toDouble() ??
                0;
        isUpdate = true;
      }

      int count =
          (metaSnap.data()?['count'] as num?)?.toInt() ?? 0;
      double sum =
          ((metaSnap.data()?['average'] as num?)?.toDouble() ?? 0) *
              count;

      if (isUpdate) {
        sum = sum - oldRating + rating;
      } else {
        sum = sum + rating;
        count = count + 1;
      }

      final newAverage = count > 0 ? sum / count : 0.0;

      tx.set(commentDoc, {
        'rating': rating,
        'comment': comment,
        'email': user.email ?? 'Anonymous',
        'date': FieldValue.serverTimestamp(),
      });

      tx.set(reviewDoc, {
        'average': newAverage,
        'count': count,
      }, SetOptions(merge: true));
    });
  }

  /// Delete own review
  static Future<void> deleteReview({
    required String parkId,
    required String itemId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = _docId(parkId, itemId);
    final reviewDoc = _db.collection('reviews').doc(docId);
    final commentDoc =
        reviewDoc.collection('comments').doc(user.uid);

    await _db.runTransaction((tx) async {
      final existingSnap = await tx.get(commentDoc);
      if (!existingSnap.exists) return;

      final oldRating =
          (existingSnap.data()?['rating'] as num?)?.toDouble() ?? 0;
      final metaSnap = await tx.get(reviewDoc);
      int count =
          (metaSnap.data()?['count'] as num?)?.toInt() ?? 0;
      double sum =
          ((metaSnap.data()?['average'] as num?)?.toDouble() ?? 0) *
              count;

      sum -= oldRating;
      count = (count - 1).clamp(0, 999999);
      final newAverage = count > 0 ? sum / count : 0.0;

      tx.delete(commentDoc);
      tx.set(reviewDoc, {
        'average': newAverage,
        'count': count,
      }, SetOptions(merge: true));
    });
  }
}

class ReviewMeta {
  final double average;
  final int count;
  const ReviewMeta({required this.average, required this.count});
}

class ReviewComment {
  final String uid;
  final String email;
  final double rating;
  final String comment;
  final DateTime? date;

  const ReviewComment({
    required this.uid,
    required this.email,
    required this.rating,
    required this.comment,
    this.date,
  });

  factory ReviewComment.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ReviewComment(
      uid: doc.id,
      email: d['email']?.toString() ?? 'Anonymous',
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      comment: d['comment']?.toString() ?? '',
      date: (d['date'] as Timestamp?)?.toDate(),
    );
  }
}