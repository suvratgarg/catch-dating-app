// Auth + Onboarding screens for Catch
// Each screen is a function returning content sized to fit inside iPhone frame (402 x 874 minus status bar)

// Welcome / splash
function ScreenWelcome({ theme, type }) {
  return (
    <div data-screen-label="01 Welcome" style={{
      width: '100%', height: '100%',
      background: theme.heroGrad,
      position: 'relative', overflow: 'hidden', color: '#fff',
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusBar theme={{...theme, dark:true}} />
      {/* decorative running track */}
      <svg viewBox="0 0 400 800" style={{ position:'absolute', inset:0, width:'100%', height:'100%', opacity: 0.18 }}>
        <defs>
          <pattern id="stripes" width="10" height="10" patternUnits="userSpaceOnUse" patternTransform="rotate(35)">
            <rect width="5" height="10" fill="#fff"/>
          </pattern>
        </defs>
        <circle cx="350" cy="100" r="140" fill="url(#stripes)"/>
        <circle cx="-20" cy="650" r="180" fill="url(#stripes)"/>
      </svg>
      <div style={{ padding: '40px 28px 0', position: 'relative' }}>
        <div style={{ fontFamily: type.display, fontWeight: 700, fontSize: 14, letterSpacing: 2, textTransform: 'uppercase' }}>
          ● catch
        </div>
      </div>
      <div style={{ flex: 1, padding: '0 28px', display: 'flex', alignItems: 'flex-end' }}>
        <div style={{ paddingBottom: 28 }}>
          <div style={{
            fontFamily: type.display, fontWeight: type.displayWeight,
            fontSize: 56, lineHeight: 0.95, letterSpacing: type.displayTracking+'em',
            textWrap: 'pretty',
          }}>
            Love arrives<br/>at <em style={{ fontStyle: type.caps?'normal':'italic' }}>mile three.</em>
          </div>
          <div style={{ fontFamily: type.text, fontSize: 16, marginTop: 16, opacity: 0.88, lineHeight: 1.4, maxWidth: 320 }}>
            Meet someone on a group run. Swipe on people you actually ran with — not strangers 30 miles away.
          </div>
        </div>
      </div>
      <div style={{ padding: '0 20px 40px', display:'flex', flexDirection:'column', gap: 10 }}>
        <Button theme={{...theme, primary:'#fff', primaryInk: theme.dark?theme.ink:theme.primary}} size="lg" style={{ width:'100%' }}>
          Get started
        </Button>
        <div style={{ textAlign:'center', fontSize: 14, fontFamily: type.text, opacity: 0.9 }}>
          Already a runner? <span style={{ textDecoration: 'underline', fontWeight: 600 }}>Sign in</span>
        </div>
      </div>
    </div>
  );
}

function ScreenPhone({ theme, type }) {
  return (
    <div data-screen-label="02 Phone" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink} /></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column' }}>
        <Progress theme={theme} value={0.14}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 1 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          What's your number?
        </div>
        <div style={{ fontFamily: type.text, fontSize: 15, color: theme.ink2, marginTop: 8 }}>
          We'll text you a 6-digit code. Never shared with matches.
        </div>
        <div style={{ marginTop: 32, display:'flex', gap: 8 }}>
          <div style={{
            padding: '0 14px', height: 60, borderRadius: 14,
            border: `1px solid ${theme.line2}`, background: theme.surface,
            display:'flex', alignItems:'center', gap: 8, fontSize: 18, fontWeight: 500,
          }}>
            🇮🇳 +91
          </div>
          <div style={{
            flex: 1, height: 60, borderRadius: 14,
            border: `1.5px solid ${theme.primary}`, background: theme.surface,
            display:'flex', alignItems:'center', padding: '0 16px',
            fontSize: 22, fontWeight: 500, letterSpacing: 1, color: theme.ink,
          }}>
            91314 04222<span style={{ display:'inline-block', width:2, height:22, background: theme.primary, marginLeft:2, animation: 'blink 1s infinite' }}/>
          </div>
        </div>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 12 }}>
          By continuing you agree to our <u>Terms</u> & <u>Privacy</u>.
        </div>
        <div style={{ flex: 1 }}/>
        <Button theme={theme} size="lg" style={{ width: '100%' }}>Send code →</Button>
      </div>
    </div>
  );
}

