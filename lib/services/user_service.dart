import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'package:rxdart/rxdart.dart';


class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();
  
  UserService._();

  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by username: $e');
    }
  }

  // Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    try {
      final List<UserModel> users = [];
      
      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final query = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        users.addAll(
          query.docs.map((doc) => UserModel.fromMap(doc.data())).toList(),
        );
      }
      
      return users;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(10)
          .get();
      
      final nameQuery = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();
      
      final Set<String> seenIds = {};
      final List<UserModel> results = [];
      
      // Add username matches first
      for (final doc in usernameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          results.add(UserModel.fromMap(doc.data()));
          seenIds.add(doc.id);
        }
      }
      
      // Add name matches
      for (final doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          results.add(UserModel.fromMap(doc.data()));
          seenIds.add(doc.id);
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Update user trust score
  Future<void> updateTrustScore(String userId, double newScore) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'trustScore': newScore,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update trust score: $e');
    }
  }

  Stream<Map<String, dynamic>> getUserStatsStream(String userId) {
    final loansBorrowed =
        _firestore.collection('loans').where('borrowerId', isEqualTo: userId);
    final loansLent =
        _firestore.collection('loans').where('lenderId', isEqualTo: userId);
    final guarantorRequests = _firestore
        .collection('guarantor_requests')
        .where('guarantorId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed');

    // Combine streams
    return Rx.combineLatest3(
      loansBorrowed.snapshots(),
      loansLent.snapshots(),
      guarantorRequests.snapshots(),
      (QuerySnapshot borrowed, QuerySnapshot lent, QuerySnapshot guarantor) {
        double totalBorrowed = 0.0;
        double totalLent = 0.0;
        int completedLoans = 0;

        for (final doc in borrowed.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalBorrowed += (data['amount'] ?? 0.0).toDouble();
          if (data['status'] == 'completed') completedLoans++;
        }

        for (final doc in lent.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalLent += (data['amount'] ?? 0.0).toDouble();
        }

        return {
          'totalBorrowed': totalBorrowed,
          'totalLent': totalLent,
          'guaranteeCount': guarantor.docs.length,
          'completedLoans': completedLoans,
        };
      },
    );
  }


  // Update KYC status
  Future<void> updateKycStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'kycStatus': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update KYC status: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get loans borrowed
      final borrowedQuery = await _firestore
          .collection('loans')
          .where('borrowerId', isEqualTo: userId)
          .get();
      
      // Get loans lent
      final lentQuery = await _firestore
          .collection('loans')
          .where('lenderId', isEqualTo: userId)
          .get();
      
      // Get guarantor requests
      final guarantorQuery = await _firestore
          .collection('guarantor_requests')
          .where('guarantorId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();
      
      double totalBorrowed = 0.0;
      double totalLent = 0.0;
      int completedLoans = 0;
      
      for (final doc in borrowedQuery.docs) {
        final data = doc.data();
        totalBorrowed += (data['amount'] ?? 0.0).toDouble();
        if (data['status'] == 'completed') completedLoans++;
      }
      
      for (final doc in lentQuery.docs) {
        final data = doc.data();
        totalLent += (data['amount'] ?? 0.0).toDouble();
      }
      
      return {
        'totalBorrowed': totalBorrowed,
        'totalLent': totalLent,
        'guaranteeCount': guarantorQuery.docs.length,
        'completedLoans': completedLoans,
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }
}

