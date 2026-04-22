// Match / swipe / post-run recap screens

// Catches tab intro — a run just finished, time to swipe
function ScreenCatchesIntro({ theme, type }) {
  return (
    <div data-screen-label="13 Catches Intro" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 12px' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Catches</div>
      </div>
      <div style={{ padding: '0 20px', display:'flex', flexDirection:'column', gap: 14, flex: 1, overflow:'auto' }}>
        {/* Active run card */}
        <div style={{ background: theme.primary, color: theme.primaryInk, borderRadius: 20, padding: 18, position: 'relative', overflow:'hidden' }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.4, opacity: 0.85 }}>● LIVE — SWIPING UNTIL 11:59 PM</div>
          <div style={{ fontFamily: type.display, fontSize: 24, fontWeight: type.displayWeight, marginTop: 6, letterSpacing: type.displayTracking+'em', lineHeight: 1.1 }}>
            Who caught your eye this morning?
          </div>
          <div style={{ fontSize: 13, marginTop: 6, opacity: 0.9 }}>
            24 runners from the Bandra Breakers 7K. Swipe on anyone you ran with.
          </div>
          <div style={{ display:'flex', marginTop: 14 }}>
            {[0,1,2,3,4].map(i=>(
              <div key={i} style={{ width: 36, height: 36, borderRadius:999, marginLeft: i===0?0:-10, border: `2px solid ${theme.primary}`, overflow:'hidden' }}>
                <PhotoBox seed={`cxi-${i}`}/>
              </div>
            ))}
            <div style={{ width:36, height:36, borderRadius:999, marginLeft:-10, border:`2px solid ${theme.primary}`, background: theme.primaryInk, color: theme.primary, fontSize: 11, fontWeight:700, display:'flex', alignItems:'center', justifyContent:'center' }}>+19</div>
          </div>
          <div style={{ marginTop: 16 }}>
            <Button theme={{...theme, primary: theme.primaryInk, primaryInk: theme.primary}} size="md">Start swiping →</Button>
          </div>
        </div>
        {/* pending earlier */}
        <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight, marginTop: 6 }}>Earlier runs</div>
        {[
          { club:'Lodhi Night Owls', ago:'2 days left', people: 12, seed:'lno-c', done: false },
          { club:'Marina Milers 10K', ago:'Expired', people: 18, seed:'mm-c', done: true },
        ].map((r,i)=>(
          <div key={i} style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16, padding: 14, display:'flex', alignItems:'center', gap: 12, opacity: r.done?0.55:1 }}>
            <div style={{ width: 50, height: 50, borderRadius: 12, overflow:'hidden' }}><PhotoBox seed={r.seed}/></div>
            <div style={{ flex:1 }}>
              <div style={{ fontWeight: 600 }}>{r.club}</div>
              <div style={{ fontSize: 12, color: theme.ink2, marginTop:2 }}>{r.people} runners · {r.ago}</div>
            </div>
            {!r.done ? <Button theme={theme} variant="secondary" size="sm">Swipe</Button> : <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 600, textTransform:'uppercase', letterSpacing: 0.5 }}>Missed</div>}
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="catches"/>
    </div>
  );
}

