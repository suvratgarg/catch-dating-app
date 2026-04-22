// ─────────────────────────────────────────────────────────────
// Shared primitives for Catch screens
// ─────────────────────────────────────────────────────────────

// Deterministic faux-photo gradient avatar (no real photos in prototype)
function avatarGrad(seed = '') {
  const palettes = [
    ['#FF8A5B','#FF3E6F'], ['#6B8CFF','#A3E4FF'], ['#FFCE54','#FF7846'],
    ['#2E8F6B','#9AD469'], ['#A86BFF','#FF6BC7'], ['#1F3A4D','#6B9BB8'],
    ['#E74F3B','#FFA26E'], ['#4B3A2E','#B68A5F'], ['#0F2F2F','#3EA89B'],
    ['#C24B2C','#F2B06E'], ['#2C3E50','#7FAFCE'], ['#D48A2D','#F6D27A'],
  ];
  let h = 0;
  for (let i=0;i<seed.length;i++) h = (h*31 + seed.charCodeAt(i)) >>> 0;
  const p = palettes[h % palettes.length];
  const angle = (h >> 3) % 180;
  return `linear-gradient(${angle}deg, ${p[0]} 0%, ${p[1]} 100%)`;
}

// An abstract 'photo' — gradient + soft shape to imply a figure
function PhotoBox({ seed = 'x', rounded = 0, style = {}, showFigure = true, dark = false }) {
  const g = avatarGrad(seed);
  // seed-derived figure position
  let h = 0; for (let i=0;i<seed.length;i++) h = (h*31 + seed.charCodeAt(i)) >>> 0;
  const cx = 30 + (h % 40);
  const cy = 45 + ((h>>3) % 25);
  const bodyW = 50 + ((h>>6) % 30);
  const headR = 14 + ((h>>9) % 4);
  return (
    <div style={{
      width: '100%', height: '100%', borderRadius: rounded,
      background: g, position: 'relative', overflow: 'hidden',
      ...style,
    }}>
      {showFigure && (
        <svg viewBox="0 0 100 140" preserveAspectRatio="xMidYMax slice"
             style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
          <defs>
            <radialGradient id={`glow-${seed}`} cx="50%" cy="30%" r="70%">
              <stop offset="0" stopColor="rgba(255,255,255,0.35)"/>
              <stop offset="1" stopColor="rgba(255,255,255,0)"/>
            </radialGradient>
          </defs>
          <rect width="100" height="140" fill={`url(#glow-${seed})`} />
          {/* body */}
          <ellipse cx={cx} cy={cy + 55} rx={bodyW/2} ry="45" fill="rgba(0,0,0,0.18)"/>
          {/* head */}
          <circle cx={cx} cy={cy} r={headR} fill="rgba(0,0,0,0.22)"/>
        </svg>
      )}
    </div>
  );
}

// Rounded pill button
function Button({ children, theme, variant = 'primary', size = 'md', style = {}, icon, onClick }) {
  const sizes = {
    sm: { h: 36, px: 16, fs: 14, gap: 6 },
    md: { h: 52, px: 24, fs: 16, gap: 8 },
    lg: { h: 60, px: 28, fs: 17, gap: 10 },
  }[size];
  const variants = {
    primary: { bg: theme.primary, fg: theme.primaryInk, bd: 'transparent' },
    secondary: { bg: 'transparent', fg: theme.ink, bd: theme.line2 },
    ghost: { bg: 'transparent', fg: theme.ink, bd: 'transparent' },
    accent: { bg: theme.accent, fg: theme.accentInk, bd: 'transparent' },
    soft: { bg: theme.primarySoft, fg: theme.primary, bd: 'transparent' },
    dark: { bg: theme.ink, fg: theme.surface, bd: 'transparent' },
  }[variant];
  return (
    <button onClick={onClick} style={{
      height: sizes.h, padding: `0 ${sizes.px}px`, borderRadius: 999,
      background: variants.bg, color: variants.fg,
      border: `1px solid ${variants.bd}`,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      gap: sizes.gap, fontSize: sizes.fs, fontWeight: 600,
      letterSpacing: -0.2, cursor: 'pointer',
      fontFamily: 'inherit',
      ...style,
    }}>
      {icon}{children}
    </button>
  );
}

