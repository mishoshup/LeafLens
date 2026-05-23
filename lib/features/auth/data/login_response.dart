import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// Deserialized response from the FastAPI login/register endpoint.
@JsonSerializable(createToJson: false)
class LoginResponse {
  /// Creates a [LoginResponse] with the required [token].
  const LoginResponse({required this.token});

  /// Creates a [LoginResponse] from the raw JSON map returned by the API.
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  /// The JWT token returned by the server.
  final String token;
}