function ScreenOtp({ theme, type }) {
  const digits = ['4','8','2','','',''];
  return (
    <div data-screen-label="03 OTP" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column' }}>
        <Progress theme={theme} value={0.28}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 2 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          Enter the code
        </div>
        <div style={{ fontFamily: type.text, fontSize: 15, color: theme.ink2, marginTop: 8 }}>
          Sent to +91 91314 04222. <u>Change number</u>
        </div>
        <div style={{ marginTop: 32, display:'flex', gap: 10 }}>
          {digits.map((d,i)=>(
            <div key={i} style={{
              flex:1, height: 64, borderRadius: 12,
              border: `1.5px solid ${i===3?theme.primary:theme.line2}`,
              background: theme.surface,
              display:'flex', alignItems:'center', justifyContent:'center',
              fontSize: 28, fontWeight: 600, fontFamily: type.display,
            }}>{d}</div>
          ))}
        </div>
        <div style={{ marginTop: 24, fontFamily: type.text, fontSize: 14, color: theme.ink2 }}>
          Resend code in <b style={{ color: theme.ink }}>0:23</b>
        </div>
        <div style={{ flex: 1 }}/>
      </div>
    </div>
  );
}

// Step 3: name/DOB
function ScreenName({ theme, type }) {
  return (
    <div data-screen-label="04 Name" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column' }}>
        <Progress theme={theme} value={0.42}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 3 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          The basics
        </div>
        <div style={{ fontFamily: type.text, fontSize: 15, color: theme.ink2, marginTop: 8 }}>
          Last name stays private until you catch.
        </div>
        <div style={{ marginTop: 28, display:'flex', flexDirection:'column', gap: 14 }}>
          {[
            { label:'First name', val:'Suvrat' },
            { label:'Last name', val:'Garg' },
          ].map((f,i)=>(
            <div key={i}>
              <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 6, textTransform:'uppercase', letterSpacing: 0.6 }}>{f.label}</div>
              <div style={{ height: 56, borderRadius: 12, background: theme.surface, border:`1px solid ${theme.line2}`, padding:'0 16px', display:'flex', alignItems:'center', fontSize: 18 }}>{f.val}</div>
            </div>
          ))}
          <div>
            <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 6, textTransform:'uppercase', letterSpacing: 0.6 }}>Date of birth</div>
            <div style={{ display:'flex', gap: 8 }}>
              {['12','Aug','1998'].map((v,i)=>(
                <div key={i} style={{ flex: i===1?1.3:1, height: 56, borderRadius: 12, background: theme.surface, border:`1px solid ${theme.line2}`, padding:'0 16px', display:'flex', alignItems:'center', justifyContent:'center', fontSize: 18, fontWeight: 500 }}>{v}</div>
              ))}
            </div>
            <div style={{ fontSize:12, color: theme.ink3, marginTop:6 }}>You'll be 27. We never show your birth year.</div>
          </div>
        </div>
        <div style={{ flex: 1 }}/>
        <Button theme={theme} size="lg" style={{ width: '100%' }}>Continue</Button>
      </div>
    </div>
  );
}

