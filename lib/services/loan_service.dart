import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import 'firebase_service.dart';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final CollectionReference _loansCollection = FirebaseService.instance.loansCollection;

  // Create a new loan request
  Future<void> createLoanRequest(LoanModel loan) async {
    try {
      await _loansCollection.doc(loan.id).set(loan.toMap());
    } catch (e) {
      print('Error creating loan request: $e');
      throw Exception('Failed to create loan request: $e');
    }
  }

  // Get a loan by ID
  Stream<LoanModel?> getLoanStream(String loanId) {
    return _loansCollection.doc(loanId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return LoanModel.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  // Get all loan requests for a user (borrower or lender)
  Stream<List<LoanModel>> getUserLoansStream(String userId) {
    return _loansCollection
        .where('borrowerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get loans where user is a lender
  Stream<List<LoanModel>> getLentLoansStream(String userId) {
    return _loansCollection
        .where('lenderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update loan status or details
  Future<void> updateLoan(LoanModel loan) async {
    try {
      await _loansCollection.doc(loan.id).update(loan.toMap());
    } catch (e) {
      print('Error updating loan: $e');
      throw Exception('Failed to update loan: $e');
    }
  }

  // Delete a loan request
  Future<void> deleteLoan(String loanId) async {
    try {
      await _loansCollection.doc(loanId).delete();
    } catch (e) {
      print('Error deleting loan: $e');
      throw Exception('Failed to delete loan: $e');
    }
  }

  // Get loans that are open for funding
  Stream<List<LoanModel>> getOpenLoanRequests() {
    return _loansCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Fund a loan
  Future<void> fundLoan(String loanId, String lenderId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference loanRef = _loansCollection.doc(loanId);
        DocumentSnapshot loanSnapshot = await transaction.get(loanRef);

        if (!loanSnapshot.exists) {
          throw Exception('Loan not found');
        }

        LoanModel loan = LoanModel.fromMap(loanSnapshot.data() as Map<String, dynamic>);

        if (loan.status != 'pending') {
          throw Exception('Loan is not available for funding');
        }

        // Update loan with lender and status
        loan = loan.copyWith(lenderId: lenderId, status: 'funded', fundedAt: DateTime.now());
        transaction.update(loanRef, loan.toMap());

        // TODO: Update borrower and lender user stats (e.g., lentAmount, borrowedAmount)
      });
    } catch (e) {
      print('Error funding loan: $e');
      throw Exception('Failed to fund loan: $e');
    }
  }

  // Complete a loan
  Future<void> completeLoan(String loanId) async {
    try {
      await _loansCollection.doc(loanId).update({
        'status': 'completed',
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });
      // TODO: Update trust scores and user stats for borrower and lender
    } catch (e) {
      print('Error completing loan: $e');
      throw Exception('Failed to complete loan: $e');
    }
  }

  // Decline a loan
  Future<void> declineLoan(String loanId) async {
    try {
      await _loansCollection.doc(loanId).update({
        'status': 'declined',
        'declinedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error declining loan: $e');
      throw Exception('Failed to decline loan: $e');
    }
  }
}

