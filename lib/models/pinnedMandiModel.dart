class PinnedMandi{
  final String marketId;
  final String marketName;
  final String state;
  final String district;

  PinnedMandi({
    required this.marketId,
    required this.marketName,
    required this.state,
    required this.district,
  });

  factory PinnedMandi.fromJson(Map<String, dynamic> json) {
    return PinnedMandi(
      marketId: json['id'],
      marketName: json['marketName'],
      state: json['state'],
      district: json['district'],
    );
  }
}