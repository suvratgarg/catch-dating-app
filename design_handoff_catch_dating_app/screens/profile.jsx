// Profile screens (self, other, edit, photo grid)

function ScreenProfileSelf({ theme, type }) {
  return (
    <div data-screen-label="19 Profile Self" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 8px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>You</div>
        <div style={{ display:'flex', gap: 8 }}>
          <IconBtn theme={theme}><Icon.bell c={theme.ink}/></IconBtn>
          <IconBtn theme={theme}><Icon.settings c={theme.ink}/></IconBtn>
        </div>
      </div>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        {/* hero card */}
        <div style={{ position:'relative', borderRadius: 24, overflow: 'hidden', aspectRatio: '4/5' }}>
          <PhotoBox seed="me-hero"/>
          <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0) 40%,rgba(0,0,0,0.8) 100%)' }}/>
          <div style={{ position:'absolute', top: 12, right: 12, padding:'6px 12px', background: 'rgba(255,255,255,0.92)', borderRadius: 999, fontSize: 11, fontWeight: 700, letterSpacing: 0.4, display:'flex', alignItems:'center', gap: 4 }}>
            <Icon.edit c="#000" s={13}/> Edit
          </div>
          <div style={{ position:'absolute', bottom: 18, left: 20, right: 20, color: '#fff' }}>
            <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1 }}>Suvrat, 27</div>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 4 }}>Product designer · Bandra · straight</div>
          </div>
        </div>
        {/* stat strip */}
        <div style={{ marginTop: 14, background: theme.surface, border: `1px solid ${theme.line}`, borderRadius: 16, padding: 16, display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10 }}>
          {[['Runs','18'],['Catches','12'],['PR 10K','48:22']].map((s,i)=>(
            <div key={i} style={{ textAlign:'center', borderRight: i<2?`1px solid ${theme.line}`:'none' }}>
              <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>{s[1]}</div>
              <div style={{ fontSize: 10, color: theme.ink3, textTransform:'uppercase', letterSpacing: 0.6, fontWeight: 600, marginTop: 2 }}>{s[0]}</div>
            </div>
          ))}
        </div>
        {/* prompts */}
        <div style={{ marginTop: 14, padding: 16, background: theme.surface, border: `1px solid ${theme.line}`, borderRadius: 16 }}>
          <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600 }}>On a perfect run</div>
          <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 6, lineHeight: 1.2 }}>
            "…it's 5:45 AM, the city's still yawning, and someone keeps pace without saying a word."
          </div>
        </div>
        {/* pace card */}
        <div style={{ marginTop: 14, padding: 16, background: theme.ink, color: theme.surface, borderRadius: 16 }}>
          <div style={{ fontSize: 11, letterSpacing: 1, fontWeight: 700, opacity: 0.7 }}>MY PACE</div>
          <div style={{ fontFamily: type.display, fontSize: 36, fontWeight: type.displayWeight, marginTop: 4 }}>5:42 <span style={{ fontSize: 16, opacity: 0.7 }}>/km</span></div>
          <div style={{ display:'flex', gap: 6, marginTop: 12, flexWrap:'wrap' }}>
            {['5K','10K','Half','Trail','Coffee after','Sunrise'].map(t=>(
              <div key={t} style={{ padding:'4px 10px', fontSize: 11, fontWeight: 600, borderRadius: 999, background:'rgba(255,255,255,0.15)' }}>{t}</div>
            ))}
          </div>
        </div>
        <Button theme={theme} variant="secondary" size="md" style={{ width:'100%', marginTop: 14 }}>Preview as others see you</Button>
      </div>
      <TabBar theme={theme} type={type} active="profile"/>
    </div>
  );
}

