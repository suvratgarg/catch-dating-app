// Messages list + chat screens (2 chat styles via variant)

function ScreenMessages({ theme, type }) {
  const threads = [
    { name:'Riya', last:'haha see you Saturday then 👀', ago:'2m', run:'Bandra Breakers 7K', unread:2, seed:'riya-m', fresh:true },
    { name:'Aarav', last:'Coffee after next run?', ago:'1h', run:'Lodhi Night Owls', unread:0, seed:'aarav-m' },
    { name:'Zoya', last:'you: I can do 5:30 pace', ago:'3h', run:'Marina Milers', unread:0, seed:'zoya-m' },
    { name:'Kabir', last:'Typing…', ago:'6h', run:'Cubbon Striders', unread:1, seed:'kabir-m', typing:true },
    { name:'Aisha', last:'New run Tuesday — in?', ago:'1d', run:'Koregaon Kicks', unread:0, seed:'aisha-m' },
    { name:'Dev', last:'you: gg on that hill', ago:'2d', run:'Cubbon Striders', unread:0, seed:'dev-m' },
  ];
  const fresh = [
    { name:'Meera', seed:'meera-n' },
    { name:'Vivaan', seed:'vivaan-n' },
    { name:'Priya', seed:'priya-n' },
    { name:'Rohan', seed:'rohan-n' },
  ];
  return (
    <div data-screen-label="17 Messages" style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      <div style={{ padding: '8px 20px 8px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
        <div style={{ fontFamily: type.display, fontSize: 28, fontWeight: type.displayWeight, letterSpacing: type.displayTracking+'em' }}>Chats</div>
        <IconBtn theme={theme}><Icon.search c={theme.ink}/></IconBtn>
      </div>
      {/* fresh catches row */}
      <div style={{ padding: '4px 16px 10px', display:'flex', gap: 12, overflow:'hidden' }}>
        <div style={{ textAlign:'center', flexShrink: 0 }}>
          <div style={{ width: 64, height: 64, borderRadius: 999, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center', fontFamily: type.display, fontSize: 22, fontWeight: 700 }}>4</div>
          <div style={{ fontSize: 10, color: theme.ink2, marginTop: 4, fontWeight: 600, textTransform:'uppercase' }}>New catches</div>
        </div>
        {fresh.map(f=>(
          <div key={f.name} style={{ textAlign:'center', flexShrink:0 }}>
            <div style={{ width: 64, height: 64, borderRadius: 999, overflow:'hidden', border: `2.5px solid ${theme.primary}`, padding: 2, background: theme.surface }}>
              <div style={{ width: '100%', height: '100%', borderRadius: 999, overflow:'hidden' }}><PhotoBox seed={f.seed}/></div>
            </div>
            <div style={{ fontSize: 11, color: theme.ink2, marginTop: 4, fontWeight: 600 }}>{f.name}</div>
          </div>
        ))}
      </div>
      <div style={{ padding: '4px 20px 6px', display:'flex', gap: 8 }}>
        {['All','Unread','Matches'].map((c,i)=>(
          <Chip key={c} theme={theme} active={i===0}>{c}</Chip>
        ))}
      </div>
      <div style={{ flex:1, overflow:'auto', padding:'4px 0' }}>
        {threads.map((t,i)=>(
          <div key={i} style={{
            padding: '10px 20px', display:'flex', gap: 12, alignItems:'center',
            background: t.fresh ? theme.primarySoft : 'transparent',
          }}>
            <div style={{ width: 52, height: 52, borderRadius: 999, overflow:'hidden', flexShrink: 0, border: t.fresh?`2px solid ${theme.primary}`:'none' }}>
              <PhotoBox seed={t.seed}/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
                <div style={{ fontWeight: 600, fontSize: 15 }}>{t.name}</div>
                <div style={{ fontSize: 11, color: theme.ink3 }}>{t.ago}</div>
              </div>
              <div style={{ fontSize: 12, color: theme.ink3, marginTop: 1, display:'flex', alignItems:'center', gap: 4 }}>
                <Icon.route c={theme.ink3} s={11}/>{t.run}
              </div>
              <div style={{ fontSize: 13, color: t.typing?theme.primary:theme.ink2, marginTop: 4, display:'flex', justifyContent:'space-between', alignItems:'center', gap: 8 }}>
                <span style={{ overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap', fontStyle: t.typing?'italic':'normal' }}>{t.last}</span>
                {t.unread>0 && <span style={{ background: theme.primary, color: theme.primaryInk, fontSize: 10, fontWeight: 700, padding:'2px 7px', borderRadius: 999 }}>{t.unread}</span>}
              </div>
            </div>
          </div>
        ))}
      </div>
      <TabBar theme={theme} type={type} active="messages"/>
    </div>
  );
}

// Chat — default (bubble) variant
function ScreenChat({ theme, type, variant = 'bubbles' }) {
  const msgs = [
    { from:'them', text:'hey stride matcher 🏃', at:'7:14' },
    { from:'me', text:'lol you killed that hill segment', at:'7:15' },
    { from:'them', text:"I was trying NOT to puke. did it look intentional?", at:'7:15' },
    { from:'me', text:"100%. you glided.", at:'7:16' },
    { from:'them', text:"Saturday there's a 10K — same club. you in?", at:'7:18', icebreaker:true },
    { from:'me', text:"in. coffee after?", at:'7:19' },
    { from:'them', text:'obviously', at:'7:19' },
  ];
  const isMinimal = variant === 'minimal';
  return (
    <div data-screen-label={`18 Chat (${variant})`} style={{ width:'100%', height:'100%', background: theme.bg, color: theme.ink, display:'flex', flexDirection:'column' }}>
      <StatusBar theme={theme}/>
      {/* custom chat header */}
      <div style={{ padding: '6px 14px 8px', display:'flex', alignItems:'center', gap: 10, borderBottom: `1px solid ${theme.line}` }}>
        <IconBtn theme={theme}><Icon.back c={theme.ink}/></IconBtn>
        <div style={{ width: 40, height: 40, borderRadius: 999, overflow:'hidden' }}><PhotoBox seed="riya-main"/></div>
        <div style={{ flex:1 }}>
          <div style={{ fontWeight: 600, fontSize: 15 }}>Riya</div>
          <div style={{ fontSize: 11, color: theme.primary, fontWeight: 600, display:'flex', alignItems:'center', gap: 4 }}>
            <Icon.dot c={theme.primary} s={6}/> Ran together today
          </div>
        </div>
        <IconBtn theme={theme}><Icon.person c={theme.ink}/></IconBtn>
      </div>
      {/* shared run context card */}
      <div style={{ padding: '10px 16px 0' }}>
        <div style={{
          background: theme.surface, border:`1px solid ${theme.line}`, borderRadius: 14,
          padding: 12, display:'flex', alignItems:'center', gap: 10,
        }}>
          <div style={{ width:38, height:38, borderRadius: 10, background: theme.primarySoft, color: theme.primary, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon.route c={theme.primary} s={18}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 600 }}>You both ran Bandra Breakers 7K</div>
            <div style={{ fontSize: 11, color: theme.ink2 }}>Today · 5:26 & 5:30 /km · your PR</div>
          </div>
          <Chip theme={theme}>Plan next →</Chip>
        </div>
      </div>
      {/* messages */}
      <div style={{ flex: 1, overflow:'auto', padding: '14px 16px 8px', display:'flex', flexDirection:'column', gap: isMinimal? 4 : 8 }}>
        <div style={{ textAlign:'center', fontSize: 11, color: theme.ink3, margin: '4px 0 6px', fontFamily: type.text, letterSpacing: 0.6 }}>MATCHED AT 11:04 AM</div>
        {msgs.map((m,i)=> isMinimal ? (
          <div key={i} style={{
            display:'flex', gap: 8, alignItems:'baseline',
            color: m.from==='me'?theme.ink:theme.ink,
            justifyContent: m.from==='me'?'flex-end':'flex-start',
          }}>
            <div style={{ maxWidth: '78%' }}>
              <span style={{ color: theme.ink3, fontSize: 11, fontWeight: 600, marginRight: 6 }}>
                {m.from==='me'?'you':'Riya'}
              </span>
              <span style={{ fontSize: 15, lineHeight: 1.4, color: theme.ink }}>{m.text}</span>
              <span style={{ color: theme.ink3, fontSize: 10, marginLeft: 6 }}>{m.at}</span>
            </div>
          </div>
        ) : (
          <div key={i} style={{ display:'flex', justifyContent: m.from==='me'?'flex-end':'flex-start' }}>
            <div style={{
              maxWidth: '78%',
              padding: '10px 14px', borderRadius: 18,
              borderBottomRightRadius: m.from==='me'?4:18,
              borderBottomLeftRadius:  m.from==='them'?4:18,
              background: m.from==='me' ? theme.primary : theme.surface,
              color: m.from==='me' ? theme.primaryInk : theme.ink,
              border: m.from==='them'?`1px solid ${theme.line}`:'none',
              fontSize: 15, lineHeight: 1.35,
            }}>
              {m.icebreaker && <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 0.8, textTransform:'uppercase', opacity: 0.65, marginBottom: 2 }}>ICEBREAKER</div>}
              {m.text}
            </div>
          </div>
        ))}
      </div>
      {/* composer */}
      <div style={{ padding: '8px 12px 14px', borderTop: `1px solid ${theme.line}`, background: theme.surface, display:'flex', alignItems:'center', gap: 8 }}>
        <IconBtn theme={theme}><Icon.plus c={theme.ink}/></IconBtn>
        <div style={{ flex:1, background: theme.raised, borderRadius: 999, padding: '10px 16px', fontSize: 14, color: theme.ink3, border:`1px solid ${theme.line}` }}>
          Say something nice…
        </div>
        <div style={{ width: 40, height: 40, borderRadius: 999, background: theme.primary, color: theme.primaryInk, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon.send c={theme.primaryInk}/>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenMessages, ScreenChat });
