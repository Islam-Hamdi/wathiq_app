import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wathiq'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Wathiq'**
  String get welcomeMessage;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow and lend with confidence using your social connections.'**
  String get welcomeSubtitle;

  /// No description provided for @requestLoanButton.
  ///
  /// In en, this message translates to:
  /// **'Request a Loan'**
  String get requestLoanButton;

  /// No description provided for @lendToSomeoneButton.
  ///
  /// In en, this message translates to:
  /// **'Lend to Someone'**
  String get lendToSomeoneButton;

  /// No description provided for @communityTrustStatistics.
  ///
  /// In en, this message translates to:
  /// **'Community Trust Statistics'**
  String get communityTrustStatistics;

  /// No description provided for @loansFunded.
  ///
  /// In en, this message translates to:
  /// **'Loans Funded'**
  String get loansFunded;

  /// No description provided for @repaymentRate.
  ///
  /// In en, this message translates to:
  /// **'Repayment Rate'**
  String get repaymentRate;

  /// No description provided for @totalLent.
  ///
  /// In en, this message translates to:
  /// **'Total Lent'**
  String get totalLent;

  /// No description provided for @howWathiqWorks.
  ///
  /// In en, this message translates to:
  /// **'How Wathiq Works'**
  String get howWathiqWorks;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Request a Loan'**
  String get step1Title;

  /// No description provided for @step1Description.
  ///
  /// In en, this message translates to:
  /// **'Add 1–3 trusted guarantors from your network.'**
  String get step1Description;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Guarantor Confirmation'**
  String get step2Title;

  /// No description provided for @step2Description.
  ///
  /// In en, this message translates to:
  /// **'They confirm your request; trust builds.'**
  String get step2Description;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Get Funded'**
  String get step3Title;

  /// No description provided for @step3Description.
  ///
  /// In en, this message translates to:
  /// **'Community lenders review and fund your loan.'**
  String get step3Description;

  /// No description provided for @whyChooseWathiq.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Wathiq?'**
  String get whyChooseWathiq;

  /// No description provided for @communityTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Trust'**
  String get communityTrustTitle;

  /// No description provided for @communityTrustDescription.
  ///
  /// In en, this message translates to:
  /// **'Leverage your social connections as guarantors.'**
  String get communityTrustDescription;

  /// No description provided for @shariaCompliantTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharia Compliant'**
  String get shariaCompliantTitle;

  /// No description provided for @shariaCompliantDescription.
  ///
  /// In en, this message translates to:
  /// **'Interest-free lending (Kafala & Qard Hasan).'**
  String get shariaCompliantDescription;

  /// No description provided for @securePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get securePrivateTitle;

  /// No description provided for @securePrivateDescription.
  ///
  /// In en, this message translates to:
  /// **'Transactions are kept safe and private.'**
  String get securePrivateDescription;

  /// No description provided for @myDashboard.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get myDashboard;

  /// No description provided for @yourFinancialOverview.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Overview'**
  String get yourFinancialOverview;

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get trustScore;

  /// No description provided for @borrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowed;

  /// No description provided for @lent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lent;

  /// No description provided for @guarantees.
  ///
  /// In en, this message translates to:
  /// **'Guarantees'**
  String get guarantees;

  /// No description provided for @borrowedTab.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowedTab;

  /// No description provided for @lentTab.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lentTab;

  /// No description provided for @guarantorTab.
  ///
  /// In en, this message translates to:
  /// **'Guarantor'**
  String get guarantorTab;

  /// No description provided for @noBorrowedLoans.
  ///
  /// In en, this message translates to:
  /// **'No borrowed loans'**
  String get noBorrowedLoans;

  /// No description provided for @borrowingHistoryWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your borrowing history will appear here'**
  String get borrowingHistoryWillAppearHere;

  /// No description provided for @noLentLoans.
  ///
  /// In en, this message translates to:
  /// **'No lent loans'**
  String get noLentLoans;

  /// No description provided for @lendingHistoryWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your lending history will appear here'**
  String get lendingHistoryWillAppearHere;

  /// No description provided for @noGuarantorRoles.
  ///
  /// In en, this message translates to:
  /// **'No guarantor roles'**
  String get noGuarantorRoles;

  /// No description provided for @guaranteedLoansWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Loans you\'ve guaranteed will appear here'**
  String get guaranteedLoansWillAppearHere;

  /// No description provided for @loanRequests.
  ///
  /// In en, this message translates to:
  /// **'Loan Requests'**
  String get loanRequests;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @amountHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount (High)'**
  String get amountHigh;

  /// No description provided for @amountLow.
  ///
  /// In en, this message translates to:
  /// **'Amount (Low)'**
  String get amountLow;

  /// No description provided for @trustScoreSort.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get trustScoreSort;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @allAmounts.
  ///
  /// In en, this message translates to:
  /// **'All amounts'**
  String get allAmounts;

  /// No description provided for @under1000.
  ///
  /// In en, this message translates to:
  /// **'Under 1,000'**
  String get under1000;

  /// No description provided for @range1000to5000.
  ///
  /// In en, this message translates to:
  /// **'1,000 - 5,000'**
  String get range1000to5000;

  /// No description provided for @over5000.
  ///
  /// In en, this message translates to:
  /// **'Over 5,000'**
  String get over5000;

  /// No description provided for @noLoanRequests.
  ///
  /// In en, this message translates to:
  /// **'No loan requests'**
  String get noLoanRequests;

  /// No description provided for @checkBackLaterForNewOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new lending opportunities'**
  String get checkBackLaterForNewOpportunities;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @fund.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get fund;

  /// No description provided for @guarantorRequests.
  ///
  /// In en, this message translates to:
  /// **'Guarantor Requests'**
  String get guarantorRequests;

  /// No description provided for @pendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get pendingConfirmation;

  /// No description provided for @noPendingGuarantorRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending guarantor requests.'**
  String get noPendingGuarantorRequests;

  /// No description provided for @confirmedGuarantees.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Guarantees'**
  String get confirmedGuarantees;

  /// No description provided for @noConfirmedGuarantees.
  ///
  /// In en, this message translates to:
  /// **'No confirmed guarantees.'**
  String get noConfirmedGuarantees;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @splashScreen.
  ///
  /// In en, this message translates to:
  /// **'Splash Screen'**
  String get splashScreen;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @guarantors.
  ///
  /// In en, this message translates to:
  /// **'Guarantors'**
  String get guarantors;

  /// No description provided for @noGuarantorsForThisLoanYet.
  ///
  /// In en, this message translates to:
  /// **'No guarantors for this loan yet.'**
  String get noGuarantorsForThisLoanYet;

  /// No description provided for @fundLoan.
  ///
  /// In en, this message translates to:
  /// **'Fund Loan'**
  String get fundLoan;

  /// No description provided for @confirmFunding.
  ///
  /// In en, this message translates to:
  /// **'Confirm Funding'**
  String get confirmFunding;

  /// No description provided for @areYouSureYouWantToFundThisLoan.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to fund this loan of {amount} {currency} for @{borrowerUsername}?'**
  String areYouSureYouWantToFundThisLoan(Object amount, Object borrowerUsername, Object currency);

  /// No description provided for @confirmFund.
  ///
  /// In en, this message translates to:
  /// **'Confirm Fund'**
  String get confirmFund;

  /// No description provided for @declining.
  ///
  /// In en, this message translates to:
  /// **'Declining...'**
  String get declining;

  /// No description provided for @confirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get confirming;

  /// No description provided for @guaranteedAmount.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed Amount'**
  String get guaranteedAmount;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get repaid;

  /// No description provided for @requestALoan.
  ///
  /// In en, this message translates to:
  /// **'Request a Loan'**
  String get requestALoan;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan Amount'**
  String get loanAmount;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @loanReason.
  ///
  /// In en, this message translates to:
  /// **'Loan Reason'**
  String get loanReason;

  /// No description provided for @selectGuarantors.
  ///
  /// In en, this message translates to:
  /// **'Select Guarantors'**
  String get selectGuarantors;

  /// No description provided for @addGuarantor.
  ///
  /// In en, this message translates to:
  /// **'Add Guarantor'**
  String get addGuarantor;

  /// No description provided for @submitLoanRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Loan Request'**
  String get submitLoanRequest;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @circles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get circles;

  /// No description provided for @createCircle.
  ///
  /// In en, this message translates to:
  /// **'Create Circle'**
  String get createCircle;

  /// No description provided for @circleName.
  ///
  /// In en, this message translates to:
  /// **'Circle Name'**
  String get circleName;

  /// No description provided for @circleDescription.
  ///
  /// In en, this message translates to:
  /// **'Circle Description'**
  String get circleDescription;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembers;

  /// No description provided for @noCirclesYet.
  ///
  /// In en, this message translates to:
  /// **'No circles yet.'**
  String get noCirclesYet;

  /// No description provided for @createYourFirstCircle.
  ///
  /// In en, this message translates to:
  /// **'Create your first circle to manage trusted groups.'**
  String get createYourFirstCircle;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @joinCircle.
  ///
  /// In en, this message translates to:
  /// **'Join Circle'**
  String get joinCircle;

  /// No description provided for @leaveCircle.
  ///
  /// In en, this message translates to:
  /// **'Leave Circle'**
  String get leaveCircle;

  /// No description provided for @manageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get manageMembers;

  /// No description provided for @circleDetails.
  ///
  /// In en, this message translates to:
  /// **'Circle Details'**
  String get circleDetails;

  /// No description provided for @circleId.
  ///
  /// In en, this message translates to:
  /// **'Circle ID'**
  String get circleId;

  /// No description provided for @copyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get copyId;

  /// No description provided for @joinCircleByEnteringId.
  ///
  /// In en, this message translates to:
  /// **'Join a circle by entering its ID'**
  String get joinCircleByEnteringId;

  /// No description provided for @enterCircleId.
  ///
  /// In en, this message translates to:
  /// **'Enter Circle ID'**
  String get enterCircleId;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loanFundedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Loan funded successfully!'**
  String get loanFundedSuccessfully;

  /// No description provided for @failedToFundLoan.
  ///
  /// In en, this message translates to:
  /// **'Failed to fund loan: {error}'**
  String failedToFundLoan(Object error);

  /// No description provided for @guarantorRequestConfirmedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Guarantor request confirmed successfully!'**
  String get guarantorRequestConfirmedSuccessfully;

  /// No description provided for @guarantorRequestDeclinedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Guarantor request declined successfully!'**
  String get guarantorRequestDeclinedSuccessfully;

  /// No description provided for @failedToUpdateGuarantorRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to update guarantor request: {error}'**
  String failedToUpdateGuarantorRequest(Object error);

  /// No description provided for @loanRequestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Loan request submitted successfully!'**
  String get loanRequestSubmittedSuccessfully;

  /// No description provided for @failedToSubmitLoanRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit loan request: {error}'**
  String failedToSubmitLoanRequest(Object error);

  /// No description provided for @circleCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Circle created successfully!'**
  String get circleCreatedSuccessfully;

  /// No description provided for @failedToCreateCircle.
  ///
  /// In en, this message translates to:
  /// **'Failed to create circle: {error}'**
  String failedToCreateCircle(Object error);

  /// No description provided for @joinedCircleSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Joined circle successfully!'**
  String get joinedCircleSuccessfully;

  /// No description provided for @failedToJoinCircle.
  ///
  /// In en, this message translates to:
  /// **'Failed to join circle: {error}'**
  String failedToJoinCircle(Object error);

  /// No description provided for @leftCircleSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Left circle successfully!'**
  String get leftCircleSuccessfully;

  /// No description provided for @failedToLeaveCircle.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave circle: {error}'**
  String failedToLeaveCircle(Object error);

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get passwordResetEmailSent;

  /// No description provided for @failedToSendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email: {error}'**
  String failedToSendPasswordResetEmail(Object error);

  /// No description provided for @youMustBeLoggedInToFundALoan.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to fund a loan'**
  String get youMustBeLoggedInToFundALoan;

  /// No description provided for @errorLoadingLoanDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading loan details'**
  String get errorLoadingLoanDetails;

  /// No description provided for @errorLoadingGuarantor.
  ///
  /// In en, this message translates to:
  /// **'Error loading guarantor'**
  String get errorLoadingGuarantor;

  /// No description provided for @pleaseLogInToViewYourDashboard.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your dashboard.'**
  String get pleaseLogInToViewYourDashboard;

  /// No description provided for @pleaseLogInToViewGuarantorRequests.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view guarantor requests.'**
  String get pleaseLogInToViewGuarantorRequests;

  /// No description provided for @errorLoadingCircleDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading circle details'**
  String get errorLoadingCircleDetails;

  /// No description provided for @errorLoadingMembers.
  ///
  /// In en, this message translates to:
  /// **'Error loading members'**
  String get errorLoadingMembers;

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsers;

  /// No description provided for @errorLoadingUserStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading user stats'**
  String get errorLoadingUserStats;

  /// No description provided for @errorLoadingLoans.
  ///
  /// In en, this message translates to:
  /// **'Error loading loans'**
  String get errorLoadingLoans;

  /// No description provided for @errorLoadingGuarantorRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading guarantor requests'**
  String get errorLoadingGuarantorRequests;

  /// No description provided for @errorLoadingCircles.
  ///
  /// In en, this message translates to:
  /// **'Error loading circles'**
  String get errorLoadingCircles;

  /// No description provided for @errorLoadingGlobalLoanStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading global loan stats'**
  String get errorLoadingGlobalLoanStats;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @errorLoadingAuthService.
  ///
  /// In en, this message translates to:
  /// **'Error loading authentication service'**
  String get errorLoadingAuthService;

  /// No description provided for @errorLoadingUserService.
  ///
  /// In en, this message translates to:
  /// **'Error loading user service'**
  String get errorLoadingUserService;

  /// No description provided for @errorLoadingLoanService.
  ///
  /// In en, this message translates to:
  /// **'Error loading loan service'**
  String get errorLoadingLoanService;

  /// No description provided for @errorLoadingCircleService.
  ///
  /// In en, this message translates to:
  /// **'Error loading circle service'**
  String get errorLoadingCircleService;

  /// No description provided for @errorLoadingGuarantorService.
  ///
  /// In en, this message translates to:
  /// **'Error loading guarantor service'**
  String get errorLoadingGuarantorService;

  /// No description provided for @errorLoadingFirebaseService.
  ///
  /// In en, this message translates to:
  /// **'Error loading Firebase service'**
  String get errorLoadingFirebaseService;

  /// No description provided for @errorLoadingTheme.
  ///
  /// In en, this message translates to:
  /// **'Error loading theme'**
  String get errorLoadingTheme;

  /// No description provided for @errorLoadingWidgets.
  ///
  /// In en, this message translates to:
  /// **'Error loading widgets'**
  String get errorLoadingWidgets;

  /// No description provided for @errorLoadingModels.
  ///
  /// In en, this message translates to:
  /// **'Error loading models'**
  String get errorLoadingModels;

  /// No description provided for @errorLoadingScreens.
  ///
  /// In en, this message translates to:
  /// **'Error loading screens'**
  String get errorLoadingScreens;

  /// No description provided for @errorLoadingCore.
  ///
  /// In en, this message translates to:
  /// **'Error loading core'**
  String get errorLoadingCore;

  /// No description provided for @errorLoadingApp.
  ///
  /// In en, this message translates to:
  /// **'Error loading app'**
  String get errorLoadingApp;

  /// No description provided for @errorLoadingUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get errorLoadingUnknown;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
