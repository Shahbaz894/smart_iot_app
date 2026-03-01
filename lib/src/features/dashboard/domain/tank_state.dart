enum TankStatus { stable, filling, draining, critical }

class TankState {
  final double levelPercentage;
  final double volumeLitres;
  final TankStatus status;

  TankState({
    required this.levelPercentage,
    required this.volumeLitres,
    required this.status,
  });

  // Used for state manipulation if needed later
  TankState copyWith({
    double? levelPercentage,
    double? volumeLitres,
    TankStatus? status,
  }) {
    return TankState(
      levelPercentage: levelPercentage ?? this.levelPercentage,
      volumeLitres: volumeLitres ?? this.volumeLitres,
      status: status ?? this.status,
    );
  }
}