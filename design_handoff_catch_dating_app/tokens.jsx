// ─────────────────────────────────────────────────────────────
// Design tokens for Catch — a dating app for runners
// 3 palettes × 2 type systems × light/dark
// ─────────────────────────────────────────────────────────────

const PALETTES = {
  sunset: {
    name: 'Sunset',
    sub:  'warm orange + cream',
    // light
    bg:      '#FBF3E9',
    surface: '#FFFFFF',
    raised:  '#FFF8EE',
    ink:     '#1A1410',
    ink2:    '#5C4A3A',
    ink3:    '#9C8775',
    line:    'rgba(26,20,16,0.08)',
    line2:   'rgba(26,20,16,0.14)',
    primary: '#FF4E1F',        // catch orange
    primaryInk: '#FFFFFF',
    primarySoft: '#FFE2D4',
    accent:  '#0B3B3C',        // deep teal
    accentInk: '#FFFFFF',
    like:    '#FF4E1F',
    pass:    '#1A1410',
    gold:    '#E9A43A',
    // dark
    dBg:      '#120D09',
    dSurface: '#1D1612',
    dRaised:  '#2A2018',
    dInk:     '#FBF3E9',
    dInk2:    '#C8B8A6',
    dInk3:    '#7C6B5A',
    dLine:    'rgba(251,243,233,0.10)',
    dLine2:   'rgba(251,243,233,0.18)',
    dPrimary: '#FF6A3F',
    dPrimaryInk: '#120D09',
    dPrimarySoft: '#3A1E10',
    dAccent:  '#45D6B3',
    heroGrad: 'linear-gradient(135deg,#FF4E1F 0%,#FF9A5C 60%,#FFC78A 100%)',
  },

  street: {
    name: 'Street',
    sub:  'neon lime on black',
    bg:      '#F1F1EC',
    surface: '#FFFFFF',
    raised:  '#F7F7F2',
    ink:     '#0B0B0A',
    ink2:    '#3F3F3B',
    ink3:    '#8A8A84',
    line:    'rgba(11,11,10,0.08)',
    line2:   'rgba(11,11,10,0.15)',
    primary: '#0B0B0A',        // black on light
    primaryInk: '#D6FF3B',
    primarySoft: '#E9E9E4',
    accent:  '#D6FF3B',        // neon lime
    accentInk: '#0B0B0A',
    like:    '#D6FF3B',
    pass:    '#0B0B0A',
    gold:    '#FF7A00',
    dBg:      '#0B0B0A',
    dSurface: '#141413',
    dRaised:  '#1C1C1A',
    dInk:     '#F1F1EC',
    dInk2:    '#A8A8A2',
    dInk3:    '#5A5A55',
    dLine:    'rgba(255,255,255,0.08)',
    dLine2:   'rgba(255,255,255,0.16)',
    dPrimary: '#D6FF3B',
    dPrimaryInk: '#0B0B0A',
    dPrimarySoft: '#2A3306',
    dAccent:  '#D6FF3B',
    heroGrad: 'linear-gradient(180deg,#0B0B0A 0%,#1C1C1A 100%)',
  },

  editorial: {
    name: 'Editorial',
    sub:  'clay + ivory + olive',
    bg:      '#F2EDE3',
    surface: '#FFFDF8',
    raised:  '#EFE8DA',
    ink:     '#1C1A14',
    ink2:    '#5A5042',
    ink3:    '#9A8F7C',
    line:    'rgba(28,26,20,0.10)',
    line2:   'rgba(28,26,20,0.18)',
    primary: '#C7502C',        // clay red
    primaryInk: '#FFFDF8',
    primarySoft: '#F4DDD1',
    accent:  '#3C4A22',        // olive
    accentInk: '#FFFDF8',
    like:    '#C7502C',
    pass:    '#1C1A14',
    gold:    '#B58A3E',
    dBg:      '#17150F',
    dSurface: '#21201A',
    dRaised:  '#2B2920',
    dInk:     '#F2EDE3',
    dInk2:    '#C8BFA9',
    dInk3:    '#7A705B',
    dLine:    'rgba(242,237,227,0.10)',
    dLine2:   'rgba(242,237,227,0.18)',
    dPrimary: '#E87656',
    dPrimaryInk: '#17150F',
    dPrimarySoft: '#3B1A10',
    dAccent:  '#8FA255',
    heroGrad: 'linear-gradient(135deg,#C7502C 0%,#E9A86C 100%)',
  },
};

// Typography systems
const TYPE = {
  sporty: {
    name: 'Sporty',
    sub:  'Space Grotesk + Inter',
    display: "'Space Grotesk', 'Inter', -apple-system, system-ui, sans-serif",
    text:    "'Inter', -apple-system, system-ui, sans-serif",
    mono:    "'JetBrains Mono', ui-monospace, monospace",
    displayWeight: 700,
    displayTracking: -0.02,
    caps: true,
  },
  editorial: {
    name: 'Editorial',
    sub:  'Fraunces + Inter',
    display: "'Fraunces', Georgia, 'Times New Roman', serif",
    text:    "'Inter', -apple-system, system-ui, sans-serif",
    mono:    "'JetBrains Mono', ui-monospace, monospace",
    displayWeight: 500,
    displayTracking: -0.01,
    caps: false,
  },
};

// Helper: resolve active theme object given palette key + dark flag
function resolveTheme(paletteKey, dark) {
  const p = PALETTES[paletteKey];
  if (!dark) {
    return {
      name: p.name, sub: p.sub, heroGrad: p.heroGrad,
      bg: p.bg, surface: p.surface, raised: p.raised,
      ink: p.ink, ink2: p.ink2, ink3: p.ink3,
      line: p.line, line2: p.line2,
      primary: p.primary, primaryInk: p.primaryInk, primarySoft: p.primarySoft,
      accent: p.accent, accentInk: p.accentInk,
      like: p.like, pass: p.pass, gold: p.gold,
      dark: false, key: paletteKey,
    };
  }
  return {
    name: p.name, sub: p.sub, heroGrad: p.heroGrad,
    bg: p.dBg, surface: p.dSurface, raised: p.dRaised,
    ink: p.dInk, ink2: p.dInk2, ink3: p.dInk3,
    line: p.dLine, line2: p.dLine2,
    primary: p.dPrimary, primaryInk: p.dPrimaryInk, primarySoft: p.dPrimarySoft,
    accent: p.dAccent, accentInk: p.primaryInk,
    like: p.dPrimary, pass: p.dInk, gold: p.gold,
    dark: true, key: paletteKey,
  };
}

Object.assign(window, { PALETTES, TYPE, resolveTheme });
