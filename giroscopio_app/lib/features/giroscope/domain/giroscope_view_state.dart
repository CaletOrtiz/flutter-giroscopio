class GiroscopeViewState {
  const GiroscopeViewState({
    this.yaw = 0,
    this.pitch = 0,
    this.vfov = 70,
    this.isGyroscopeEnabled = false,
    this.error,
  });

  final double yaw;
  final double pitch;
  final double vfov;
  final bool isGyroscopeEnabled;
  final String? error;

  GiroscopeViewState copyWith({
    double? yaw,
    double? pitch,
    double? vfov,
    bool? isGyroscopeEnabled,
    String? error,
  }) {
    return GiroscopeViewState(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      vfov: vfov ?? this.vfov,
      isGyroscopeEnabled: isGyroscopeEnabled ?? this.isGyroscopeEnabled,
      error: error ?? this.error,
    );
  }
}
