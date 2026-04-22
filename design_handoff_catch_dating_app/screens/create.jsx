// Create Run — host stepper flow (run-club admin only)

function CreateHeader({ theme, type, step, total, title }) {
  return (
    <>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type}
        left={<IconBtn theme={theme}><Icon.x c={theme.ink}/></IconBtn>}
        title="New run"
        right={<div style={{ fontSize: 13, color: theme.ink2, fontWeight: 600 }}>Save draft</div>}/>
      <div style={{ padding: '4px 20px 16px' }}>
        <Progress theme={theme} value={step/total}/>
        <div style={{ fontFamily: type.text, fontSize: 11, color: theme.ink3, marginTop: 8, letterSpacing: 0.6, textTransform:'uppercase', fontWeight: 600 }}>Step {step} of {total} · Bandra Breakers RC</div>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1.05, marginTop: 6 }}>{title}</div>
      </div>
    </>
  );
}

// Step 1 — Basics (title, cover, description)
function ScreenCreateBasics({ theme, type }) {
  return (
    <div data-screen-label="30 Create · Basics" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <CreateHeader theme={theme} type={type} step={1} total={4} title="What's the run?"/>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        <div style={{ aspectRatio:'16/9', borderRadius: 16, background: theme.raised, border:`1.5px dashed ${theme.line2}`, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap: 8 }}>
          <Icon.camera c={theme.ink3} s={28}/>
          <div style={{ fontSize: 13, color: theme.ink2, fontWeight: 600 }}>Add cover photo</div>
          <div style={{ fontSize: 11, color: theme.ink3 }}>Recommended 1600×900</div>
        </div>
        <Field theme={theme} label="Run title" value="Sunrise Seawall 7K" hint="Make it sing. First impressions matter."/>
        <Field theme={theme} label="Description" multiline value="Easy-pace weekly run along the Bandra seawall, ending with filter coffee at Kitchen Garden. First-timers very welcome." />
        <div style={{ marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 10 }}>Difficulty</div>
          <div style={{ display:'flex', gap: 8 }}>
            {['Easy','Moderate','Hard'].map((d,i)=>(
              <div key={d} style={{ flex:1, height: 48, borderRadius: 12, background: i===0?theme.ink:theme.surface, color: i===0?theme.surface:theme.ink, border:`1px solid ${i===0?theme.ink:theme.line2}`, display:'flex', alignItems:'center', justifyContent:'center', fontSize: 14, fontWeight: 600 }}>{d}</div>
            ))}
          </div>
        </div>
        <div style={{ marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 10 }}>Vibe tags</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap: 8 }}>
            {['Sunrise','Silent run','Coffee after','Beginners welcome','Trail','Track','Hills','Intervals'].map((t,i)=>(
              <Chip key={t} theme={theme} active={[0,2,3].includes(i)}>{t}</Chip>
            ))}
          </div>
        </div>
      </div>
      <div style={{ padding:'12px 16px 24px', background: theme.surface, borderTop:`1px solid ${theme.line}` }}>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>Continue · Route →</Button>
      </div>
    </div>
  );
}

function Field({ theme, label, value, hint, multiline }) {
  return (
    <div style={{ marginTop: 18 }}>
      <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 8 }}>{label}</div>
      <div style={{
        minHeight: multiline ? 92 : 54, borderRadius: 12, background: theme.surface,
        border:`1.5px solid ${theme.line2}`, padding:'14px 14px',
        fontSize: 15, lineHeight: 1.4, color: theme.ink,
      }}>{value}</div>
      {hint && <div style={{ fontSize: 11, color: theme.ink3, marginTop: 6 }}>{hint}</div>}
    </div>
  );
}

