// Home, Run Clubs, Run Detail, Map screens

// Home — cards feed of upcoming runs (default variant)
function ScreenHomeFeed({ theme, type }) {
  const runs = [
    { club: 'Bandra Breakers RC', where: 'Carter Road', when: 'Today · 6:00 AM', dist: '7K', pace: '5:30 /km', price: '₹299', attend: 24, cap: 30, seed: 'bbrc', hot: true },
    { club: 'Lodhi Night Owls', where: 'Lodhi Gardens', when: 'Wed · 7:30 PM', dist: '5K', pace: '6:00 /km', price: 'Free', attend: 12, cap: 20, seed: 'lno', hot: false },
    { club: 'Cubbon Park Striders', where: 'Cubbon Park', when: 'Sat · 5:30 AM', dist: '10K', pace: '5:00 /km', price: '₹249', attend: 18, cap: 25, seed: 'cps', hot: false },
  ];
  return (
    <div data-screen-label="08 Home Feed" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 10px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontSize: 12, color: theme.ink3, fontFamily: type.text, letterSpacing: 0.4 }}>GOOD MORNING</div>
          <div style={{ fontFamily: type.display, fontSize: 26, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Find your pace, Suvrat</div>
        </div>
        <IconBtn theme={theme}><Icon.bell c={theme.ink}/></IconBtn>
      </div>
      <div style={{ padding: '6px 20px 10px', display:'flex', gap:8, overflow:'hidden' }}>
        {['Near you','Today','This week','5K–10K','Easy','Free'].map((c,i)=>(
          <Chip key={c} theme={theme} active={i===0}>{c}</Chip>
        ))}
      </div>
      <div style={{ flex:1, overflow:'auto', padding:'4px 20px 20px', display:'flex', flexDirection:'column', gap: 16 }}>
        {runs.map((r,idx)=>(
          <div key={idx} style={{
            background: theme.surface, borderRadius: 20, overflow:'hidden',
            border:`1px solid ${theme.line}`,
          }}>
            <div style={{ position:'relative', height: 160 }}>
              <MiniMap theme={theme} height={160}/>
              <div style={{ position:'absolute', top:12, left:12, display:'flex', gap: 6 }}>
                {r.hot && <div style={{ padding:'4px 10px', borderRadius: 999, background: theme.ink, color: theme.surface, fontSize: 11, fontWeight: 700, letterSpacing: 0.4, display:'flex', alignItems:'center', gap: 4 }}>
                  <Icon.flame c={theme.surface} s={12}/> 2 SPOTS LEFT
                </div>}
                <div style={{ padding:'4px 10px', borderRadius: 999, background: 'rgba(255,255,255,0.9)', color: theme.ink, fontSize: 11, fontWeight: 700, letterSpacing: 0.4 }}>
                  {r.dist} · {r.pace}
                </div>
              </div>
              {/* stacked avatars */}
              <div style={{ position:'absolute', right:12, bottom:12, display:'flex' }}>
                {[0,1,2,3].map(i=>(
                  <div key={i} style={{ width: 32, height: 32, borderRadius: 999, marginLeft: i===0?0:-10, border:'2px solid white', overflow:'hidden' }}>
                    <PhotoBox seed={`${r.seed}-${i}`}/>
                  </div>
                ))}
                <div style={{ width:32, height:32, borderRadius:999, marginLeft:-10, border:'2px solid white', background: theme.ink, color: theme.surface, fontSize: 11, fontWeight: 700, display:'flex', alignItems:'center', justifyContent:'center' }}>
                  +{r.attend-4}
                </div>
              </div>
            </div>
            <div style={{ padding: 16 }}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline', gap: 8 }}>
                <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>{r.club}</div>
                <div style={{ fontSize: 14, fontWeight: 700, color: r.price==='Free'?theme.accent:theme.ink }}>{r.price}</div>
              </div>
              <div style={{ display:'flex', gap: 10, marginTop: 6, color: theme.ink2, fontSize: 13, alignItems:'center' }}>
                <span style={{ display:'inline-flex', alignItems:'center', gap:4 }}><Icon.pin s={13} c={theme.ink2}/>{r.where}</span>
                <span style={{ display:'inline-flex', alignItems:'center', gap:4 }}><Icon.clock s={13} c={theme.ink2}/>{r.when}</span>
              </div>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginTop: 14 }}>
                <div style={{ fontSize: 12, color: theme.ink2 }}>{r.attend}/{r.cap} runners · <b style={{ color: theme.ink }}>{r.attend-8} might be a match</b></div>
                <Button theme={theme} size="sm">Join →</Button>
              </div>
            </div>
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

// Home Map variant
function ScreenHomeMap({ theme, type }) {
  const pins = [
    { x: 18, y: 35, price: '₹299', hot:true },
    { x: 48, y: 25, price: '10K' },
    { x: 68, y: 55, price: 'Free' },
    { x: 32, y: 70, price: '₹199' },
    { x: 80, y: 30, price: '5K' },
  ];
  return (
    <div data-screen-label="09 Home Map" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ flex:1, position:'relative' }}>
        <MiniMap theme={theme} height="100%" route={false}/>
        {/* search pill */}
        <div style={{ position:'absolute', top:8, left:16, right:16, display:'flex', gap: 8 }}>
          <div style={{ flex:1, background: theme.surface, borderRadius: 14, height: 46, border:`1px solid ${theme.line2}`, display:'flex', alignItems:'center', padding:'0 14px', gap: 10, boxShadow:'0 2px 10px rgba(0,0,0,0.06)' }}>
            <Icon.search c={theme.ink2}/>
            <span style={{ fontSize: 15, color: theme.ink2 }}>Find a run near Bandra</span>
          </div>
          <div style={{ width: 46, height: 46, borderRadius: 14, background: theme.ink, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 2px 10px rgba(0,0,0,0.15)' }}>
            <Icon.filter c={theme.surface}/>
          </div>
        </div>
        {/* price pins */}
        {pins.map((p,i)=>(
          <div key={i} style={{
            position:'absolute', left: `${p.x}%`, top: `${p.y}%`,
            padding: '6px 12px', borderRadius: 999,
            background: p.hot?theme.primary:theme.surface,
            color: p.hot?theme.primaryInk:theme.ink,
            fontSize: 13, fontWeight: 700,
            boxShadow:'0 4px 14px rgba(0,0,0,0.18)',
            border: `2px solid ${p.hot?theme.primary:theme.surface}`,
          }}>{p.price}</div>
        ))}
        {/* locate-me */}
        <div style={{ position:'absolute', right: 16, bottom: 220, width: 46, height: 46, borderRadius: 14, background: theme.surface, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 4px 14px rgba(0,0,0,0.15)' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3" fill={theme.primary}/><circle cx="12" cy="12" r="8" stroke={theme.ink2} strokeWidth="1.5" fill="none"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3" stroke={theme.ink2} strokeWidth="1.5"/></svg>
        </div>
        {/* bottom sheet preview */}
        <div style={{
          position:'absolute', left: 12, right: 12, bottom: 76,
          background: theme.surface, borderRadius: 20, padding: 14,
          boxShadow:'0 -6px 20px rgba(0,0,0,0.08)',
          border: `1px solid ${theme.line}`,
          display:'flex', gap: 12, alignItems:'center',
        }}>
          <div style={{ width: 60, height: 60, borderRadius: 12, overflow:'hidden' }}>
            <PhotoBox seed="bbrc-map"/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: type.display, fontSize: 16, fontWeight: type.displayWeight }}>Bandra Breakers · 7K</div>
            <div style={{ fontSize: 12, color: theme.ink2, marginTop: 2 }}>Today 6:00 AM · Carter Road · 24/30</div>
            <div style={{ display:'flex', gap: 4, marginTop:6 }}>
              {[0,1,2].map(i=>(
                <div key={i} style={{ width:18, height:18, borderRadius:999, overflow:'hidden', border:'1.5px solid white' }}><PhotoBox seed={`bbrc-m-${i}`}/></div>
              ))}
              <div style={{ fontSize:11, color: theme.ink2, marginLeft: 4, alignSelf:'center' }}>+21 running</div>
            </div>
          </div>
          <Button theme={theme} size="sm">₹299</Button>
        </div>
      </div>
      <TabBar theme={theme} type={type} active="map"/>
    </div>
  );
}

// Run Detail
function ScreenRunDetail({ theme, type }) {
  return (
    <div data-screen-label="10 Run Detail" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <div style={{ position: 'relative' }}>
        <div style={{ height: 320, position:'relative', overflow:'hidden' }}>
          <MiniMap theme={theme} height={320}/>
          <div style={{ position:'absolute', inset:0, background: 'linear-gradient(180deg,rgba(0,0,0,0.25) 0%,rgba(0,0,0,0) 40%,rgba(0,0,0,0) 60%,rgba(0,0,0,0.55) 100%)' }}/>
          <StatusBar theme={{...theme, dark:true}}/>
          <div style={{ position:'absolute', top: 50, left: 16, right: 16, display:'flex', justifyContent:'space-between' }}>
            <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.9)', display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.back c="#000"/></div>
            <div style={{ display:'flex', gap: 8 }}>
              <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.9)', display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.heart c="#000"/></div>
              <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.9)', display:'flex', alignItems:'center', justifyContent:'center' }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 3v14M5 10l7-7 7 7M5 20h14" stroke="#000" strokeWidth="1.6" strokeLinecap="round"/></svg>
              </div>
            </div>
          </div>
          <div style={{ position:'absolute', bottom: 16, left: 20, right: 20, color: '#fff' }}>
            <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 1.2, opacity: 0.9 }}>BANDRA BREAKERS RC · EASY PACE</div>
            <div style={{ fontFamily: type.display, fontSize: 30, fontWeight: type.displayWeight, lineHeight: 1.05, letterSpacing: type.displayTracking+'em' }}>
              Sunrise Seawall 7K
            </div>
          </div>
        </div>
      </div>
      <div style={{ flex: 1, overflow:'auto', padding: '20px 20px 20px' }}>
        {/* key metrics */}
        <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10 }}>
          {[
            { l:'Distance', v:'7.2 km' },
            { l:'Avg pace', v:'5:30/km' },
            { l:'Elev gain', v:'28 m' },
          ].map(m=>(
            <div key={m.l} style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 14, padding: '12px 12px' }}>
              <div style={{ fontSize: 11, color: theme.ink3, textTransform:'uppercase', letterSpacing: 0.6, fontWeight: 600 }}>{m.l}</div>
              <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2 }}>{m.v}</div>
            </div>
          ))}
        </div>
        {/* when/where */}
        <div style={{ marginTop: 16, background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16, padding: 16, display:'flex', flexDirection:'column', gap: 12 }}>
          <div style={{ display:'flex', gap: 12, alignItems:'flex-start' }}>
            <div style={{ width:44, height:44, borderRadius:12, background: theme.primarySoft, color: theme.primary, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
              <div style={{ fontSize: 10, fontWeight: 700, textTransform:'uppercase' }}>APR</div>
              <div style={{ fontSize: 18, fontWeight: 700, lineHeight:1 }}>22</div>
            </div>
            <div>
              <div style={{ fontSize: 16, fontWeight: 600 }}>Monday · 6:00 AM</div>
              <div style={{ fontSize: 13, color: theme.ink2, marginTop:2 }}>Meet 5:45. Warm-up at 5:55.</div>
            </div>
          </div>
          <div style={{ height: 1, background: theme.line }}/>
          <div style={{ display:'flex', gap: 12, alignItems:'flex-start' }}>
            <div style={{ width:44, height:44, borderRadius:12, background: theme.raised, color: theme.ink, display:'flex', alignItems:'center', justifyContent:'center' }}>
              <Icon.pin c={theme.ink}/>
            </div>
            <div>
              <div style={{ fontSize: 16, fontWeight: 600 }}>Carter Road Promenade</div>
              <div style={{ fontSize: 13, color: theme.ink2, marginTop:2 }}>Bandra W. Meet near Joggers Park sign.</div>
            </div>
          </div>
        </div>
        {/* Who's running */}
        <div style={{ marginTop: 20 }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
            <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight }}>Who's running</div>
            <div style={{ fontSize: 13, color: theme.ink2 }}>24 of 30 · 9 your vibe</div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 10, marginTop: 12 }}>
            {['a','b','c','d','e','f','g','h'].map((s,i)=>(
              <div key={i} style={{ aspectRatio:'1/1', borderRadius: 12, overflow:'hidden', position:'relative' }}>
                <PhotoBox seed={`attendee-${s}`}/>
                {i===1 && <div style={{ position:'absolute', bottom:4, left:4, padding:'2px 6px', background: theme.primary, color: theme.primaryInk, fontSize: 9, fontWeight: 700, borderRadius: 4, letterSpacing: 0.4 }}>POPULAR</div>}
                <div style={{ position:'absolute', bottom: 4, right: 4, padding:'1px 6px', borderRadius: 999, background:'rgba(0,0,0,0.6)', color:'#fff', fontSize: 10, fontWeight: 600 }}>{23+i}</div>
              </div>
            ))}
          </div>
          <div style={{ marginTop: 10, padding: 12, background: theme.primarySoft, color: theme.primary, borderRadius: 12, fontSize: 12, display:'flex', gap: 10, alignItems:'center' }}>
            <Icon.bolt c={theme.primary} s={16}/>
            Swiping unlocks after the run finishes.
          </div>
        </div>
        {/* about club */}
        <div style={{ marginTop: 20, padding: 16, background: theme.surface, border: `1px solid ${theme.line}`, borderRadius: 16 }}>
          <div style={{ display:'flex', gap: 12, alignItems:'center' }}>
            <div style={{ width:44, height:44, borderRadius:999, overflow:'hidden' }}><PhotoBox seed="bbrc-logo"/></div>
            <div>
              <div style={{ fontSize: 15, fontWeight: 600 }}>Hosted by Bandra Breakers RC</div>
              <div style={{ fontSize: 12, color: theme.ink2, display:'flex', gap: 6, alignItems:'center' }}>
                <Icon.star c={theme.gold}/> 4.9 · 312 runs hosted
              </div>
            </div>
          </div>
          <div style={{ fontSize: 14, color: theme.ink2, marginTop: 12, lineHeight: 1.5 }}>
            Easy-pace group run along the seawall, ending with filter coffee at Kitchen Garden. First-timers very welcome.
          </div>
        </div>
      </div>
      {/* sticky CTA */}
      <div style={{ padding: '12px 16px 24px', background: theme.surface, borderTop:`1px solid ${theme.line}`, display:'flex', alignItems:'center', gap: 12 }}>
        <div>
          <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>₹299</div>
          <div style={{ fontSize: 11, color: theme.ink3 }}>incl. coffee after</div>
        </div>
        <Button theme={theme} size="lg" style={{ flex: 1 }}>Join run — 6 spots left</Button>
      </div>
    </div>
  );
}

