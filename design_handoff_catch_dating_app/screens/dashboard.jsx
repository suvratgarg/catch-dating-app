// Home / Dashboard — personal hub, not a feed.
// Shows: next run, active catches, personal stride, quick actions.

function ScreenDashboard({ theme, type }) {
  return (
    <div data-screen-label="25 Dashboard" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 10px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontSize: 11, color: theme.ink3, fontFamily: type.text, letterSpacing: 1, fontWeight: 600, textTransform:'uppercase' }}>Thursday · Mumbai</div>
          <div style={{ fontFamily: type.display, fontSize: 26, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Morning, Suvrat</div>
        </div>
        <div style={{ width: 42, height: 42, borderRadius: 999, overflow: 'hidden', border: `2px solid ${theme.primary}` }}>
          <PhotoBox seed="me-hero"/>
        </div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 20px' }}>
        {/* Next run countdown — hero */}
        <div style={{
          position: 'relative', borderRadius: 22, overflow:'hidden',
          background: theme.ink, color: theme.surface, padding: 18,
        }}>
          <div style={{ position:'absolute', inset:0, opacity: 0.25 }}>
            <MiniMap theme={{...theme, dark: true}} height={220} />
          </div>
          <div style={{ position:'relative' }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.4, opacity: 0.75 }}>
              ● NEXT RUN · IN 14 HOURS
            </div>
            <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 8 }}>
              Bandra Breakers<br/>Sunrise Seawall 7K
            </div>
            <div style={{ display:'flex', gap: 14, fontSize: 12, marginTop: 10, opacity: 0.85 }}>
              <span style={{ display:'inline-flex', alignItems:'center', gap: 4 }}><Icon.clock s={13} c={theme.surface}/>Tomorrow 6:00 AM</span>
              <span style={{ display:'inline-flex', alignItems:'center', gap: 4 }}><Icon.pin s={13} c={theme.surface}/>Carter Road</span>
            </div>
            <div style={{ display:'flex', marginTop: 14, alignItems:'center', gap: 10 }}>
              <div style={{ display:'flex' }}>
                {[0,1,2,3].map(i=>(
                  <div key={i} style={{ width: 28, height: 28, borderRadius:999, marginLeft: i===0?0:-8, border:`2px solid ${theme.ink}`, overflow:'hidden' }}>
                    <PhotoBox seed={`d-${i}`}/>
                  </div>
                ))}
              </div>
              <div style={{ fontSize: 12, opacity: 0.85 }}>23 runners confirmed · <b style={{ color: theme.primary }}>3 might be a match</b></div>
            </div>
          </div>
        </div>

        {/* Live catches still open */}
        <div style={{ marginTop: 18, background: theme.primary, color: theme.primaryInk, borderRadius: 18, padding: 16, display:'flex', alignItems:'center', gap: 12 }}>
          <div style={{ width: 46, height: 46, borderRadius: 999, background: 'rgba(255,255,255,0.2)', display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon.heart c={theme.primaryInk} s={22} filled/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1, opacity: 0.85 }}>SWIPE WINDOW CLOSING · 6h 41m</div>
            <div style={{ fontFamily: type.display, fontSize: 17, fontWeight: type.displayWeight, marginTop: 2 }}>11 unswiped from today's 7K</div>
          </div>
          <svg width="14" height="20" viewBox="0 0 14 20"><path d="M2 2l10 8-10 8" stroke={theme.primaryInk} strokeWidth="2.2" fill="none" strokeLinecap="round"/></svg>
        </div>

        {/* Quick actions */}
        <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10, marginTop: 14 }}>
          {[
            { i:'grid', l:'Browse runs' },
            { i:'map', l:'Map view' },
            { i:'calendar', l:'Calendar' },
          ].map((a,i)=>(
            <div key={i} style={{
              padding: 14, background: theme.surface, border:`1px solid ${theme.line}`,
              borderRadius: 16, display:'flex', flexDirection:'column', gap: 8,
            }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: theme.primarySoft, color: theme.primary, display:'flex', alignItems:'center', justifyContent:'center' }}>
                {React.createElement(Icon[a.i], { c: theme.primary, s: 18 })}
              </div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>{a.l}</div>
            </div>
          ))}
        </div>

        {/* Stride card */}
        <div style={{ marginTop: 18, padding: 18, background: theme.surface, borderRadius: 18, border: `1px solid ${theme.line}` }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
            <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>Your stride · this week</div>
            <div style={{ fontSize: 11, color: theme.primary, fontWeight: 700 }}>↗ +4.3%</div>
          </div>
          <div style={{ display:'flex', alignItems:'baseline', gap: 6, marginTop: 8 }}>
            <div style={{ fontFamily: type.display, fontSize: 36, fontWeight: type.displayWeight, letterSpacing: -1 }}>28.4</div>
            <div style={{ fontSize: 13, color: theme.ink3, fontWeight: 500 }}>km · 3 runs</div>
          </div>
          {/* weekly bars */}
          <div style={{ display:'flex', gap: 6, alignItems:'flex-end', height: 58, marginTop: 10 }}>
            {[0.1,0,0.7,0,0.3,0.9,0.5].map((h,i)=>(
              <div key={i} style={{ flex: 1, display:'flex', flexDirection:'column', alignItems:'center', gap: 4 }}>
                <div style={{ flex: 1, width: '100%', display:'flex', alignItems:'flex-end' }}>
                  <div style={{
                    width: '100%',
                    height: `${Math.max(h*100, 4)}%`,
                    background: h>0 ? theme.primary : theme.line2,
                    borderRadius: 4,
                    opacity: i===6?0.5:1,
                  }}/>
                </div>
                <div style={{ fontSize: 9, color: theme.ink3, fontWeight: 600, letterSpacing: 0.4 }}>
                  {['M','T','W','T','F','S','S'][i]}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recommended */}
        <div style={{ marginTop: 22 }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
            <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>Because you ran the 7K</div>
            <div style={{ fontSize: 12, color: theme.ink2, fontWeight: 600 }}>See all</div>
          </div>
          <div style={{ display:'flex', gap: 10, overflowX:'auto', marginTop: 10, paddingBottom: 4 }}>
            {[
              { club:'Koregaon Kicks', dist:'5K', when:'Sat 6AM', seed:'kk-r' },
              { club:'Pali Hills Pack', dist:'10K', when:'Sun 5:30AM', seed:'phn-r' },
              { club:'Juhu Dawn Run', dist:'8K', when:'Mon 6AM', seed:'jdr-r' },
            ].map((r,i)=>(
              <div key={i} style={{ flexShrink: 0, width: 180, borderRadius: 14, overflow:'hidden', background: theme.surface, border: `1px solid ${theme.line}` }}>
                <div style={{ height: 86, position:'relative' }}>
                  <PhotoBox seed={r.seed}/>
                  <div style={{ position:'absolute', top: 8, left: 8, padding:'3px 8px', background: 'rgba(255,255,255,0.95)', borderRadius: 999, fontSize: 10, fontWeight: 700, color:'#000', letterSpacing: 0.3 }}>{r.dist}</div>
                </div>
                <div style={{ padding: 10 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{r.club}</div>
                  <div style={{ fontSize: 11, color: theme.ink3, marginTop: 2 }}>{r.when}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

// Dashboard empty state — first run not booked yet
function ScreenDashboardEmpty({ theme, type }) {
  return (
    <div data-screen-label="26 Dashboard Empty" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 10px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 1, fontWeight: 600, textTransform:'uppercase' }}>Welcome to Catch</div>
          <div style={{ fontFamily: type.display, fontSize: 26, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Let's find your first run</div>
        </div>
        <div style={{ width: 42, height: 42, borderRadius: 999, overflow: 'hidden', border: `2px dashed ${theme.line2}` }}/>
      </div>
      <div style={{ flex:1, overflow:'auto', padding: '4px 20px 20px' }}>
        {/* CTA card */}
        <div style={{ borderRadius: 22, background: theme.heroGrad, color: '#fff', padding: 22, position:'relative', overflow:'hidden' }}>
          <svg viewBox="0 0 200 200" style={{ position:'absolute', right:-40, top:-40, width: 200, height: 200, opacity: 0.25 }}>
            <circle cx="100" cy="100" r="80" stroke="#fff" strokeWidth="1" fill="none"/>
            <circle cx="100" cy="100" r="60" stroke="#fff" strokeWidth="1" fill="none"/>
            <circle cx="100" cy="100" r="40" stroke="#fff" strokeWidth="1" fill="none"/>
          </svg>
          <div style={{ position: 'relative' }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.4, opacity: 0.9 }}>● NO RUNS BOOKED</div>
            <div style={{ fontFamily: type.display, fontSize: 26, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.1, marginTop: 10 }}>
              Your catches unlock after your first run.
            </div>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 8, lineHeight: 1.5 }}>
              Book a group run. Show up. Meet people. Then we'll hand you the roster.
            </div>
            <div style={{ marginTop: 16 }}>
              <Button theme={{...theme, primary:'#fff', primaryInk: theme.ink}} size="md">Find a run near me</Button>
            </div>
          </div>
        </div>
        {/* Steps */}
        <div style={{ marginTop: 20 }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight, marginBottom: 10 }}>How Catch works</div>
          {[
            { n:'01', t:'Book a group run', d:'Pick a club near you. Pay the fee (or don\'t — some are free).' },
            { n:'02', t:'Actually show up', d:'Run with the club. No swiping happens here. Just run.' },
            { n:'03', t:'Swipe within 24 hours', d:'You get the roster of who ran. Catch anyone who caught your eye.' },
            { n:'04', t:'They catch you back?', d:'Match. Message. Plan the next run together.' },
          ].map((s,i)=>(
            <div key={i} style={{ display:'flex', gap: 14, padding: '14px 0', borderBottom: i<3?`1px solid ${theme.line}`:'none' }}>
              <div style={{ fontFamily: type.mono, fontSize: 13, fontWeight: 700, color: theme.primary, letterSpacing: 0.5, paddingTop: 2 }}>{s.n}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{s.t}</div>
                <div style={{ fontSize: 13, color: theme.ink2, marginTop: 3, lineHeight: 1.4 }}>{s.d}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

Object.assign(window, { ScreenDashboard, ScreenDashboardEmpty });
