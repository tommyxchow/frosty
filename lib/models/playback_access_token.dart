class PlaybackAccessToken {
  final String value;
  final String signature;

  const PlaybackAccessToken({
    required this.value,
    required this.signature,
  });

  factory PlaybackAccessToken.fromGqlResponse(Map<String, dynamic> json) {
    final data =
        (json['data'] as Map<String, dynamic>?)?['streamPlaybackAccessToken']
            as Map<String, dynamic>?;
    if (data == null) {
      throw const FormatException(
        'streamPlaybackAccessToken missing from GQL response',
      );
    }
    return PlaybackAccessToken(
      value: data['value'] as String,
      signature: data['signature'] as String,
    );
  }
}
