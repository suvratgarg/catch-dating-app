String classifyScreenGapAction(String nextAction) {
  final lowerAction = _remainingActionText(nextAction).toLowerCase();
  final hasProductOnlySignal = _containsAny(lowerAction, const [
    'if contractual',
    'if product keeps',
    'if product wants',
    'if that surface keeps growing',
    'product decision',
    'product-only',
    'product review',
  ]);
  if (hasProductOnlySignal) {
    return 'product-only';
  }

  final hasReferenceOnlySignal = _containsAny(lowerAction, const [
    'additional pixel-reference',
    'additional dynamic host data once canonical exports exist',
    'advisory comparison',
    'compare ',
    'continue only',
    'design reference',
    'design references',
    'future variant',
    'if backend data can',
    'if design exports',
    'if design requires',
    'if visually distinct',
    'keyboard-safe',
    'manual pass',
    'missing reference',
    'pixel comparison',
    'pixel-reference',
    'reference-specific variant',
    'reference-specific variants',
    'references and masks',
    'references are',
    'reference masks',
    'reference export',
    'reference variant',
    'remaining references',
    'simulator/manual',
    'state-specific references',
    'visual parity',
  ]);
  final hasStrongEngineeringSignal = _containsAny(lowerAction, const [
    'adapter',
    'backend',
    'callback',
    'controller',
    'extract',
    'implement',
    'mutation',
    'provider',
    'repository',
    'retry',
    'scanner',
    'test',
    'tool',
    'widgetbook',
    'wire',
    'wiring',
  ]);
  final hasWeakEngineeringSignal = _containsAny(lowerAction, const ['copy']);

  if (hasReferenceOnlySignal && !hasStrongEngineeringSignal) {
    return 'reference-only';
  }
  if (hasReferenceOnlySignal && hasStrongEngineeringSignal) {
    return 'mixed';
  }
  if (hasStrongEngineeringSignal || hasWeakEngineeringSignal) {
    return 'engineering';
  }
  return 'engineering';
}

String _remainingActionText(String nextAction) {
  final lowerAction = nextAction.toLowerCase();
  const markers = [
    'remaining route capture work is ',
    'remaining capture work is ',
    'remaining work is ',
    'remaining references are ',
    'continue only ',
    'continue ',
  ];
  for (final marker in markers) {
    final index = lowerAction.indexOf(marker);
    if (index >= 0) {
      if (marker.contains('references')) {
        return nextAction.substring(index);
      }
      return nextAction.substring(index + marker.length);
    }
  }
  return nextAction;
}

bool _containsAny(String value, List<String> needles) {
  for (final needle in needles) {
    if (value.contains(needle)) return true;
  }
  return false;
}
