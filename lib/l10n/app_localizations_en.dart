// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wathiq';

  @override
  String get welcomeMessage => 'Welcome to Wathiq';

  @override
  String get welcomeSubtitle => 'Borrow and lend with confidence using your social connections.';

  @override
  String get requestLoanButton => 'Request a Loan';

  @override
  String get lendToSomeoneButton => 'Lend to Someone';

  @override
  String get communityTrustStatistics => 'Community Trust Statistics';

  @override
  String get loansFunded => 'Loans Funded';

  @override
  String get repaymentRate => 'Repayment Rate';

  @override
  String get totalLent => 'Total Lent';

  @override
  String get howWathiqWorks => 'How Wathiq Works';

  @override
  String get step1Title => 'Request a Loan';

  @override
  String get step1Description => 'Add 1–3 trusted guarantors from your network.';

  @override
  String get step2Title => 'Guarantor Confirmation';

  @override
  String get step2Description => 'They confirm your request; trust builds.';

  @override
  String get step3Title => 'Get Funded';

  @override
  String get step3Description => 'Community lenders review and fund your loan.';

  @override
  String get whyChooseWathiq => 'Why Choose Wathiq?';

  @override
  String get communityTrustTitle => 'Community Trust';

  @override
  String get communityTrustDescription => 'Leverage your social connections as guarantors.';

  @override
  String get shariaCompliantTitle => 'Sharia Compliant';

  @override
  String get shariaCompliantDescription => 'Interest-free lending (Kafala & Qard Hasan).';

  @override
  String get securePrivateTitle => 'Secure & Private';

  @override
  String get securePrivateDescription => 'Transactions are kept safe and private.';

  @override
  String get myDashboard => 'My Dashboard';

  @override
  String get yourFinancialOverview => 'Your Financial Overview';

  @override
  String get trustScore => 'Trust Score';

  @override
  String get borrowed => 'Borrowed';

  @override
  String get lent => 'Lent';

  @override
  String get guarantees => 'Guarantees';

  @override
  String get borrowedTab => 'Borrowed';

  @override
  String get lentTab => 'Lent';

  @override
  String get guarantorTab => 'Guarantor';

  @override
  String get noBorrowedLoans => 'No borrowed loans';

  @override
  String get borrowingHistoryWillAppearHere => 'Your borrowing history will appear here';

  @override
  String get noLentLoans => 'No lent loans';

  @override
  String get lendingHistoryWillAppearHere => 'Your lending history will appear here';

  @override
  String get noGuarantorRoles => 'No guarantor roles';

  @override
  String get guaranteedLoansWillAppearHere => 'Loans you\'ve guaranteed will appear here';

  @override
  String get loanRequests => 'Loan Requests';

  @override
  String get sortBy => 'Sort by';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get amountHigh => 'Amount (High)';

  @override
  String get amountLow => 'Amount (Low)';

  @override
  String get trustScoreSort => 'Trust Score';

  @override
  String get amount => 'Amount';

  @override
  String get allAmounts => 'All amounts';

  @override
  String get under1000 => 'Under 1,000';

  @override
  String get range1000to5000 => '1,000 - 5,000';

  @override
  String get over5000 => 'Over 5,000';

  @override
  String get noLoanRequests => 'No loan requests';

  @override
  String get checkBackLaterForNewOpportunities => 'Check back later for new lending opportunities';

  @override
  String get viewDetails => 'View Details';

  @override
  String get fund => 'Fund';

  @override
  String get guarantorRequests => 'Guarantor Requests';

  @override
  String get pendingConfirmation => 'Pending Confirmation';

  @override
  String get noPendingGuarantorRequests => 'No pending guarantor requests.';

  @override
  String get confirmedGuarantees => 'Confirmed Guarantees';

  @override
  String get noConfirmedGuarantees => 'No confirmed guarantees.';

  @override
  String get decline => 'Decline';

  @override
  String get confirm => 'Confirm';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get areYouSureYouWantToLogout => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Login';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get splashScreen => 'Splash Screen';

  @override
  String get loading => 'Loading...';

  @override
  String get loanDetails => 'Loan Details';

  @override
  String get dueDate => 'Due Date';

  @override
  String get category => 'Category';

  @override
  String get reason => 'Reason';

  @override
  String get guarantors => 'Guarantors';

  @override
  String get noGuarantorsForThisLoanYet => 'No guarantors for this loan yet.';

  @override
  String get fundLoan => 'Fund Loan';

  @override
  String get confirmFunding => 'Confirm Funding';

  @override
  String areYouSureYouWantToFundThisLoan(Object amount, Object borrowerUsername, Object currency) {
    return 'Are you sure you want to fund this loan of $amount $currency for @$borrowerUsername?';
  }

  @override
  String get confirmFund => 'Confirm Fund';

  @override
  String get declining => 'Declining...';

  @override
  String get confirming => 'Confirming...';

  @override
  String get guaranteedAmount => 'Guaranteed Amount';

  @override
  String get repaid => 'Repaid';

  @override
  String get requestALoan => 'Request a Loan';

  @override
  String get loanAmount => 'Loan Amount';

  @override
  String get currency => 'Currency';

  @override
  String get loanReason => 'Loan Reason';

  @override
  String get selectGuarantors => 'Select Guarantors';

  @override
  String get addGuarantor => 'Add Guarantor';

  @override
  String get submitLoanRequest => 'Submit Loan Request';

  @override
  String get searchUsers => 'Search Users';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get circles => 'Circles';

  @override
  String get createCircle => 'Create Circle';

  @override
  String get circleName => 'Circle Name';

  @override
  String get circleDescription => 'Circle Description';

  @override
  String get addMembers => 'Add Members';

  @override
  String get noCirclesYet => 'No circles yet.';

  @override
  String get createYourFirstCircle => 'Create your first circle to manage trusted groups.';

  @override
  String get members => 'Members';

  @override
  String get joinCircle => 'Join Circle';

  @override
  String get leaveCircle => 'Leave Circle';

  @override
  String get manageMembers => 'Manage Members';

  @override
  String get circleDetails => 'Circle Details';

  @override
  String get circleId => 'Circle ID';

  @override
  String get copyId => 'Copy ID';

  @override
  String get joinCircleByEnteringId => 'Join a circle by entering its ID';

  @override
  String get enterCircleId => 'Enter Circle ID';

  @override
  String get join => 'Join';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loanFundedSuccessfully => 'Loan funded successfully!';

  @override
  String failedToFundLoan(Object error) {
    return 'Failed to fund loan: $error';
  }

  @override
  String get guarantorRequestConfirmedSuccessfully => 'Guarantor request confirmed successfully!';

  @override
  String get guarantorRequestDeclinedSuccessfully => 'Guarantor request declined successfully!';

  @override
  String failedToUpdateGuarantorRequest(Object error) {
    return 'Failed to update guarantor request: $error';
  }

  @override
  String get loanRequestSubmittedSuccessfully => 'Loan request submitted successfully!';

  @override
  String failedToSubmitLoanRequest(Object error) {
    return 'Failed to submit loan request: $error';
  }

  @override
  String get circleCreatedSuccessfully => 'Circle created successfully!';

  @override
  String failedToCreateCircle(Object error) {
    return 'Failed to create circle: $error';
  }

  @override
  String get joinedCircleSuccessfully => 'Joined circle successfully!';

  @override
  String failedToJoinCircle(Object error) {
    return 'Failed to join circle: $error';
  }

  @override
  String get leftCircleSuccessfully => 'Left circle successfully!';

  @override
  String failedToLeaveCircle(Object error) {
    return 'Failed to leave circle: $error';
  }

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get passwordResetEmailSent => 'Password reset email sent!';

  @override
  String failedToSendPasswordResetEmail(Object error) {
    return 'Failed to send password reset email: $error';
  }

  @override
  String get youMustBeLoggedInToFundALoan => 'You must be logged in to fund a loan';

  @override
  String get errorLoadingLoanDetails => 'Error loading loan details';

  @override
  String get errorLoadingGuarantor => 'Error loading guarantor';

  @override
  String get pleaseLogInToViewYourDashboard => 'Please log in to view your dashboard.';

  @override
  String get pleaseLogInToViewGuarantorRequests => 'Please log in to view guarantor requests.';

  @override
  String get errorLoadingCircleDetails => 'Error loading circle details';

  @override
  String get errorLoadingMembers => 'Error loading members';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get errorLoadingUserStats => 'Error loading user stats';

  @override
  String get errorLoadingLoans => 'Error loading loans';

  @override
  String get errorLoadingGuarantorRequests => 'Error loading guarantor requests';

  @override
  String get errorLoadingCircles => 'Error loading circles';

  @override
  String get errorLoadingGlobalLoanStats => 'Error loading global loan stats';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get errorLoadingAuthService => 'Error loading authentication service';

  @override
  String get errorLoadingUserService => 'Error loading user service';

  @override
  String get errorLoadingLoanService => 'Error loading loan service';

  @override
  String get errorLoadingCircleService => 'Error loading circle service';

  @override
  String get errorLoadingGuarantorService => 'Error loading guarantor service';

  @override
  String get errorLoadingFirebaseService => 'Error loading Firebase service';

  @override
  String get errorLoadingTheme => 'Error loading theme';

  @override
  String get errorLoadingWidgets => 'Error loading widgets';

  @override
  String get errorLoadingModels => 'Error loading models';

  @override
  String get errorLoadingScreens => 'Error loading screens';

  @override
  String get errorLoadingCore => 'Error loading core';

  @override
  String get errorLoadingApp => 'Error loading app';

  @override
  String get errorLoadingUnknown => 'An unknown error occurred.';
}
