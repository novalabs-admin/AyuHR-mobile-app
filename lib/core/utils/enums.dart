/// Standardized status enum for data fetching operations.
///
/// Used within a BLoC/Cubit state to track the progress of loading data,
/// e.g., to drive an AppSkeletonizer or LoadingView.
enum FetchStatus {
  initial,
  loading,
  success,
  failure,
}

/// Extension to easily check [FetchStatus] states.
extension FetchStatusX on FetchStatus {
  bool get isInitial => this == FetchStatus.initial;
  bool get isLoading => this == FetchStatus.loading;
  bool get isSuccess => this == FetchStatus.success;
  bool get isFailure => this == FetchStatus.failure;
}

/// Standardized status enum for form submission or saving operations.
///
/// Used within a BLoC/Cubit state to track the progress of a user action,
/// e.g., to drive the `isLoading` property of an AppButton.
enum SubmitStatus {
  initial,
  loading,
  success,
  failure,
  passwordExpired,
}

/// Extension to easily check [SubmitStatus] states.
extension SubmitStatusX on SubmitStatus {
  bool get isInitial => this == SubmitStatus.initial;
  bool get isLoading => this == SubmitStatus.loading;
  bool get isSuccess => this == SubmitStatus.success;
  bool get isFailure => this == SubmitStatus.failure;
}