// Chip/tag
function Chip({ children, theme, active = false, icon, style = {} }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      height: 32, padding: '0 12px', borderRadius: 999,
      background: active ? theme.ink : 'transparent',
      color: active ? theme.surface : theme.ink2,
      border: `1px solid ${active ? theme.ink : theme.line2}`,
      fontSize: 13, fontWeight: 500, whiteSpace: 'nowrap',
      ...style,
    }}>{icon}{children}</div>
  );
}

// Tiny inline icons (stroke) — tuned small
const Icon = {
  shoe: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M3 16c0-1 .5-2 2-2l5-1 2-4c.5-1 1.5-1.5 2.5-1 1 .4 1.5 1.5 1 2.5l-.5 1 5 3c1 .6 1.5 1.5 1.5 2.5v1H3v-2z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M7 14l.5 1M10 13l.5 1M13 12l.5 1" stroke={c} strokeWidth="1.4" strokeLinecap="round"/>
    </svg>
  ),
  heart: ({c='currentColor',s=20,filled=false}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={filled?c:'none'}>
      <path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/>
    </svg>
  ),
  x: ({c='currentColor',s=20}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  pin: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M12 21s7-6.5 7-12a7 7 0 1 0-14 0c0 5.5 7 12 7 12z" stroke={c} strokeWidth="1.6"/>
      <circle cx="12" cy="9" r="2.5" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  clock: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="9" stroke={c} strokeWidth="1.6"/>
      <path d="M12 7v5l3 2" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  users: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="9" cy="8" r="3.5" stroke={c} strokeWidth="1.6"/>
      <path d="M3 20c0-3 3-5 6-5s6 2 6 5" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
      <path d="M16 10a3 3 0 0 0 0-5M15 20c0-2 1-3.5 3-4" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  chat: ({c='currentColor',s=22}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M4 5h16v11H9l-5 4V5z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
  person: ({c='currentColor',s=22}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="8" r="4" stroke={c} strokeWidth="1.6"/>
      <path d="M4 21c0-4 4-7 8-7s8 3 8 7" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  map: ({c='currentColor',s=22}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M3 6l6-2 6 2 6-2v14l-6 2-6-2-6 2V6z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M9 4v16M15 6v16" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  search: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="11" cy="11" r="6" stroke={c} strokeWidth="1.8"/>
      <path d="M16 16l4 4" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  filter: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M4 5h16M7 12h10M10 19h4" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  bell: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M6 16l-1 2h14l-1-2V10a6 6 0 1 0-12 0v6z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M10 20a2 2 0 0 0 4 0" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  back: ({c='currentColor',s=22}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M14 6l-6 6 6 6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  plus: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M12 5v14M5 12h14" stroke={c} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  check: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M5 13l4 4 10-10" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  send: ({c='currentColor',s=20}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M3 12l18-8-8 18-2-8-8-2z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
  settings: ({c='currentColor',s=20}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="3" stroke={c} strokeWidth="1.6"/>
      <path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4L7 17M17 7l1.4-1.4" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  edit: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M4 20h4l10-10-4-4L4 16v4z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
  bolt: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c}>
      <path d="M13 2L4 14h6l-1 8 9-12h-6l1-8z"/>
    </svg>
  ),
  flame: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c}>
      <path d="M12 2s2 3 2 6c0 1.5-1 2-1 2s3 0 3 4c0 3-2 6-6 6s-6-2-6-6c0-5 5-6 5-10 0 0 3 0 3 -2z"/>
    </svg>
  ),
  dot: ({c='currentColor',s=6}) => (
    <svg width={s} height={s} viewBox="0 0 6 6"><circle cx="3" cy="3" r="3" fill={c}/></svg>
  ),
  route: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="6" cy="5" r="2" stroke={c} strokeWidth="1.6"/>
      <circle cx="18" cy="19" r="2" stroke={c} strokeWidth="1.6"/>
      <path d="M6 7v4a4 4 0 0 0 4 4h4a4 4 0 0 1 4 4" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  star: ({c='currentColor',s=14,filled=true}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={filled?c:'none'}>
      <path d="M12 3l3 6 7 1-5 5 1 7-6-3-6 3 1-7-5-5 7-1z" stroke={c} strokeWidth="1.5" strokeLinejoin="round"/>
    </svg>
  ),
  camera: ({c='currentColor',s=20}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M4 8h3l2-2h6l2 2h3v10H4V8z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <circle cx="12" cy="13" r="3.5" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  calendar: ({c='currentColor',s=16}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="3" y="5" width="18" height="16" rx="2" stroke={c} strokeWidth="1.6"/>
      <path d="M3 10h18M8 3v4M16 3v4" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  home: ({c='currentColor',s=22}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1v-9z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
  grid: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="3" y="3" width="7" height="7" rx="1.5" stroke={c} strokeWidth="1.6"/>
      <rect x="14" y="3" width="7" height="7" rx="1.5" stroke={c} strokeWidth="1.6"/>
      <rect x="3" y="14" width="7" height="7" rx="1.5" stroke={c} strokeWidth="1.6"/>
      <rect x="14" y="14" width="7" height="7" rx="1.5" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  list: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M8 6h12M8 12h12M8 18h12" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
      <circle cx="4" cy="6" r="1" fill={c}/><circle cx="4" cy="12" r="1" fill={c}/><circle cx="4" cy="18" r="1" fill={c}/>
    </svg>
  ),
  trophy: ({c='currentColor',s=18}) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M7 4h10v4a5 5 0 0 1-10 0V4z" stroke={c} strokeWidth="1.6"/>
      <path d="M7 5H4v2a3 3 0 0 0 3 3M17 5h3v2a3 3 0 0 1-3 3M9 14h6l-1 5h-4l-1-5z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
};

// Tab bar for main app
function TabBar({ theme, active = 'home', type }) {
  const items = [
    { key: 'home', icon: 'home', label: 'Home' },
    { key: 'clubs', icon: 'shoe', label: 'Clubs' },
    { key: 'catches', icon: 'heart', label: 'Catches' },
    { key: 'messages', icon: 'chat', label: 'Chats' },
    { key: 'profile', icon: 'person', label: 'You' },
  ];
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-around', alignItems: 'center',
      padding: '8px 0 24px', background: theme.surface,
      borderTop: `1px solid ${theme.line}`,
    }}>
      {items.map(it => {
        const isActive = active === it.key;
        const I = Icon[it.icon];
        return (
          <div key={it.key} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            padding: '6px 10px', minWidth: 54,
          }}>
            <I c={isActive ? theme.primary : theme.ink3} s={22} filled={false}/>
            <div style={{
              fontSize: 10, fontWeight: 600, letterSpacing: 0.2,
              color: isActive ? theme.primary : theme.ink3,
              fontFamily: type.text,
              textTransform: type.caps ? 'uppercase' : 'none',
            }}>{it.label}</div>
          </div>
        );
      })}
    </div>
  );
}