function ScreenProfileOther({ theme, type }) {
  return (
    <div data-screen-label="20 Profile Other" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <div style={{ flex: 1, overflow:'auto' }}>
        {/* hero photo */}
        <div style={{ position:'relative', aspectRatio:'3/4' }}>
          <PhotoBox seed="riya-main"/>
          <StatusBar theme={{...theme, dark:true}}/>
          <div style={{ position:'absolute', top: 50, left: 16, right: 16, display:'flex', justifyContent:'space-between' }}>
            <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.92)', display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.back c="#000"/></div>
            <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.92)', display:'flex', alignItems:'center', justifyContent:'center' }}>
              <svg width="20" height="4" viewBox="0 0 22 6"><circle cx="3" cy="3" r="2.5" fill="#000"/><circle cx="11" cy="3" r="2.5" fill="#000"/><circle cx="19" cy="3" r="2.5" fill="#000"/></svg>
            </div>
          </div>
          <div style={{ position:'absolute', top: 8, left: 40, right: 40, display:'flex', gap: 4 }}>
            {[0,1,2,3].map(i=>(<div key={i} style={{ flex:1, height: 3, borderRadius: 2, background: i===0?'#fff':'rgba(255,255,255,0.35)' }}/>))}
          </div>
          <div style={{ position:'absolute', bottom: 16, left: 20, right: 20, color: '#fff' }}>
            <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
              <div style={{ fontFamily: type.display, fontSize: 34, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1 }}>Riya, 26</div>
            </div>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 6 }}>Architect · Bandra W · 1.2 km away</div>
          </div>
        </div>
        {/* shared run badge */}
        <div style={{ margin: '16px 16px 0', padding: 14, background: theme.primarySoft, borderRadius: 16, color: theme.primary, display:'flex', gap: 12, alignItems:'center' }}>
          <div style={{ width: 44, height:44, borderRadius: 12, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon.route c={theme.primaryInk} s={22}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700 }}>You ran together today</div>
            <div style={{ fontSize: 12, opacity: 0.85 }}>Bandra Breakers 7K · 5:26 & 5:30 /km</div>
          </div>
        </div>
        {/* bio */}
        <div style={{ padding: '16px 20px 0', fontSize: 15, lineHeight: 1.5, color: theme.ink2 }}>
          Architect at Studio Kām. Training for SCMM half. Weekends = long runs, filter coffee, real film cameras.
        </div>
        {/* prompt */}
        <div style={{ margin: '16px 20px 0', padding: 16, background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16 }}>
          <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600 }}>My simple pleasure</div>
          <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 6, lineHeight: 1.25 }}>
            "Silent runs. No podcast, no playlist — just footsteps and the city waking up."
          </div>
        </div>
        {/* second photo */}
        <div style={{ margin: '16px 20px 0', aspectRatio: '3/4', borderRadius: 20, overflow:'hidden' }}>
          <PhotoBox seed="riya-2"/>
        </div>
        {/* vitals */}
        <div style={{ padding: '16px 20px 0' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight, marginBottom: 10 }}>The vitals</div>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(2,1fr)', gap: 10 }}>
            {[['Pace','5:15/km'],['Height','5\'6"'],['Runs','47'],['PR','1:52 half']].map((s,i)=>(
              <div key={i} style={{ padding: 12, background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 12 }}>
                <div style={{ fontSize: 10, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600 }}>{s[0]}</div>
                <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2 }}>{s[1]}</div>
              </div>
            ))}
          </div>
        </div>
        {/* interests */}
        <div style={{ padding: '16px 20px 120px' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight, marginBottom: 10 }}>Runs her way</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['5:15 /km','Half ×3','Silent runs','Espresso','Film photos','Sunrise only','Hill repeats'].map(t=>(
              <Chip key={t} theme={theme}>{t}</Chip>
            ))}
          </div>
        </div>
      </div>
      {/* floating action dock */}
      <div style={{ position:'absolute', bottom: 28, left: 0, right: 0, display:'flex', justifyContent:'center', gap: 14 }}>
        <div style={{ width:56, height:56, borderRadius:999, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 10px 24px rgba(0,0,0,0.18)', border:`1px solid ${theme.line}` }}>
          <Icon.x c={theme.pass} s={22}/>
        </div>
        <div style={{ width:72, height:72, borderRadius:999, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 14px 28px rgba(0,0,0,0.25)' }}>
          <Icon.heart c={theme.primaryInk} s={32} filled/>
        </div>
        <div style={{ width:56, height:56, borderRadius:999, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 10px 24px rgba(0,0,0,0.18)', border:`1px solid ${theme.line}` }}>
          <Icon.chat c={theme.ink} s={22}/>
        </div>
      </div>
    </div>
  );
}

function ScreenEditProfile({ theme, type }) {
  return (
    <div data-screen-label="21 Edit Profile" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} title="Edit profile" left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>} right={<div style={{ color: theme.primary, fontWeight: 600, padding:'6px 12px' }}>Done</div>}/>
      <div style={{ flex: 1, overflow:'auto', padding: '4px 0 20px' }}>
        {/* photos */}
        <div style={{ padding: '12px 20px 20px' }}>
          <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600, marginBottom: 10 }}>Photos · drag to reorder</div>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 8 }}>
            {[0,1,2,3,4,5].map(i=>(
              <div key={i} style={{ aspectRatio:'3/4', borderRadius: 12, overflow:'hidden', position:'relative', background: theme.raised, border: i<4?'none':`1.5px dashed ${theme.line2}` }}>
                {i<4 ? <PhotoBox seed={`me-e-${i}`}/> : (
                  <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.plus c={theme.ink3} s={24}/></div>
                )}
                {i===0 && <div style={{ position:'absolute', top:6, left:6, padding:'2px 7px', fontSize: 9, fontWeight: 700, borderRadius:999, background: theme.primary, color: theme.primaryInk, letterSpacing: 0.4, textTransform:'uppercase' }}>Main</div>}
              </div>
            ))}
          </div>
        </div>
        {/* sections */}
        {[
          { h:'About you', items:[['Name','Suvrat'],['Age','27'],['Pronouns','he/him'],['Height','5\'10"']] },
          { h:'Your running', items:[['Pace','5:42/km'],['Favourite distances','5K, 10K, Half'],['PR 10K','48:22']] },
          { h:'The vibe', items:[['Work','Product designer'],['Education','IIT Bombay'],['Location','Bandra W · Mumbai']] },
        ].map(sec=>(
          <div key={sec.h} style={{ marginBottom: 18 }}>
            <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600, padding:'0 20px 8px' }}>{sec.h}</div>
            <div style={{ background: theme.surface, borderTop: `1px solid ${theme.line}`, borderBottom: `1px solid ${theme.line}` }}>
              {sec.items.map((it,i)=>(
                <div key={i} style={{
                  padding: '14px 20px', display:'flex', justifyContent:'space-between', alignItems:'center',
                  borderBottom: i<sec.items.length-1?`1px solid ${theme.line}`:'none',
                }}>
                  <div style={{ fontSize: 15 }}>{it[0]}</div>
                  <div style={{ fontSize: 15, color: theme.ink2, display:'flex', alignItems:'center', gap:6 }}>{it[1]}
                    <svg width="8" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" stroke={theme.ink3} strokeWidth="2" fill="none" strokeLinecap="round"/></svg>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { ScreenProfileSelf, ScreenProfileOther, ScreenEditProfile });
