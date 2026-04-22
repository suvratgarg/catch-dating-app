// Filters, notifications, settings screens

function ScreenFilters({ theme, type }) {
  return (
    <div data-screen-label="22 Filters" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} title="Filters" left={<IconBtn theme={theme}><Icon.x c={theme.ink}/></IconBtn>} right={<div style={{ fontSize: 13, color: theme.ink2, fontWeight: 600 }}>Reset</div>}/>
      <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 20px' }}>
        {/* distance */}
        <Section theme={theme} label="Distance from you">
          <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>5 km</div>
          <div style={{ height: 6, background: theme.line2, borderRadius: 999, marginTop: 14, position:'relative' }}>
            <div style={{ position:'absolute', left: 0, width:'28%', height:'100%', background: theme.primary, borderRadius:999 }}/>
            <div style={{ position:'absolute', left:'28%', width:18, height:18, top:-6, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.2)' }}/>
          </div>
          <div style={{ display:'flex', justifyContent:'space-between', fontSize: 11, color: theme.ink3, marginTop: 8, fontFamily: type.mono, letterSpacing: 0.5 }}>
            <span>1 KM</span><span>25 KM</span>
          </div>
        </Section>
        {/* pace */}
        <Section theme={theme} label="Pace range">
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
            <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>4:30 — 6:30 /km</div>
            <div style={{ fontSize: 11, color: theme.ink3 }}>matches 68% of your pace</div>
          </div>
          <div style={{ height: 6, background: theme.line2, borderRadius: 999, marginTop: 14, position:'relative' }}>
            <div style={{ position:'absolute', left:'22%', width:'46%', height:'100%', background: theme.primary, borderRadius:999 }}/>
            <div style={{ position:'absolute', left:'22%', width:18, height:18, top:-6, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.2)' }}/>
            <div style={{ position:'absolute', left:'68%', width:18, height:18, top:-6, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.2)' }}/>
          </div>
        </Section>
        <Section theme={theme} label="Age">
          <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>24 — 31</div>
        </Section>
        <Section theme={theme} label="Interested in">
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['Women','Men','Everyone'].map((g,i)=>(
              <Chip key={g} theme={theme} active={i===0}>{g}</Chip>
            ))}
          </div>
        </Section>
        <Section theme={theme} label="Run type">
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['5K','10K','Half','Full','Trail','Track','Social jog'].map((g,i)=>(
              <Chip key={g} theme={theme} active={[0,1,2].includes(i)}>{g}</Chip>
            ))}
          </div>
        </Section>
        <Section theme={theme} label="Vibe">
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['Sunrise','Evening','Silent run','Chatty','Coffee after','Post-run stretch'].map((g,i)=>(
              <Chip key={g} theme={theme} active={[0,4].includes(i)}>{g}</Chip>
            ))}
          </div>
        </Section>
        <Section theme={theme} label="Only show verified runners">
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
            <div style={{ fontSize: 13, color: theme.ink2, flex:1, paddingRight: 12 }}>At least one completed run on Catch.</div>
            <Toggle theme={theme} on/>
          </div>
        </Section>
      </div>
      <div style={{ padding: '12px 16px 24px', borderTop:`1px solid ${theme.line}`, background: theme.surface }}>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>See 47 runs →</Button>
      </div>
    </div>
  );
}

function Section({ theme, label, children }) {
  return (
    <div style={{ padding: '18px 0', borderBottom: `1px solid ${theme.line}` }}>
      <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600, marginBottom: 10 }}>{label}</div>
      {children}
    </div>
  );
}

function Toggle({ theme, on }) {
  return (
    <div style={{
      width: 46, height: 28, borderRadius: 999,
      background: on ? theme.primary : theme.line2, position: 'relative',
    }}>
      <div style={{ position:'absolute', top: 2, left: on?20:2, width: 24, height: 24, borderRadius: 999, background:'#fff', boxShadow:'0 1px 3px rgba(0,0,0,0.2)' }}/>
    </div>
  );
}

