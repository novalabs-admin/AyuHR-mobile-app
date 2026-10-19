/// Centralized class containing all API endpoint paths.
///
/// All paths are **relative** — the base URL is configured once in
/// [EnvConfig] and injected into Dio's [BaseOptions] via [NetworkModule].
/// Never hardcode absolute URLs here.
class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  /// POST login credentials
  static const String login = '/api/userManagement/user/login';

  /// POST refresh token
  static const String refresh = '/auth/refresh';

  /// POST logout
  static const String logout = '/api/userManagement/user/logout';

  /// POST change password (used when password is expired)
  static const String changePassword = '/auth/change-password';

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------
  /// GET user profile by ID
  static String userProfile(int id) => '/users/$id';

  /// GET branch by ID
  static String branch(int id) => '/branches/$id';

  /// GET all branches
  static const String branches = '/branches';

  // ---------------------------------------------------------------------------
  // Leads
  // ---------------------------------------------------------------------------
  /// POST create lead
  static const String leads = '/leads';
  static String updateLead(int id) => '/leads/$id';
  static String updateLeadStatus(int id) => '/leads/$id/status';
  static const String leadCloseReasons = '/lead-close-reasons';
  static const String leadVisitReasons = '/lead-visit-reasons';

  // ---------------------------------------------------------------------------
  // Appointments
  // ---------------------------------------------------------------------------
  static const String leadAppointments = '/lead-appointments';
  static String updateLeadAppointment(int id) => '/lead-appointments/$id';
  static const String leadAppointmentVisits = '/lead-appointment-visits';

  // ---------------------------------------------------------------------------
  // Rating Engine
  // ---------------------------------------------------------------------------
  /// GET form config
  static const String formConfig = '/quotation/form-config';

  /// GET shared plans
  static const String sharedPlans = '/plans';

  /// GET plan fields
  static const String quotationPlans = '/quotation/plans';

  /// POST calculate benefit
  static const String calculateBenefit = '/quotation/calculate-benefit';

  // ---------------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------------
  /// POST mark attendance (IN/OUT)
  static const String markAttendance = '/attendance/mark';

  /// GET today's attendance summary
  static String todaySummary(int userProfileId) =>
      '/attendance/today/$userProfileId';

  /// GET attendance summary list
  static const String attendanceSummary = '/attendance/summary';

  // ---------------------------------------------------------------------------
  // Item Master
  // ---------------------------------------------------------------------------
  /// GET items/treatments by company with search query
  /// Query params: searchQuery (string), isTreatment (bool)
  static String itemMasterSearch(int companyId) =>
      '/api/userManagement/itemMaster/GetItemMastersByCompanyIdWithQuery/$companyId';
}