// Step 2 — Route, meet point, distance
function ScreenCreateRoute({ theme, type }) {
  return (
    <div data-screen-label="31 Create · Route" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <CreateHeader theme={theme} type={type} step={2} total={4} title="Where will you run?"/>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        <div style={{ borderRadius: 16, overflow:'hidden', border:`1px solid ${theme.line}`, position:'relative' }}>
          <MiniMap theme={theme} height={200}/>
          <div style={{ position:'absolute', bottom: 10, right: 10, padding:'6px 12px', background: theme.surface, color: theme.ink, borderRadius: 999, fontSize: 11, fontWeight: 700, border:`1px solid ${theme.line2}`, display:'flex', alignItems:'center', gap: 4 }}>
            <Icon.edit c={theme.ink} s={12}/> Draw route
          </div>
        </div>
        <div style={{ display:'grid', gridTemplateColumns:'repeat(2,1fr)', gap: 10, marginTop: 12 }}>
          <div style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 12, padding: 12 }}>
            <div style={{ fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.6, textTransform:'uppercase' }}>Distance</div>
            <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight, marginTop: 2 }}>7.2 km</div>
          </div>
          <div style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 12, padding: 12 }}>
            <div style={{ fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.6, textTransform:'uppercase' }}>Elevation</div>
            <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight, marginTop: 2 }}>+28 m</div>
          </div>
        </div>
        <Field theme={theme} label="Meet point" value="Joggers Park sign · Carter Road, Bandra W"/>
        <div style={{ marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 10 }}>Target pace range</div>
          <div style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16, padding: 16 }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
              <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight }}>5:15 — 6:15 /km</div>
              <div style={{ fontSize: 11, color: theme.ink3 }}>easy pace</div>
            </div>
            <div style={{ height: 6, background: theme.line2, borderRadius:999, marginTop: 14, position:'relative' }}>
              <div style={{ position:'absolute', left:'24%', width:'42%', height:'100%', background: theme.primary, borderRadius:999 }}/>
              <div style={{ position:'absolute', left:'24%', width:18, height:18, top:-6, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.2)' }}/>
              <div style={{ position:'absolute', left:'66%', width:18, height:18, top:-6, borderRadius:999, background: theme.primary, border:'3px solid white', boxShadow:'0 2px 6px rgba(0,0,0,0.2)' }}/>
            </div>
          </div>
        </div>
      </div>
      <div style={{ padding:'12px 16px 24px', background: theme.surface, borderTop:`1px solid ${theme.line}` }}>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>Continue · When →</Button>
      </div>
    </div>
  );
}