function ScreenNotifications({ theme, type }) {
  const days = [
    { when:'Today', items:[
      { kind:'catch', text:'It\'s a catch! Riya also caught you.', sub:'Bandra Breakers 7K · 2 min ago', seed:'riya-n', pri:true },
      { kind:'like', text:'Aarav liked your profile.', sub:'Lodhi Night Owls · 1 h ago', seed:'aarav-nn' },
      { kind:'run', text:'Your run starts in 15 minutes', sub:'Carter Road · Bandra Breakers', seed:null, icon:'bell' },
    ]},
    { when:'Yesterday', items:[
      { kind:'message', text:'Zoya sent you a message', sub:'"I can do 5:30 pace"', seed:'zoya-n' },
      { kind:'run', text:'A new run near you', sub:'Lodhi Night Owls · Wed 7:30 PM', seed:null, icon:'route' },
    ]},
    { when:'This week', items:[
      { kind:'like', text:'3 new people caught you', sub:'Check your catches tab', seed:null, icon:'heart' },
    ]},
  ];
  return (
    <div data-screen-label="23 Notifications" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 8px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Activity</div>
        <div style={{ fontSize: 13, color: theme.ink2, fontWeight: 600 }}>Mark all read</div>
      </div>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        {days.map(d=>(
          <div key={d.when} style={{ marginBottom: 18 }}>
            <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600, marginBottom: 10 }}>{d.when}</div>
            {d.items.map((it,i)=>(
              <div key={i} style={{
                display:'flex', gap: 12, padding: '10px 0',
                borderBottom: i<d.items.length-1?`1px solid ${theme.line}`:'none',
              }}>
                {it.seed ? (
                  <div style={{ width: 44, height: 44, borderRadius: 999, overflow:'hidden', position:'relative', flexShrink: 0 }}>
                    <PhotoBox seed={it.seed}/>
                    {it.pri && <div style={{ position:'absolute', bottom:-2, right:-2, width:18, height:18, borderRadius:999, background: theme.primary, border:`2px solid ${theme.bg}`, display:'flex', alignItems:'center', justifyContent:'center' }}>
                      <Icon.heart c={theme.primaryInk} s={10} filled/>
                    </div>}
                  </div>
                ) : (
                  <div style={{ width: 44, height: 44, borderRadius: 999, background: theme.primarySoft, color: theme.primary, display:'flex', alignItems:'center', justifyContent:'center', flexShrink: 0 }}>
                    {it.icon==='bell' ? <Icon.bell c={theme.primary}/> : it.icon==='route' ? <Icon.route c={theme.primary}/> : <Icon.heart c={theme.primary} filled/>}
                  </div>
                )}
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: it.pri?700:500, color: theme.ink }}>{it.text}</div>
                  <div style={{ fontSize: 12, color: theme.ink2, marginTop: 2 }}>{it.sub}</div>
                </div>
                {it.pri && <div style={{ fontSize: 11, fontWeight: 700, color: theme.primary, alignSelf:'center' }}>→</div>}
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

function ScreenSettings({ theme, type }) {
  const groups = [
    { h:'Account', items:[
      { l:'Phone', v:'+91 ••• 04222' },
      { l:'Email', v:'suvrat@example.com' },
      { l:'Razorpay', v:'Connected', ok:true },
    ]},
    { h:'Discovery', items:[
      { l:'Who can see me', v:'Runners on my runs' },
      { l:'Show me on map', toggle:true, on:true },
      { l:'Snooze profile', v:'Off' },
    ]},
    { h:'Notifications', items:[
      { l:'New catches', toggle:true, on:true },
      { l:'Run reminders', toggle:true, on:true },
      { l:'Weekly digest', toggle:true, on:false },
    ]},
    { h:'Safety', items:[
      { l:'Blocked runners', v:'2' },
      { l:'Safety center', v:'→' },
      { l:'Verify I\'m real', v:'Recommended', ok:true },
    ]},
    { h:'About', items:[
      { l:'Help & support', v:'→' },
      { l:'Privacy', v:'→' },
      { l:'Terms', v:'→' },
    ]},
  ];
  return (
    <div data-screen-label="24 Settings" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} title="Settings" left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>}/>
      <div style={{ flex:1, overflow:'auto', padding: '4px 0 40px' }}>
        {groups.map(g=>(
          <div key={g.h} style={{ marginBottom: 20 }}>
            <div style={{ fontSize: 11, color: theme.ink3, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600, padding:'0 20px 8px' }}>{g.h}</div>
            <div style={{ background: theme.surface, borderTop: `1px solid ${theme.line}`, borderBottom: `1px solid ${theme.line}` }}>
              {g.items.map((it,i)=>(
                <div key={i} style={{
                  padding: '14px 20px', display:'flex', justifyContent:'space-between', alignItems:'center',
                  borderBottom: i<g.items.length-1?`1px solid ${theme.line}`:'none',
                }}>
                  <div style={{ fontSize: 15 }}>{it.l}</div>
                  {it.toggle ? <Toggle theme={theme} on={it.on}/> : (
                    <div style={{ fontSize: 14, color: it.ok?theme.primary:theme.ink2, fontWeight: it.ok?600:400 }}>{it.v}</div>
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}
        <div style={{ padding: '0 20px' }}>
          <div style={{ padding:14, textAlign:'center', color:'#d43c3c', fontWeight: 600, fontSize: 15, background: theme.surface, borderRadius: 12, border:`1px solid ${theme.line}` }}>Log out</div>
          <div style={{ textAlign:'center', fontSize: 11, color: theme.ink3, marginTop: 20 }}>Catch v1.0 · made with 🏃 in Bombay</div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenFilters, ScreenNotifications, ScreenSettings, Toggle });