// Run Clubs list
function ScreenRunClubs({ theme, type }) {
  const clubs = [
    { name:'Bandra Breakers RC', host:'Priya K.', loc:'Mumbai · Bandra', members: 420, rating: 4.9, seed:'bbrc' },
    { name:'Lodhi Night Owls', host:'Arjun S.', loc:'Delhi · Lodhi Gardens', members: 285, rating: 4.8, seed:'lno' },
    { name:'Cubbon Park Striders', host:'Meera R.', loc:'Bangalore · Cubbon', members: 512, rating: 4.9, seed:'cps' },
    { name:'Marina Milers', host:'Karthik V.', loc:'Chennai · Marina', members: 198, rating: 4.7, seed:'mm' },
    { name:'Koregaon Kicks', host:'Ananya D.', loc:'Pune · Koregaon Park', members: 156, rating: 4.8, seed:'kk' },
  ];
  return (
    <div data-screen-label="11 Run Clubs" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 12px' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Run clubs</div>
        <div style={{ fontSize: 13, color: theme.ink2, marginTop: 2 }}>Find your people. Then find your person.</div>
      </div>
      <div style={{ padding: '0 20px 12px', display:'flex', gap: 8, alignItems:'center' }}>
        <div style={{ flex: 1, background: theme.surface, borderRadius: 12, height: 44, border:`1px solid ${theme.line2}`, display:'flex', alignItems:'center', padding:'0 14px', gap: 10 }}>
          <Icon.search c={theme.ink2}/>
          <span style={{ fontSize: 14, color: theme.ink2 }}>Search clubs</span>
        </div>
        <div style={{ width: 44, height: 44, borderRadius: 12, background: theme.ink, color: theme.surface, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon.filter c={theme.surface}/>
        </div>
      </div>
      <div style={{ flex: 1, overflow:'auto', padding: '0 20px 20px' }}>
        {clubs.map((c,i)=>(
          <div key={i} style={{
            display:'flex', gap: 12, padding: '12px 0',
            borderBottom: i<clubs.length-1?`1px solid ${theme.line}`:'none',
          }}>
            <div style={{ width: 64, height: 64, borderRadius: 14, overflow:'hidden', flexShrink: 0 }}>
              <PhotoBox seed={c.seed}/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: type.display, fontSize: 16, fontWeight: type.displayWeight }}>{c.name}</div>
              <div style={{ fontSize: 12, color: theme.ink2, marginTop: 2 }}>{c.loc} · {c.members} runners</div>
              <div style={{ fontSize: 12, color: theme.ink3, marginTop: 2, display:'flex', alignItems:'center', gap: 4 }}>
                <Icon.star c={theme.gold} s={12}/>{c.rating} · hosted by {c.host}
              </div>
            </div>
            <div style={{ alignSelf: 'center' }}>
              <Chip theme={theme}>Follow</Chip>
            </div>
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

// Run Club detail
function ScreenClubDetail({ theme, type }) {
  const upcoming = [
    { dist:'7K', when:'Mon 6:00 AM', price:'₹299' },
    { dist:'5K', when:'Wed 7:30 PM', price:'₹199' },
    { dist:'10K', when:'Sat 5:30 AM', price:'₹349' },
  ];
  return (
    <div data-screen-label="12 Club Detail" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <div style={{ height: 220, position:'relative', overflow:'hidden' }}>
        <PhotoBox seed="bbrc-hero"/>
        <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg,rgba(0,0,0,0.3) 0%,rgba(0,0,0,0) 60%,rgba(0,0,0,0.6) 100%)' }}/>
        <StatusBar theme={{...theme,dark:true}}/>
        <div style={{ position:'absolute', top:50, left:16 }}>
          <div style={{ width:40, height:40, borderRadius:999, background:'rgba(255,255,255,0.9)', display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.back c="#000"/></div>
        </div>
        <div style={{ position:'absolute', bottom: 16, left: 20, color:'#fff' }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.4, opacity: 0.85 }}>MUMBAI · BANDRA</div>
          <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Bandra Breakers RC</div>
          <div style={{ fontSize: 13, opacity: 0.9, marginTop: 2 }}>420 runners · 312 runs · ★ 4.9</div>
        </div>
      </div>
      <div style={{ flex:1, overflow:'auto', padding: '20px 20px 100px' }}>
        <div style={{ display:'flex', gap: 10 }}>
          <Button theme={theme} size="md" style={{ flex: 1 }}>Follow</Button>
          <div style={{ width: 52, height: 52, borderRadius: 999, border: `1px solid ${theme.line2}`, display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.chat c={theme.ink}/></div>
          <div style={{ width: 52, height: 52, borderRadius: 999, border: `1px solid ${theme.line2}`, display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.bell c={theme.ink}/></div>
        </div>
        <div style={{ fontSize: 14, color: theme.ink2, marginTop: 18, lineHeight: 1.5 }}>
          Easy-pace weekly runs along the Bandra seawall. First-timers welcome. We end every run with filter coffee and absolutely no fitness talk.
        </div>
        <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight, marginTop: 22 }}>Upcoming</div>
        <div style={{ marginTop: 10, display:'flex', flexDirection:'column', gap: 10 }}>
          {upcoming.map((r,i)=>(
            <div key={i} style={{ background: theme.surface, border: `1px solid ${theme.line}`, borderRadius: 14, padding: 12, display:'flex', alignItems:'center', gap: 12 }}>
              <div style={{ width: 52, height: 52, borderRadius: 10, background: theme.primarySoft, color: theme.primary, display:'flex', alignItems:'center', justifyContent:'center', fontFamily: type.display, fontSize: 16, fontWeight: 700 }}>{r.dist}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{r.when}</div>
                <div style={{ fontSize: 12, color: theme.ink2 }}>Carter Road · hosted by Priya</div>
              </div>
              <div style={{ fontSize: 14, fontWeight: 700 }}>{r.price}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  ScreenHomeFeed, ScreenHomeMap, ScreenRunDetail, ScreenRunClubs, ScreenClubDetail,
});