// Step 3 — When + capacity + price
function ScreenCreateWhen({ theme, type }) {
  return (
    <div data-screen-label="32 Create · When" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <CreateHeader theme={theme} type={type} step={3} total={4} title="When & how many?"/>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        {/* Date & time */}
        <div style={{ background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16, padding: 16 }}>
          <div style={{ display:'flex', gap: 12, alignItems:'center' }}>
            <div style={{ width:54, height:54, borderRadius:12, background: theme.primarySoft, color: theme.primary, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
              <div style={{ fontSize: 9, fontWeight: 700, textTransform:'uppercase' }}>APR</div>
              <div style={{ fontSize: 20, fontWeight: 700, lineHeight: 1 }}>22</div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>Monday, 22 April</div>
              <div style={{ fontSize: 13, color: theme.ink2, marginTop: 2 }}>6:00 AM · meet at 5:45</div>
            </div>
            <div style={{ padding:'6px 12px', borderRadius: 999, background: theme.raised, color: theme.ink, fontSize: 12, fontWeight: 600, border:`1px solid ${theme.line2}` }}>Change</div>
          </div>
          <div style={{ marginTop: 14, padding:'10px 12px', borderRadius: 10, background: theme.raised, display:'flex', alignItems:'center', gap: 10 }}>
            <Toggle theme={theme} on/>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 600 }}>Make it recurring</div>
              <div style={{ fontSize: 11, color: theme.ink2 }}>Every Monday at 6:00 AM</div>
            </div>
          </div>
        </div>
        {/* Capacity */}
        <div style={{ marginTop: 18, background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 16, padding: 16 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 8 }}>Capacity</div>
          <div style={{ display:'flex', alignItems:'center', gap: 14 }}>
            <div style={{ width: 40, height: 40, borderRadius:999, border:`1.5px solid ${theme.line2}`, display:'flex', alignItems:'center', justifyContent:'center' }}>−</div>
            <div style={{ fontFamily: type.display, fontSize: 36, fontWeight: type.displayWeight, flex: 1, textAlign:'center' }}>30</div>
            <div style={{ width: 40, height: 40, borderRadius:999, background: theme.ink, color: theme.surface, display:'flex', alignItems:'center', justifyContent:'center' }}><Icon.plus c={theme.surface} s={16}/></div>
          </div>
          <div style={{ marginTop: 12, padding:'10px 12px', borderRadius: 10, background: theme.raised, display:'flex', alignItems:'center', gap: 10 }}>
            <Toggle theme={theme} on/>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 600 }}>Enable waitlist</div>
              <div style={{ fontSize: 11, color: theme.ink2 }}>Auto-promote when someone drops</div>
            </div>
          </div>
        </div>
        {/* Pricing */}
        <div style={{ marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase', marginBottom: 10 }}>Price per runner</div>
          <div style={{ display:'flex', gap: 8 }}>
            {['Free','₹199','₹299','₹499','Custom'].map((p,i)=>(
              <div key={p} style={{ flex: 1, height: 48, borderRadius: 12, background: i===2?theme.primary:theme.surface, color: i===2?theme.primaryInk:theme.ink, border:`1px solid ${i===2?theme.primary:theme.line2}`, display:'flex', alignItems:'center', justifyContent:'center', fontSize: 13, fontWeight: 600 }}>{p}</div>
            ))}
          </div>
          <div style={{ fontSize: 11, color: theme.ink3, marginTop: 8 }}>Catch keeps 10%. You'll get ₹269/runner. Paid via Razorpay.</div>
        </div>
      </div>
      <div style={{ padding:'12px 16px 24px', background: theme.surface, borderTop:`1px solid ${theme.line}` }}>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>Continue · Review →</Button>
      </div>
    </div>
  );
}

// Step 4 — Review + publish
function ScreenCreateReview({ theme, type }) {
  return (
    <div data-screen-label="33 Create · Review" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <CreateHeader theme={theme} type={type} step={4} total={4} title="One last look"/>
      <div style={{ flex:1, overflow:'auto', padding: '0 20px 20px' }}>
        <div style={{ borderRadius: 20, overflow:'hidden', border:`1px solid ${theme.line}` }}>
          <div style={{ position:'relative', height: 140 }}>
            <MiniMap theme={theme} height={140}/>
            <div style={{ position:'absolute', top: 10, left: 10, padding:'4px 10px', background: 'rgba(255,255,255,0.95)', color:'#000', borderRadius: 999, fontSize: 10, fontWeight: 700, letterSpacing: 0.5 }}>7.2 KM · 5:15–6:15</div>
          </div>
          <div style={{ padding: 14, background: theme.surface }}>
            <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 600, letterSpacing: 0.4, textTransform:'uppercase' }}>Bandra Breakers RC</div>
            <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2 }}>Sunrise Seawall 7K</div>
            <div style={{ fontSize: 13, color: theme.ink2, marginTop: 4, display:'flex', gap: 12 }}>
              <span><Icon.clock c={theme.ink2} s={13}/> Mon 22 Apr · 6:00 AM</span>
            </div>
            <div style={{ fontSize: 13, color: theme.ink2, marginTop: 2, display:'flex', gap: 12 }}>
              <span><Icon.pin c={theme.ink2} s={13}/> Carter Road, Bandra W</span>
            </div>
          </div>
        </div>
        {/* Summary rows */}
        <div style={{ marginTop: 18, background: theme.surface, borderRadius: 16, border:`1px solid ${theme.line}`, overflow:'hidden' }}>
          {[
            ['Capacity','30 runners · waitlist on'],
            ['Price','₹299 per runner'],
            ['You\'ll earn','₹269 × 30 = ₹8,070'],
            ['Recurring','Every Monday at 6:00 AM'],
            ['Visibility','Public · anyone can join'],
          ].map((r,i,a)=>(
            <div key={i} style={{ padding:'14px 16px', display:'flex', justifyContent:'space-between', borderBottom: i<a.length-1?`1px solid ${theme.line}`:'none' }}>
              <div style={{ fontSize: 13, color: theme.ink2 }}>{r[0]}</div>
              <div style={{ fontSize: 14, fontWeight: 600, color: theme.ink, textAlign:'right' }}>{r[1]}</div>
            </div>
          ))}
        </div>
        {/* Notify */}
        <div style={{ marginTop: 14, padding: 14, background: theme.primarySoft, color: theme.primary, borderRadius: 14, display:'flex', alignItems:'center', gap: 10 }}>
          <Icon.bell c={theme.primary} s={18}/>
          <div style={{ flex: 1, fontSize: 13, fontWeight: 600, color: theme.primary }}>Notify 420 followers of your club</div>
          <Toggle theme={theme} on/>
        </div>
      </div>
      <div style={{ padding:'12px 16px 24px', background: theme.surface, borderTop:`1px solid ${theme.line}` }}>
        <Button theme={theme} size="lg" style={{ width:'100%' }}>Publish run</Button>
      </div>
    </div>
  );
}

