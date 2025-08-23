import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guarantor_model.dart';
import 'firebase_service.dart';

class GuarantorService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final CollectionReference _guarantorRequestsCollection = FirebaseService.instance.guarantorRequestsCollection;

  // Create a new guarantor request
  Future<void> createGuarantorRequest(GuarantorRequestModel request) async {
    try {
      await _guarantorRequestsCollection.doc(request.id).set(request.toMap());
    } catch (e) {
      print('Error creating guarantor request: $e');
      throw Exception('Failed to create guarantor request: $e');
    }
  }

  // Get a guarantor request by ID
  Stream<GuarantorRequestModel?> getGuarantorRequestStream(String requestId) {
    return _guarantorRequestsCollection.doc(requestId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return GuarantorRequestModel.fromMap(
            snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  // Get all guarantor requests for a specific user (as a guarantor)
  Stream<List<GuarantorRequestModel>> getUserGuarantorRequestsStream(
      String guarantorId) {
    return _guarantorRequestsCollection
        .where('guarantorId', isEqualTo: guarantorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GuarantorRequestModel.fromMap(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update guarantor request status
  Future<void> updateGuarantorRequestStatus(String requestId, String status) async {
    try {
      await _guarantorRequestsCollection.doc(requestId).update({
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      // TODO: Update user's guaranteed loans count if status is 'confirmed'
    } catch (e) {
      print('Error updating guarantor request status: $e');
      throw Exception('Failed to update guarantor request status: $e');
    }
  }

  // Delete a guarantor request
  Future<void> deleteGuarantorRequest(String requestId) async {
    try {
      await _guarantorRequestsCollection.doc(requestId).delete();
    } catch (e) {
      print('Error deleting guarantor request: $e');
      throw Exception('Failed to delete guarantor request: $e');
    }
  }
}

