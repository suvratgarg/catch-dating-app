// Clubs-first main tab — 3 layout variants

// Variant A — Spotify-style: For you / Joined / Nearby rows
function ScreenClubsRows({ theme, type }) {
  const joined = [
    { name:'Bandra Breakers', sub:'Next: Tomorrow 6AM', seed:'bbrc', tag:'EASY' },
    { name:'Lodhi Night Owls', sub:'Next: Wed 7:30PM', seed:'lno', tag:'SOCIAL' },
    { name:'Cubbon Striders', sub:'Next: Sat 5:30AM', seed:'cps', tag:'FAST' },
  ];
  const forYou = [
    { name:'Marina Milers', sub:'312 members · Chennai', seed:'mm', tag:'BEGINNER' },
    { name:'Koregaon Kicks', sub:'156 members · Pune', seed:'kk', tag:'SOCIAL' },
    { name:'Pali Hills Pack', sub:'89 members · Mumbai', seed:'php', tag:'HILLS' },
  ];
  const nearby = [
    { name:'Juhu Dawn Run', sub:'1.4 km away', seed:'jdr' },
    { name:'Linking Rd Loopers', sub:'2.1 km away', seed:'lrl' },
  ];
  return (
    <div data-screen-label="27 Clubs · Rows" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 8px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div>
          <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Run clubs</div>
          <div style={{ fontSize: 13, color: theme.ink2, marginTop: 2 }}>Find your people. Catch your person.</div>
        </div>
        <IconBtn theme={theme}><Icon.search c={theme.ink}/></IconBtn>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '6px 0 20px' }}>
        {/* Joined clubs — horizontal scroll */}
        <div style={{ padding: '10px 20px 4px', display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>Your clubs</div>
          <div style={{ fontSize: 12, color: theme.ink2, fontWeight: 600 }}>See all ({joined.length})</div>
        </div>
        <div style={{ display:'flex', gap: 10, overflowX:'auto', padding: '6px 20px 6px' }}>
          {joined.map(c=>(
            <div key={c.name} style={{ flexShrink: 0, width: 220, background: theme.surface, border: `1px solid ${theme.line}`, borderRadius: 16, overflow: 'hidden' }}>
              <div style={{ height: 110, position: 'relative' }}>
                <PhotoBox seed={c.seed}/>
                <div style={{ position:'absolute', top: 8, left: 8, padding:'3px 8px', fontSize: 10, fontWeight: 700, background: theme.primary, color: theme.primaryInk, borderRadius: 999, letterSpacing: 0.5 }}>{c.tag}</div>
                <div style={{ position:'absolute', top: 8, right: 8, width: 24, height: 24, borderRadius: 999, background:'rgba(255,255,255,0.95)', display:'flex', alignItems:'center', justifyContent:'center' }}>
                  <Icon.check c="#000" s={14}/>
                </div>
              </div>
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{c.name}</div>
                <div style={{ fontSize: 11, color: theme.primary, marginTop: 2, fontWeight: 600 }}>{c.sub}</div>
              </div>
            </div>
          ))}
        </div>

        {/* For you */}
        <div style={{ padding: '14px 20px 4px', display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>For you</div>
          <div style={{ fontSize: 12, color: theme.ink2, fontWeight: 600 }}>See all</div>
        </div>
        <div style={{ display:'flex', gap: 10, overflowX:'auto', padding: '6px 20px 6px' }}>
          {forYou.map(c=>(
            <div key={c.name} style={{ flexShrink: 0, width: 160, borderRadius: 16, overflow:'hidden' }}>
              <div style={{ height: 160, borderRadius: 16, overflow:'hidden', position:'relative' }}>
                <PhotoBox seed={c.seed}/>
                <div style={{ position:'absolute', inset:0, background: 'linear-gradient(180deg,transparent 40%,rgba(0,0,0,0.8) 100%)' }}/>
                <div style={{ position:'absolute', bottom: 10, left: 10, right: 10, color:'#fff' }}>
                  <div style={{ fontSize: 10, fontWeight: 700, opacity: 0.85, letterSpacing: 0.5 }}>{c.tag}</div>
                  <div style={{ fontSize: 14, fontWeight: 600, marginTop: 2 }}>{c.name}</div>
                  <div style={{ fontSize: 10, opacity: 0.85, marginTop: 1 }}>{c.sub}</div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Nearby */}
        <div style={{ padding: '14px 20px 4px' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>Nearby</div>
        </div>
        <div style={{ padding: '6px 20px 0' }}>
          {nearby.map((c,i)=>(
            <div key={c.name} style={{ padding: '12px 0', borderBottom: i<nearby.length-1?`1px solid ${theme.line}`:'none', display:'flex', gap: 12, alignItems:'center' }}>
              <div style={{ width: 54, height: 54, borderRadius: 12, overflow:'hidden', flexShrink: 0 }}>
                <PhotoBox seed={c.seed}/>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{c.name}</div>
                <div style={{ fontSize: 12, color: theme.ink2 }}>{c.sub}</div>
              </div>
              <Chip theme={theme}>Follow</Chip>
            </div>
          ))}
        </div>
      </div>
      <TabBar theme={theme} type={type} active="clubs"/>
    </div>
  );
}

// Variant B — Clubs chip-scroll on top + upcoming-runs feed below
function ScreenClubsFeed({ theme, type }) {
  const clubs = [
    { name:'All', seed:null, active:true },
    { name:'Bandra Breakers', seed:'bbrc' },
    { name:'Lodhi Owls', seed:'lno' },
    { name:'Cubbon', seed:'cps' },
    { name:'Marina', seed:'mm' },
  ];
  const runs = [
    { club:'Bandra Breakers', clubSeed:'bbrc', dist:'7K', pace:'5:30', time:'Tomorrow 6:00 AM', spots:6, price:'₹299', seed:'r1' },
    { club:'Lodhi Night Owls', clubSeed:'lno', dist:'5K', pace:'6:00', time:'Wed 7:30 PM', spots:8, price:'Free', seed:'r2' },
    { club:'Cubbon Striders', clubSeed:'cps', dist:'10K', pace:'5:00', time:'Sat 5:30 AM', spots:2, price:'₹249', hot:true, seed:'r3' },
    { club:'Bandra Breakers', clubSeed:'bbrc', dist:'12K', pace:'5:45', time:'Sun 6:00 AM', spots:14, price:'₹349', seed:'r4' },
  ];
  return (
    <div data-screen-label="28 Clubs · Feed" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 6px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Clubs</div>
        <div style={{ display:'flex', gap: 8 }}>
          <IconBtn theme={theme}><Icon.search c={theme.ink}/></IconBtn>
          <IconBtn theme={theme}><Icon.calendar c={theme.ink} s={18}/></IconBtn>
        </div>
      </div>
      {/* clubs chip row */}
      <div style={{ display:'flex', gap: 10, overflowX:'auto', padding: '6px 16px 10px' }}>
        {clubs.map((c,i)=>(
          <div key={i} style={{
            flexShrink: 0, display:'flex', flexDirection:'column', alignItems:'center', gap: 4, width: 64,
          }}>
            <div style={{
              width: 58, height: 58, borderRadius: 999, overflow:'hidden',
              border: c.active ? `3px solid ${theme.primary}` : `1px solid ${theme.line2}`,
              padding: c.active ? 2 : 0,
              background: theme.surface,
            }}>
              <div style={{ width:'100%', height: '100%', borderRadius: 999, overflow:'hidden',
                   background: c.seed?undefined:theme.ink, color: theme.surface,
                   display: c.seed?'block':'flex', alignItems:'center', justifyContent:'center', fontSize: 11, fontWeight: 700 }}>
                {c.seed ? <PhotoBox seed={c.seed}/> : 'ALL'}
              </div>
            </div>
            <div style={{ fontSize: 10, fontWeight: 600, color: c.active?theme.primary:theme.ink2, textAlign:'center', lineHeight: 1.1, width:'100%', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{c.name}</div>
          </div>
        ))}
      </div>
      {/* filter strip */}
      <div style={{ display:'flex', gap: 6, padding: '0 20px 10px' }}>
        {['This week','Today','Free','5–10K'].map((c,i)=>(<Chip key={c} theme={theme} active={i===0}>{c}</Chip>))}
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 20px', display:'flex', flexDirection:'column', gap: 12 }}>
        {runs.map((r,i)=>(
          <div key={i} style={{
            background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16,
            padding: 14, display:'flex', gap: 12, alignItems:'center',
          }}>
            <div style={{ width: 58, height: 58, borderRadius: 14, overflow:'hidden', flexShrink:0, position:'relative' }}>
              <PhotoBox seed={r.clubSeed}/>
              {r.hot && <div style={{ position:'absolute', bottom: 0, left: 0, right: 0, background: theme.primary, color: theme.primaryInk, fontSize: 8, fontWeight: 700, textAlign:'center', padding:2, letterSpacing: 0.3 }}>2 LEFT</div>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 600, letterSpacing: 0.4, textTransform:'uppercase' }}>{r.club}</div>
              <div style={{ fontSize: 15, fontWeight: 600, marginTop: 2 }}>{r.dist} · {r.pace}/km · {r.time}</div>
              <div style={{ fontSize: 11, color: theme.ink2, marginTop: 4, display:'flex', gap:10 }}>
                <span><Icon.users c={theme.ink2} s={11}/> {30 - r.spots}/30</span>
                <span style={{ fontWeight: 700, color: r.price==='Free'?theme.accent:theme.ink }}>{r.price}</span>
              </div>
            </div>
            <div style={{ width: 32, height: 32, borderRadius: 999, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center' }}>
              <Icon.plus c={theme.primaryInk} s={16}/>
            </div>
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="clubs"/>
    </div>
  );
}

// Variant C — Directory grid (large cards with vibe tags + recent activity)
function ScreenClubsGrid({ theme, type }) {
  const clubs = [
    { name:'Bandra Breakers RC', loc:'Bandra · Mumbai', members: 420, rating: 4.9, next:'Tomorrow 6AM', tags:['easy','social'], seed:'bbrc', joined:true, activity:[0,1,2,3] },
    { name:'Cubbon Striders', loc:'Cubbon · Bangalore', members: 512, rating: 4.9, next:'Sat 5:30AM', tags:['fast','pr'], seed:'cps', joined:true, activity:[0,1,2] },
    { name:'Marina Milers', loc:'Marina · Chennai', members: 198, rating: 4.7, next:'Thu 6PM', tags:['beginner','coastal'], seed:'mm', activity:[0,1,2,3,4] },
    { name:'Pali Hills Pack', loc:'Bandra · Mumbai', members: 89, rating: 4.8, next:'Sun 5:30AM', tags:['hills','small'], seed:'php', activity:[0,1] },
  ];
  return (
    <div data-screen-label="29 Clubs · Grid" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 6px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Clubs</div>
        <div style={{ display:'flex', gap: 6, background: theme.raised, padding: 3, borderRadius: 10, border:`1px solid ${theme.line}` }}>
          <div style={{ padding:'6px 8px', borderRadius: 7, background: theme.ink, color: theme.surface }}><Icon.grid c={theme.surface} s={14}/></div>
          <div style={{ padding:'6px 8px' }}><Icon.list c={theme.ink2} s={14}/></div>
        </div>
      </div>
      <div style={{ padding: '2px 20px 8px', display:'flex', gap: 8 }}>
        {['All','Joined','Nearby','Popular'].map((c,i)=>(<Chip key={c} theme={theme} active={i===0}>{c}</Chip>))}
      </div>
      <div style={{ flex: 1, overflow:'auto', padding: '4px 20px 20px' }}>
        {clubs.map((c,i)=>(
          <div key={i} style={{
            background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 18,
            padding: 0, marginBottom: 14, overflow:'hidden',
          }}>
            <div style={{ height: 140, position:'relative' }}>
              <PhotoBox seed={c.seed}/>
              <div style={{ position:'absolute', inset:0, background: 'linear-gradient(180deg,rgba(0,0,0,0.25) 0%,rgba(0,0,0,0) 40%,rgba(0,0,0,0.1) 100%)' }}/>
              {c.joined && (
                <div style={{ position:'absolute', top: 10, left: 10, padding:'4px 10px', background:'rgba(255,255,255,0.95)', color:'#000', borderRadius: 999, fontSize: 10, fontWeight: 700, letterSpacing: 0.5, display:'flex', alignItems:'center', gap: 4 }}>
                  <Icon.check c="#000" s={12}/> JOINED
                </div>
              )}
              <div style={{ position:'absolute', top: 10, right: 10, padding:'4px 10px', background:'rgba(0,0,0,0.7)', color:'#fff', borderRadius: 999, fontSize: 10, fontWeight: 700, letterSpacing: 0.3 }}>
                NEXT: {c.next}
              </div>
            </div>
            <div style={{ padding: 14 }}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
                <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>{c.name}</div>
                <div style={{ fontSize: 12, color: theme.ink2, display:'flex', alignItems:'center', gap: 3 }}>
                  <Icon.star c={theme.gold} s={12}/>{c.rating}
                </div>
              </div>
              <div style={{ fontSize: 12, color: theme.ink2, marginTop: 2 }}>{c.loc} · {c.members} runners</div>
              <div style={{ display:'flex', gap: 6, marginTop: 10 }}>
                {c.tags.map(t=>(
                  <div key={t} style={{ padding:'3px 8px', fontSize: 10, fontWeight: 700, letterSpacing: 0.4, background: theme.primarySoft, color: theme.primary, borderRadius: 999, textTransform:'uppercase' }}>{t}</div>
                ))}
              </div>
              {/* recent activity */}
              <div style={{ marginTop: 12, display:'flex', alignItems:'center', gap: 8, paddingTop: 12, borderTop: `1px solid ${theme.line}` }}>
                <div style={{ display:'flex' }}>
                  {c.activity.slice(0,4).map((_,j)=>(
                    <div key={j} style={{ width: 20, height: 20, borderRadius: 4, overflow:'hidden', marginLeft: j===0?0:-4, border:`1.5px solid ${theme.surface}` }}>
                      <PhotoBox seed={`${c.seed}-ra-${j}`}/>
                    </div>
                  ))}
                </div>
                <div style={{ fontSize: 11, color: theme.ink2, flex: 1 }}>Photos from yesterday's run</div>
                <svg width="10" height="14" viewBox="0 0 10 14"><path d="M2 2l6 5-6 5" stroke={theme.ink3} strokeWidth="1.8" fill="none" strokeLinecap="round"/></svg>
              </div>
            </div>
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="clubs"/>
    </div>
  );
}

Object.assign(window, { ScreenClubsRows, ScreenClubsFeed, ScreenClubsGrid });