// Created + edge state — full / waitlist
function ScreenCreateSuccess({ theme, type }) {
  return (
    <div data-screen-label="34 Create · Live" style={{ width:'100%', height:'100%', background: theme.heroGrad, color:'#fff', position:'relative', overflow:'hidden', display:'flex', flexDirection:'column' }}>
      <StatusBar theme={{...theme,dark:true}}/>
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding: '0 24px', textAlign:'center' }}>
        <div style={{ width: 72, height: 72, borderRadius:999, background:'rgba(255,255,255,0.2)', display:'flex', alignItems:'center', justifyContent:'center', border:'2px solid rgba(255,255,255,0.5)' }}>
          <Icon.check c="#fff" s={36}/>
        </div>
        <div style={{ fontFamily: type.display, fontSize: 40, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em', lineHeight: 1, marginTop: 22 }}>
          Run's live.
        </div>
        <div style={{ fontSize: 15, marginTop: 12, opacity: 0.9, maxWidth: 280 }}>
          Sunrise Seawall 7K is now visible to 420 followers and anyone nearby.
        </div>
        <div style={{ marginTop: 22, padding: '10px 16px', background:'rgba(0,0,0,0.3)', borderRadius: 999, fontSize: 12, fontWeight: 600, display:'inline-flex', gap: 8 }}>
          <Icon.bolt c="#fff" s={14}/> 3 people have already tapped to join
        </div>
      </div>
      <div style={{ padding: '0 20px 40px', display:'flex', flexDirection:'column', gap: 10 }}>
        <Button theme={{...theme, primary:'#fff', primaryInk: theme.ink}} size="lg" style={{ width:'100%' }}>View run</Button>
        <Button theme={theme} variant="ghost" style={{ width:'100%', color:'#fff' }}>Share with club →</Button>
      </div>
    </div>
  );
}