// Status bar (simple, black or white time/indicators)
function StatusBar({ theme, time = '9:41' }) {
  const c = theme.dark ? '#fff' : '#000';
  return (
    <div style={{
      height: 44, padding: '0 24px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      fontFamily: '-apple-system, system-ui', color: c,
      position: 'relative', zIndex: 5,
    }}>
      <div style={{ fontWeight: 600, fontSize: 15 }}>{time}</div>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 19 12"><rect x="0" y="7.5" width="3" height="4.5" rx="0.7" fill={c}/><rect x="4.5" y="5" width="3" height="7" rx="0.7" fill={c}/><rect x="9" y="2.5" width="3" height="9.5" rx="0.7" fill={c}/><rect x="13.5" y="0" width="3" height="12" rx="0.7" fill={c}/></svg>
        <svg width="16" height="11" viewBox="0 0 17 12"><path d="M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z" fill={c}/><path d="M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z" fill={c}/><circle cx="8.5" cy="10.5" r="1.5" fill={c}/></svg>
        <svg width="25" height="12" viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3.5" stroke={c} strokeOpacity="0.35" fill="none"/><rect x="2" y="2" width="20" height="9" rx="2" fill={c}/><path d="M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z" fill={c} fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// Top app-bar (non-large)
function TopBar({ theme, type, title, left, right, border = false }) {
  return (
    <div style={{
      padding: '8px 16px', display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', gap: 8,
      background: theme.surface, color: theme.ink,
      borderBottom: border ? `1px solid ${theme.line}` : 'none',
      minHeight: 52,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, flex: 1 }}>
        {left}
        {title && <div style={{
          fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight,
          letterSpacing: type.displayTracking+'em',
        }}>{title}</div>}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>{right}</div>
    </div>
  );
}

// Circular icon button (for nav)
function IconBtn({ theme, children, bg }) {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: 999,
      background: bg || theme.raised, color: theme.ink,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      border: `1px solid ${theme.line}`,
    }}>{children}</div>
  );
}