// Swipe stack
function ScreenSwipe({ theme, type }) {
  return (
    <div data-screen-label="14 Swipe" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 16px 10px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div style={{ width:40, height:40, borderRadius:999, background: theme.raised, display:'flex', alignItems:'center', justifyContent:'center', border:`1px solid ${theme.line}` }}>
          <Icon.back c={theme.ink}/>
        </div>
        <div style={{ textAlign:'center' }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.2, color: theme.ink3 }}>BANDRA BREAKERS · TODAY</div>
          <div style={{ fontFamily: type.display, fontSize: 16, fontWeight: type.displayWeight }}>13 of 24 left</div>
        </div>
        <div style={{ width: 40 }}/>
      </div>
      <div style={{ flex: 1, position:'relative', padding: '8px 16px 0' }}>
        {/* back cards peek */}
        <div style={{ position:'absolute', inset:'12px 28px 90px', borderRadius: 24, background: theme.raised, transform:'scale(0.94)', opacity: 0.55 }}/>
        <div style={{ position:'absolute', inset:'8px 22px 84px', borderRadius: 24, background: theme.surface, transform:'scale(0.97)', opacity: 0.75, border:`1px solid ${theme.line}` }}/>
        {/* main card */}
        <div style={{
          position:'absolute', inset:'4px 16px 82px', borderRadius: 24, overflow:'hidden',
          background: '#000', boxShadow:'0 20px 40px rgba(0,0,0,0.18)',
          display:'flex', flexDirection:'column',
        }}>
          <div style={{ flex: 1, position:'relative' }}>
            <PhotoBox seed="riya-main"/>
            <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0) 30%,rgba(0,0,0,0) 50%,rgba(0,0,0,0.85) 100%)' }}/>
            {/* top badges */}
            <div style={{ position:'absolute', top:14, left:14, right:14, display:'flex', justifyContent:'space-between' }}>
              <div style={{ padding:'6px 10px', borderRadius: 999, background: 'rgba(255,255,255,0.92)', fontSize: 11, fontWeight: 700, color: '#000', letterSpacing: 0.4, display:'flex', alignItems:'center', gap:4 }}>
                <Icon.route s={13} c="#000"/> RAN 7K TODAY
              </div>
              <div style={{ padding:'6px 10px', borderRadius: 999, background: theme.primary, color: theme.primaryInk, fontSize: 11, fontWeight: 700, letterSpacing: 0.4, display:'flex', alignItems:'center', gap:4 }}>
                <Icon.flame s={12} c={theme.primaryInk}/> HIGH DEMAND
              </div>
            </div>
            {/* photo pager */}
            <div style={{ position:'absolute', top: 8, left: 40, right: 40, display:'flex', gap: 4 }}>
              {[0,1,2,3].map(i=>(
                <div key={i} style={{ flex:1, height: 3, borderRadius: 2, background: i===0?'#fff':'rgba(255,255,255,0.35)' }}/>
              ))}
            </div>
            {/* bottom info */}
            <div style={{ position:'absolute', bottom: 16, left: 18, right: 18, color: '#fff' }}>
              <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
                <div style={{ fontFamily: type.display, fontSize: 30, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1 }}>Riya, 26</div>
                <div style={{ fontSize: 12, fontWeight: 500, opacity: 0.9 }}>· 1.2 km from you</div>
              </div>
              <div style={{ fontSize: 13, marginTop: 6, opacity: 0.9 }}>Architect. Espresso over oat milk. Training for SCMM half.</div>
              <div style={{ display:'flex', gap: 6, marginTop: 10, flexWrap:'wrap' }}>
                {['5:15/km','Half ×3','Coffee after'].map(t=>(
                  <div key={t} style={{ padding:'4px 10px', fontSize:11, fontWeight:600, borderRadius:999, background:'rgba(255,255,255,0.18)', color:'#fff', backdropFilter: 'blur(8px)' }}>{t}</div>
                ))}
              </div>
            </div>
          </div>
        </div>
        {/* action dock */}
        <div style={{ position:'absolute', bottom: 18, left: 0, right: 0, display:'flex', justifyContent:'center', gap: 18 }}>
          <div style={{ width:56, height:56, borderRadius:999, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 6px 20px rgba(0,0,0,0.12)', border:`1px solid ${theme.line}` }}>
            <Icon.x c={theme.pass} s={22}/>
          </div>
          <div style={{ width:56, height:56, borderRadius:999, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 6px 20px rgba(0,0,0,0.12)', border:`1px solid ${theme.line}` }}>
            <Icon.star c={theme.gold} s={22}/>
          </div>
          <div style={{ width:72, height:72, borderRadius:999, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 10px 24px rgba(0,0,0,0.25)' }}>
            <Icon.heart c={theme.primaryInk} s={30} filled/>
          </div>
          <div style={{ width:56, height:56, borderRadius:999, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 6px 20px rgba(0,0,0,0.12)', border:`1px solid ${theme.line}` }}>
            <Icon.chat c={theme.ink} s={22}/>
          </div>
        </div>
      </div>
    </div>
  );
}

// Match moment
function ScreenMatch({ theme, type }) {
  return (
    <div data-screen-label="15 Match" style={{ width:'100%', height:'100%', background: theme.heroGrad, color:'#fff', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <svg viewBox="0 0 400 800" style={{ position:'absolute', inset:0, width:'100%', height:'100%', opacity: 0.2 }}>
        <defs>
          <pattern id="m-stripes" width="10" height="10" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
            <rect width="5" height="10" fill="#fff"/>
          </pattern>
        </defs>
        <rect width="400" height="800" fill="url(#m-stripes)"/>
      </svg>
      <StatusBar theme={{...theme, dark: true}}/>
      <div style={{ flex: 1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding: '0 24px', position:'relative' }}>
        <div style={{ fontSize: 13, fontWeight: 700, letterSpacing: 3, textTransform: 'uppercase', opacity: 0.9 }}>Catch!</div>
        <div style={{ fontFamily: type.display, fontSize: 56, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 0.95, textAlign:'center', marginTop: 14 }}>
          You two<br/><em style={{ fontStyle: type.caps?'normal':'italic' }}>ran together.</em>
        </div>
        <div style={{ fontSize: 15, marginTop: 14, opacity: 0.9, textAlign: 'center', maxWidth: 280 }}>
          Riya also caught you at the Bandra Breakers 7K.
        </div>
        <div style={{ display:'flex', marginTop: 36, gap: -24 }}>
          <div style={{ width: 140, height: 180, borderRadius: 20, overflow:'hidden', border: '4px solid white', transform:'rotate(-8deg)', boxShadow:'0 20px 40px rgba(0,0,0,0.25)' }}>
            <PhotoBox seed="me-match"/>
          </div>
          <div style={{ width: 140, height: 180, borderRadius: 20, overflow:'hidden', border: '4px solid white', transform:'rotate(8deg) translateX(-20px)', marginTop: 24, boxShadow:'0 20px 40px rgba(0,0,0,0.25)' }}>
            <PhotoBox seed="riya-match"/>
          </div>
        </div>
        {/* pace badge */}
        <div style={{ marginTop: 28, padding: '8px 14px', background:'rgba(0,0,0,0.35)', borderRadius: 999, fontSize: 12, fontWeight: 600, letterSpacing: 0.3, display:'flex', alignItems:'center', gap: 8 }}>
          <Icon.route c="#fff" s={14}/> Both ran 5:30/km · next run together?
        </div>
      </div>
      <div style={{ padding: '0 20px 40px', display:'flex', flexDirection:'column', gap: 10 }}>
        <Button theme={{...theme, primary:'#fff', primaryInk: theme.ink}} size="lg" style={{ width:'100%' }} icon={<Icon.chat c={theme.ink}/>}>
          Send a message
        </Button>
        <Button theme={theme} variant="ghost" style={{ width:'100%', color:'#fff' }}>Keep swiping</Button>
      </div>
    </div>
  );
}

// Post-run recap / rate attendees — quick vibes
function ScreenRecap({ theme, type }) {
  return (
    <div data-screen-label="16 Post-run Recap" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} left={<IconBtn theme={theme}><Icon.x c={theme.ink}/></IconBtn>} title="Run recap"/>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        {/* stats hero */}
        <div style={{ background: theme.ink, color: theme.surface, borderRadius: 20, padding: 20, position:'relative', overflow:'hidden' }}>
          <div style={{ fontSize: 11, letterSpacing: 1.4, fontWeight: 700, opacity: 0.7 }}>BANDRA BREAKERS · 7.2 KM · COMPLETE</div>
          <div style={{ fontFamily: type.display, fontSize: 38, fontWeight: type.displayWeight, lineHeight: 1, marginTop: 10, letterSpacing: type.displayTracking+'em' }}>
            39:12
          </div>
          <div style={{ fontSize: 13, opacity: 0.75, marginTop: 4 }}>Avg pace 5:26/km · your new PR</div>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10, marginTop: 20 }}>
            {[['Pace','5:26'],['Elev','32m'],['Kcal','486']].map((s,i)=>(
              <div key={i}>
                <div style={{ fontSize: 10, letterSpacing: 1, fontWeight: 600, opacity: 0.6 }}>{s[0].toUpperCase()}</div>
                <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight, marginTop: 2 }}>{s[1]}</div>
              </div>
            ))}
          </div>
        </div>
        {/* rate runners */}
        <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 22 }}>Who brought the vibe?</div>
        <div style={{ fontSize: 13, color: theme.ink2, marginTop: 4 }}>Tap people you vibed with. They'll float to the top of your catches deck.</div>
        <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10, marginTop: 14 }}>
          {[
            { s:'r1', name:'Riya', tagged:true },
            { s:'r2', name:'Aarav', tagged:false },
            { s:'r3', name:'Zoya', tagged:true },
            { s:'r4', name:'Kabir', tagged:false },
            { s:'r5', name:'Aisha', tagged:false },
            { s:'r6', name:'Dev', tagged:false },
          ].map(p=>(
            <div key={p.s} style={{ aspectRatio:'3/4', borderRadius: 14, overflow:'hidden', position:'relative', border: p.tagged ? `3px solid ${theme.primary}` : 'none' }}>
              <PhotoBox seed={p.s}/>
              <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg,transparent 50%,rgba(0,0,0,0.7) 100%)' }}/>
              <div style={{ position:'absolute', bottom: 6, left: 8, right: 8, color:'#fff', fontSize: 13, fontWeight: 600 }}>{p.name}</div>
              {p.tagged && <div style={{ position:'absolute', top:8, right:8, width:28, height:28, borderRadius:999, background: theme.primary, display:'flex', alignItems:'center', justifyContent:'center' }}>
                <Icon.check c={theme.primaryInk} s={16}/>
              </div>}
            </div>
          ))}
        </div>
        <Button theme={theme} size="lg" style={{ width:'100%', marginTop: 24 }}>Open catches deck →</Button>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenCatchesIntro, ScreenSwipe, ScreenMatch, ScreenRecap });
