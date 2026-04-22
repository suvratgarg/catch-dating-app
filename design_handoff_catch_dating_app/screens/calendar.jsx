// Calendar screens — timeline (time-of-day) + agenda (days stacked)

// View A — Timeline (day view, vertical time)
function ScreenCalendarTimeline({ theme, type }) {
  const hours = ['5','6','7','8','9','10','11','12','1','2','3','4','5','6','7','8'];
  const events = [
    { start: 1, dur: 1.5, club:'Bandra Breakers', title:'Sunrise Seawall 7K', people: 23, cap:30, color: theme.primary, status:'confirmed' },
    { start: 3, dur: 1, club:'You', title:'Solo tempo run', solo: true, color: theme.ink },
    { start: 13, dur: 1.5, club:'Lodhi Night Owls', title:'Dusk 5K · slow', people: 11, cap:20, color: theme.accent, status:'interested' },
  ];
  return (
    <div data-screen-label="36 Calendar · Timeline" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding:'6px 20px 8px' }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
          <div>
            <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 600, letterSpacing: 1, textTransform:'uppercase' }}>April 2026</div>
            <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>This week</div>
          </div>
          <div style={{ display:'flex', gap: 6, background: theme.raised, padding: 3, borderRadius: 10, border: `1px solid ${theme.line}`, fontSize: 11 }}>
            <div style={{ padding:'5px 10px', borderRadius: 7, background: theme.ink, color: theme.surface, fontWeight: 600 }}>Day</div>
            <div style={{ padding:'5px 10px', color: theme.ink2, fontWeight: 600 }}>Agenda</div>
          </div>
        </div>
        {/* week strip */}
        <div style={{ display:'flex', gap: 4, marginTop: 14 }}>
          {['M 14','T 15','W 16','T 17','F 18','S 19','S 20'].map((d,i)=>{
            const active = i===2;
            const dot = [0,2,5].includes(i);
            return (
              <div key={d} style={{
                flex: 1, padding: '8px 0', textAlign:'center', borderRadius: 10,
                background: active?theme.ink:'transparent',
                color: active?theme.surface:theme.ink,
                display:'flex', flexDirection:'column', alignItems:'center', gap: 4,
              }}>
                <div style={{ fontSize: 9, letterSpacing: 0.5, opacity: active?0.7:0.6 }}>{d.split(' ')[0]}</div>
                <div style={{ fontSize: 15, fontWeight: 700 }}>{d.split(' ')[1]}</div>
                <div style={{ width: 4, height: 4, borderRadius: 999, background: dot ? (active?theme.primary:theme.primary) : 'transparent' }}/>
              </div>
            );
          })}
        </div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding:'10px 0 24px', position:'relative' }}>
        <div style={{ padding: '0 20px 8px', fontSize: 11, color: theme.ink3, fontWeight: 600, letterSpacing: 0.6, textTransform:'uppercase' }}>Wed · 16 Apr</div>
        <div style={{ position:'relative', minHeight: hours.length*54, padding:'0 20px' }}>
          {hours.map((h,i)=>(
            <div key={i} style={{
              display:'flex', gap: 10, alignItems:'flex-start',
              height: 54, position:'relative',
            }}>
              <div style={{ width: 34, flexShrink: 0, paddingTop: 0, fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.4 }}>
                {h} {i<7?'AM':'PM'}
              </div>
              <div style={{ flex: 1, borderTop:`1px solid ${theme.line}`, height:'100%' }}/>
            </div>
          ))}
          {/* now line */}
          <div style={{ position:'absolute', left: 44, right: 20, top: 54*2 + 30, display:'flex', alignItems:'center', gap: 6, pointerEvents:'none' }}>
            <div style={{ width: 8, height: 8, borderRadius: 999, background: theme.primary, boxShadow:`0 0 0 3px ${theme.primary}20`}}/>
            <div style={{ flex: 1, height: 1.5, background: theme.primary }}/>
            <div style={{ fontSize: 9, fontWeight: 700, color: theme.primary, letterSpacing: 0.4 }}>NOW · 7:30</div>
          </div>
          {/* events */}
          {events.map((e,i)=>(
            <div key={i} style={{
              position:'absolute', left: 60, right: 20,
              top: e.start*54 + 2, height: e.dur*54 - 4,
              borderRadius: 12, padding: 10,
              background: e.solo ? theme.surface : e.color,
              color: e.solo ? theme.ink : '#fff',
              border: e.solo ? `1.5px dashed ${theme.line2}` : 'none',
              display:'flex', flexDirection:'column', justifyContent: e.dur < 1 ? 'center' : 'space-between',
              overflow:'hidden',
            }}>
              <div>
                <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: 0.4, opacity: e.solo?0.5:0.85 }}>{e.club.toUpperCase()}</div>
                <div style={{ fontSize: 14, fontWeight: 600, marginTop: 2 }}>{e.title}</div>
              </div>
              {!e.solo && e.dur >= 1 && (
                <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
                  <div style={{ fontSize: 11, opacity: 0.85 }}>{e.people}/{e.cap} runners</div>
                  {e.status==='confirmed'
                    ? <div style={{ padding:'3px 8px', background:'rgba(255,255,255,0.25)', borderRadius: 999, fontSize: 9, fontWeight: 700, letterSpacing: 0.4 }}>✓ JOINED</div>
                    : <div style={{ padding:'3px 8px', background:'rgba(0,0,0,0.25)', borderRadius: 999, fontSize: 9, fontWeight: 700, letterSpacing: 0.4 }}>INTERESTED</div>}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

// View B — Agenda (days stacked)
function ScreenCalendarAgenda({ theme, type }) {
  const days = [
    {
      label:'TODAY · Wed 16 Apr', highlight: true,
      events:[
        { club:'Bandra Breakers', title:'Sunrise Seawall 7K', when:'6:00 AM', dist:'7K · 5:30', people:'23/30', status:'joined', color: theme.primary },
        { club:'Lodhi Night Owls', title:'Dusk 5K · slow', when:'7:30 PM', dist:'5K · 6:00', people:'11/20', status:'interested', color: theme.accent },
      ],
    },
    {
      label:'Thu 17 Apr',
      events:[
        { club:'You', title:'Rest day', rest: true },
      ],
    },
    {
      label:'Fri 18 Apr',
      events:[
        { club:'Cubbon Striders', title:'Tempo intervals 8K', when:'5:30 AM', dist:'8K · 4:50', people:'12/15', status:'waitlist', color: theme.ink },
      ],
    },
    {
      label:'Sat 19 Apr',
      events:[
        { club:'Bandra Breakers', title:'Long run · 15K', when:'5:45 AM', dist:'15K · 5:45', people:'18/30', status:'joined', color: theme.primary },
        { club:'Marina Milers', title:'Beach loop 6K', when:'6:30 AM', dist:'6K · 6:15', people:'22/25', color: theme.primary },
      ],
    },
  ];
  return (
    <div data-screen-label="37 Calendar · Agenda" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '6px 20px 8px' }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
          <div>
            <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 600, letterSpacing: 1, textTransform:'uppercase' }}>Your calendar</div>
            <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>April</div>
          </div>
          <div style={{ display:'flex', gap: 6, background: theme.raised, padding: 3, borderRadius: 10, border: `1px solid ${theme.line}`, fontSize: 11 }}>
            <div style={{ padding:'5px 10px', color: theme.ink2, fontWeight: 600 }}>Day</div>
            <div style={{ padding:'5px 10px', borderRadius: 7, background: theme.ink, color: theme.surface, fontWeight: 600 }}>Agenda</div>
          </div>
        </div>
        {/* stat strip */}
        <div style={{ display:'flex', gap: 8, marginTop: 14, background: theme.surface, borderRadius: 14, padding: 12, border: `1px solid ${theme.line}` }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.5, textTransform:'uppercase' }}>Booked</div>
            <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2 }}>5 runs</div>
          </div>
          <div style={{ width:1, background: theme.line }}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.5, textTransform:'uppercase' }}>Distance</div>
            <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2 }}>41 km</div>
          </div>
          <div style={{ width:1, background: theme.line }}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 10, color: theme.ink3, fontWeight: 600, letterSpacing: 0.5, textTransform:'uppercase' }}>Catches</div>
            <div style={{ fontFamily: type.display, fontSize: 20, fontWeight: type.displayWeight, marginTop: 2, color: theme.primary }}>3</div>
          </div>
        </div>
      </div>
      <div style={{ flex: 1, overflow:'auto', padding:'8px 0 20px' }}>
        {days.map((d,i)=>(
          <div key={i} style={{ padding: '10px 20px 6px' }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.8, textTransform:'uppercase', color: d.highlight? theme.primary : theme.ink3, marginBottom: 8 }}>
              {d.label}
            </div>
            {d.events.map((e,j)=>(
              e.rest ? (
                <div key={j} style={{
                  padding: 14, borderRadius: 14, border:`1.5px dashed ${theme.line2}`,
                  background: 'transparent', fontSize: 13, color: theme.ink3, fontStyle:'italic',
                  textAlign:'center',
                }}>Rest day · no runs scheduled</div>
              ) : (
                <div key={j} style={{
                  padding: 14, borderRadius: 14, background: theme.surface, border:`1px solid ${theme.line}`,
                  display:'flex', gap: 12, alignItems:'center', marginBottom: 8,
                }}>
                  <div style={{ width: 4, alignSelf:'stretch', borderRadius: 99, background: e.color, minHeight: 40 }}/>
                  <div style={{ flex: 1 }}>
                    <div style={{ display:'flex', gap: 10, alignItems:'baseline' }}>
                      <div style={{ fontSize: 11, color: theme.ink3, fontWeight: 700, letterSpacing: 0.4, textTransform:'uppercase' }}>{e.club}</div>
                    </div>
                    <div style={{ fontSize: 15, fontWeight: 600, marginTop: 2 }}>{e.title}</div>
                    <div style={{ fontSize: 12, color: theme.ink2, marginTop: 4, display:'flex', gap: 10 }}>
                      <span>{e.when}</span>
                      <span>·</span>
                      <span>{e.dist}</span>
                      <span>·</span>
                      <span>{e.people}</span>
                    </div>
                  </div>
                  {e.status==='joined' && <div style={{ padding:'4px 10px', fontSize: 9, fontWeight: 700, background: theme.primarySoft, color: theme.primary, borderRadius: 999, letterSpacing: 0.5 }}>✓ JOINED</div>}
                  {e.status==='interested' && <div style={{ padding:'4px 10px', fontSize: 9, fontWeight: 700, background: theme.raised, color: theme.ink2, borderRadius: 999, letterSpacing: 0.5, border:`1px solid ${theme.line2}` }}>INTERESTED</div>}
                  {e.status==='waitlist' && <div style={{ padding:'4px 10px', fontSize: 9, fontWeight: 700, background: theme.ink, color: theme.surface, borderRadius: 999, letterSpacing: 0.5 }}>WAITLIST #3</div>}
                </div>
              )
            ))}
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="home"/>
    </div>
  );
}

Object.assign(window, { ScreenCalendarTimeline, ScreenCalendarAgenda });