// Progress bar (for onboarding)
function Progress({ theme, value }) {
  return (
    <div style={{ height: 4, background: theme.line2, borderRadius: 999, overflow: 'hidden' }}>
      <div style={{ width: `${value*100}%`, height: '100%', background: theme.primary, borderRadius: 999 }}/>
    </div>
  );
}

// Map placeholder — stylized route
function MiniMap({ theme, height = 120, style = {}, route = true }) {
  const isDark = theme.dark;
  const landBg = isDark ? '#1A2E2A' : '#E8EDE5';
  const water  = isDark ? '#0F1E2B' : '#CDDDE6';
  const road   = isDark ? '#2F2A24' : '#FFFFFF';
  return (
    <div style={{
      width: '100%', height, background: landBg, position: 'relative',
      overflow: 'hidden', ...style,
    }}>
      <svg viewBox="0 0 300 160" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
        {/* water */}
        <path d="M0 110 C 60 100 120 130 200 120 L 300 130 L 300 160 L 0 160 Z" fill={water}/>
        {/* roads */}
        <path d="M-10 40 L 310 60" stroke={road} strokeWidth="6" />
        <path d="M80 -10 L 100 170" stroke={road} strokeWidth="4" />
        <path d="M200 -10 L 220 170" stroke={road} strokeWidth="4" />
        <path d="M-10 90 L 310 100" stroke={road} strokeWidth="3" />
        {/* blocks */}
        <rect x="20" y="10" width="50" height="24" fill={isDark?'#2A423D':'#D5DCC8'} opacity="0.5"/>
        <rect x="120" y="10" width="70" height="40" fill={isDark?'#2A423D':'#D5DCC8'} opacity="0.5"/>
        <rect x="230" y="10" width="60" height="44" fill={isDark?'#2A423D':'#D5DCC8'} opacity="0.5"/>
        <rect x="20" y="65" width="50" height="18" fill={isDark?'#2A423D':'#D5DCC8'} opacity="0.5"/>
        <rect x="230" y="65" width="60" height="22" fill={isDark?'#2A423D':'#D5DCC8'} opacity="0.5"/>
        {/* park */}
        <rect x="120" y="60" width="70" height="35" fill={isDark?'#25413A':'#CFDCB8'} opacity="0.7"/>
        {/* route */}
        {route && <path d="M40 130 Q 90 90 140 80 T 250 50" stroke={theme.primary} strokeWidth="3" fill="none" strokeLinecap="round" strokeDasharray="0"/>}
        {route && <circle cx="40" cy="130" r="5" fill={theme.primary}/>}
        {route && <circle cx="250" cy="50" r="5" fill={theme.ink} stroke="white" strokeWidth="2"/>}
      </svg>
    </div>
  );
}

// Toggle switch
function Toggle({ theme, on = false }) {
  return (
    <div style={{
      width: 38, height: 22, borderRadius: 999, padding: 2,
      background: on ? theme.primary : theme.line2,
      display: 'flex', alignItems: 'center',
      justifyContent: on ? 'flex-end' : 'flex-start',
      transition: 'background 0.2s',
    }}>
      <div style={{ width: 18, height: 18, borderRadius: 999, background: '#fff', boxShadow:'0 1px 2px rgba(0,0,0,0.2)' }}/>
    </div>
  );
}

Object.assign(window, {
  avatarGrad, PhotoBox, Button, Chip, Icon, Toggle,
  TabBar, StatusBar, TopBar, IconBtn, Progress, MiniMap,
});
