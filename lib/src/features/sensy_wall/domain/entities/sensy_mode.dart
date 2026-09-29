enum SensyModeKind { paint, catchColor, memory, reaction }

final class SensyMode {
  const SensyMode({required this.id, required this.kind});

  final int id;
  final SensyModeKind kind;
}

const sensyModes = <SensyMode>[
  SensyMode(id: 102, kind: SensyModeKind.paint),
  SensyMode(id: 103, kind: SensyModeKind.catchColor),
  SensyMode(id: 104, kind: SensyModeKind.memory),
  SensyMode(id: 105, kind: SensyModeKind.reaction),
];

bool isSupportedModeId(int id) => sensyModes.any((mode) => mode.id == id);