// Step 4: gender / orientation
function ScreenGender({ theme, type }) {
  const orientation = ['Straight','Gay','Bisexual','Pansexual','Queer','Other'];
  return (
    <div data-screen-label="05 Gender" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column', overflow: 'auto' }}>
        <Progress theme={theme} value={0.56}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 4 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          You &amp; who you want to meet
        </div>
        <div style={{ marginTop: 24 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>I am</div>
          <div style={{ display:'flex', gap:8 }}>
            {['Woman','Man','Non-binary'].map((g,i)=>(
              <div key={g} style={{
                flex: 1, height: 56, borderRadius: 12,
                background: i===0?theme.ink:theme.surface,
                color: i===0?theme.surface:theme.ink,
                border:`1px solid ${i===0?theme.ink:theme.line2}`,
                display:'flex', alignItems:'center', justifyContent:'center', fontSize: 15, fontWeight: 500,
              }}>{g}</div>
            ))}
          </div>
        </div>
        <div style={{ marginTop: 20 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>Interested in</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {orientation.map((o,i)=>(
              <Chip key={o} theme={theme} active={i===0}>{o}</Chip>
            ))}
          </div>
        </div>
        <div style={{ marginTop: 22 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>Show me</div>
          <div style={{ display:'flex', gap:8 }}>
            {['Men','Women','Everyone'].map((g,i)=>(
              <div key={g} style={{
                flex: 1, height: 48, borderRadius: 12,
                background: i===0?theme.primary:theme.surface,
                color: i===0?theme.primaryInk:theme.ink,
                border:`1px solid ${i===0?theme.primary:theme.line2}`,
                display:'flex', alignItems:'center', justifyContent:'center', fontSize: 15, fontWeight: 600,
              }}>{g}</div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// Step 5: photos upload grid
function ScreenPhotos({ theme, type }) {
  const filled = [0,1,2]; // which slots have photos
  return (
    <div data-screen-label="06 Photos" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column', overflow:'auto' }}>
        <Progress theme={theme} value={0.72}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 5 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          Pics please
        </div>
        <div style={{ fontFamily: type.text, fontSize: 15, color: theme.ink2, marginTop: 8 }}>
          Add at least 3. Drag to reorder. First one is your main.
        </div>
        <div style={{ marginTop: 20, display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap: 10 }}>
          {Array.from({length:6}).map((_,i)=>(
            <div key={i} style={{
              aspectRatio:'3/4', borderRadius: 14, overflow:'hidden',
              background: theme.raised,
              border: filled.includes(i) ? 'none' : `1.5px dashed ${theme.line2}`,
              position:'relative',
            }}>
              {filled.includes(i) ? (
                <>
                  <PhotoBox seed={`me-${i}`} />
                  {i===0 && <div style={{ position:'absolute', top:6, left:6, padding:'2px 8px', fontSize:10, fontWeight:700, borderRadius:999, background:theme.primary, color:theme.primaryInk, letterSpacing:0.5, textTransform:'uppercase' }}>Main</div>}
                </>
              ) : (
                <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', color: theme.ink3, fontSize: 28 }}>
                  <Icon.plus c={theme.ink3} s={28}/>
                </div>
              )}
            </div>
          ))}
        </div>
        <div style={{ marginTop: 14, padding: 12, borderRadius: 12, background: theme.primarySoft, color: theme.primary, display:'flex', gap: 10, alignItems:'flex-start' }}>
          <Icon.bolt c={theme.primary} s={18}/>
          <div style={{ fontSize: 13, lineHeight: 1.4 }}>
            <b>Tip:</b> one full-body running photo boosts catches by 2.3×.
          </div>
        </div>
        <div style={{ flex:1 }}/>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>Continue</Button>
      </div>
    </div>
  );
}

// Step 6: pace / runner profile
function ScreenPace({ theme, type }) {
  return (
    <div data-screen-label="07 Pace" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ padding: '16px 24px 24px', flex:1, display:'flex', flexDirection:'column', overflow:'auto' }}>
        <Progress theme={theme} value={0.86}/>
        <div style={{ fontFamily: type.text, fontSize: 12, color: theme.ink3, marginTop: 10, letterSpacing: 0.6, textTransform: 'uppercase' }}>Step 6 of 7</div>
        <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 24 }}>
          Your stride
        </div>
        <div style={{ fontFamily: type.text, fontSize: 15, color: theme.ink2, marginTop: 8 }}>
          We match you to runs at your level.
        </div>

        <div style={{ marginTop: 22 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>Typical pace (per km)</div>
          <div style={{ padding: 16, borderRadius: 16, background: theme.surface, border:`1px solid ${theme.line}` }}>
            <div style={{ fontFamily: type.display, fontSize: 40, fontWeight: 700, color: theme.ink, letterSpacing: -1 }}>
              5:42<span style={{ fontSize: 18, color: theme.ink3, fontWeight: 500 }}> /km</span>
            </div>
            <div style={{ height: 6, background: theme.line2, borderRadius:999, marginTop: 12, position:'relative' }}>
              <div style={{ position:'absolute', left:0, width:'52%', height:'100%', background: theme.primary, borderRadius:999 }}/>
              <div style={{ position:'absolute', left:'52%', width:16, height:16, top:-5, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.25)' }}/>
            </div>
            <div style={{ display:'flex', justifyContent:'space-between', fontSize:11, color: theme.ink3, marginTop:8, fontFamily: type.mono, textTransform:'uppercase', letterSpacing: 0.5 }}>
              <span>Stroll 8:00</span><span>Elite 3:30</span>
            </div>
          </div>
        </div>

        <div style={{ marginTop: 20 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>Favourite distances</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['5K','10K','Half','Full','Trail','Track'].map((d,i)=>(
              <Chip key={d} theme={theme} active={[0,1,2].includes(i)}>{d}</Chip>
            ))}
          </div>
        </div>

        <div style={{ marginTop: 20 }}>
          <div style={{ fontSize:12, fontWeight:600, color: theme.ink2, marginBottom: 10, textTransform:'uppercase', letterSpacing: 0.6 }}>Why do you run?</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['Social','Fitness','Race PRs','Mental health','Community','Coffee after'].map((d,i)=>(
              <Chip key={d} theme={theme} active={[0,5].includes(i)}>{d}</Chip>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  ScreenWelcome, ScreenPhone, ScreenOtp, ScreenName, ScreenGender, ScreenPhotos, ScreenPace,
});
