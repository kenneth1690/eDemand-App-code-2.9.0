// ignore_for_file: file_names


String findFirebaseError(final String code) {
  if (code == "invalid-verification-code") {
    return "invalid_verification_code";
  } else if (code == "invalid-phone-number") {
    return "invalid_phone_number";
  } else if (code == "too-many-requests") {
    return "too_many_requests";
  } else if (code == "network-request-failed") {
    return "network_request_failed";
  } else {
    return "somethingWentWrong";
  }
}
