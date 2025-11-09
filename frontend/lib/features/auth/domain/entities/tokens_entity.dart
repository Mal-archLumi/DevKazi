class TokensEntity {
  final String accessToken;
  final String refreshToken;

  const TokensEntity({required this.accessToken, required this.refreshToken});

  bool get hasValidTokens => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  TokensEntity copyWith({String? accessToken, String? refreshToken}) {
    return TokensEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
