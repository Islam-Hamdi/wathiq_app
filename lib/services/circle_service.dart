import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import 'firebase_service.dart';

class CircleService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final CollectionReference _circlesCollection = FirebaseService.instance.circlesCollection;
  final CollectionReference _usersCollection = FirebaseService.instance.usersCollection;

  // Create a new circle
  Future<void> createCircle(CircleModel circle) async {
    try {
      await _circlesCollection.doc(circle.id).set(circle.toMap());
      // Update creator's circlesJoined count
      await _usersCollection.doc(circle.creatorId).update({
        'circlesJoined': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error creating circle: $e');
      throw Exception('Failed to create circle: $e');
    }
  }

  // Get a circle by ID
  Stream<CircleModel?> getCircleStream(String circleId) {
    return _circlesCollection.doc(circleId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return CircleModel.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  // Get all circles a user is a member of
  Stream<List<CircleModel>> getUserCirclesStream(String userId) {
    return _circlesCollection
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Join a circle
  Future<void> joinCircle(String circleId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference circleRef = _circlesCollection.doc(circleId);
        DocumentSnapshot circleSnapshot = await transaction.get(circleRef);

        if (!circleSnapshot.exists) {
          throw Exception('Circle not found');
        }

        CircleModel circle = CircleModel.fromMap(circleSnapshot.data() as Map<String, dynamic>);

        if (circle.members.contains(userId)) {
          throw Exception('User is already a member of this circle');
        }

        // Add user to members list
        circle = circle.copyWith(members: [...circle.members, userId]);
        transaction.update(circleRef, {'members': FieldValue.arrayUnion([userId])});

        // Update user's circlesJoined count
        await _usersCollection.doc(userId).update({
          'circlesJoined': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('Error joining circle: $e');
      throw Exception('Failed to join circle: $e');
    }
  }

  // Leave a circle
  Future<void> leaveCircle(String circleId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference circleRef = _circlesCollection.doc(circleId);
        DocumentSnapshot circleSnapshot = await transaction.get(circleRef);

        if (!circleSnapshot.exists) {
          throw Exception('Circle not found');
        }

        CircleModel circle = CircleModel.fromMap(circleSnapshot.data() as Map<String, dynamic>);

        if (!circle.members.contains(userId)) {
          throw Exception('User is not a member of this circle');
        }

        // Remove user from members list
        circle = circle.copyWith(members: circle.members.where((id) => id != userId).toList());
        transaction.update(circleRef, {'members': FieldValue.arrayRemove([userId])});

        // Update user's circlesJoined count
        await _usersCollection.doc(userId).update({
          'circlesJoined': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      print('Error leaving circle: $e');
      throw Exception('Failed to leave circle: $e');
    }
  }

  // Search circles by name or description
  Stream<List<CircleModel>> searchCircles(String query) {
    if (query.isEmpty) return Stream.value([]);
    return _circlesCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get recommended circles (e.g., based on common members or interests)
  Stream<List<CircleModel>> getRecommendedCircles(String userId) {
    // This is a placeholder. Real recommendation logic would be more complex.
    // For now, it returns circles the user is not a member of.
    return _circlesCollection
        .where('members', isNotEqualTo: userId) // Simple exclusion
        .limit(5) // Limit for performance
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}