// Host run management — once a run is full / waitlist building
function ScreenHostRun({ theme, type }) {
  return (
    <div data-screen-label="35 Host · Manage" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <TopBar theme={theme} type={type} title="Manage run" left={<IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>} right={<IconBtn theme={theme}><Icon.edit c={theme.ink}/></IconBtn>}/>
      <div style={{ flex:1, overflow:'auto', padding: '4px 20px 24px' }}>
        {/* hero summary */}
        <div style={{ background: theme.ink, color: theme.surface, borderRadius: 18, padding: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.2, opacity: 0.7 }}>SUNRISE SEAWALL 7K · TOMORROW 6 AM</div>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap: 10, marginTop: 14 }}>
            {[['Booked','30/30',true],['Waitlist','7',false],['Revenue','₹8,070',false]].map((m,i)=>(
              <div key={i}>
                <div style={{ fontSize: 10, fontWeight: 600, letterSpacing: 0.5, opacity: 0.6, textTransform:'uppercase' }}>{m[0]}</div>
                <div style={{ fontFamily: type.display, fontSize: 22, fontWeight: type.displayWeight, color: m[2]?theme.primary:theme.surface, marginTop: 4 }}>{m[1]}</div>
              </div>
            ))}
          </div>
          <div style={{ padding: '8px 12px', background: theme.primary, color: theme.primaryInk, borderRadius: 10, marginTop: 14, fontSize: 12, fontWeight: 700, display:'flex', alignItems:'center', gap: 8 }}>
            <Icon.bolt c={theme.primaryInk} s={14}/> Run is FULL · 7 on waitlist
          </div>
        </div>
        {/* Roster */}
        <div style={{ marginTop: 20, display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
          <div style={{ fontFamily: type.display, fontSize: 18, fontWeight: type.displayWeight }}>Roster</div>
          <div style={{ fontSize: 12, color: theme.ink2, fontWeight: 600 }}>Message all</div>
        </div>
        <div style={{ marginTop: 10 }}>
          {[
            { name:'Riya Kapoor', pace:'5:15/km', status:'paid', seed:'h1' },
            { name:'Aarav Desai', pace:'5:30/km', status:'paid', seed:'h2' },
            { name:'Zoya Shah', pace:'5:45/km', status:'paid', seed:'h3' },
            { name:'Kabir Rao', pace:'6:00/km', status:'pending', seed:'h4' },
          ].map((r,i)=>(
            <div key={i} style={{ display:'flex', gap: 12, padding: '10px 0', alignItems:'center', borderBottom: `1px solid ${theme.line}` }}>
              <div style={{ width: 40, height: 40, borderRadius: 999, overflow:'hidden' }}><PhotoBox seed={r.seed}/></div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{r.name}</div>
                <div style={{ fontSize: 11, color: theme.ink3 }}>Pace {r.pace}</div>
              </div>
              {r.status==='paid' ? (
                <div style={{ padding:'3px 8px', fontSize: 10, fontWeight: 700, background: theme.primarySoft, color: theme.primary, borderRadius: 999, letterSpacing: 0.4 }}>PAID</div>
              ) : (
                <div style={{ padding:'3px 8px', fontSize: 10, fontWeight: 700, background: theme.raised, color: theme.ink2, borderRadius: 999, letterSpacing: 0.4, border: `1px solid ${theme.line2}` }}>PENDING</div>
              )}
            </div>
          ))}
          <div style={{ padding: '12px 0 0', textAlign:'center', fontSize: 12, color: theme.ink2, fontWeight: 600 }}>+26 more runners</div>
        </div>
        {/* Waitlist */}
        <div style={{ marginTop: 20, padding: 14, background: theme.raised, borderRadius: 14, border: `1px solid ${theme.line}` }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: theme.ink2, letterSpacing: 0.6, textTransform:'uppercase' }}>Waitlist · 7</div>
          <div style={{ fontSize: 13, color: theme.ink2, marginTop: 6, lineHeight: 1.4 }}>They'll be auto-promoted when someone drops. You can also promote manually.</div>
          <div style={{ display:'flex', marginTop: 10 }}>
            {[0,1,2,3,4,5,6].map(i=>(
              <div key={i} style={{ width: 32, height: 32, borderRadius: 999, overflow:'hidden', border:`2px solid ${theme.raised}`, marginLeft: i===0?0:-8 }}>
                <PhotoBox seed={`w-${i}`}/>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenCreateBasics, ScreenCreateRoute, ScreenCreateWhen, ScreenCreateReview, ScreenCreateSuccess, ScreenHostRun });
