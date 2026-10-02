import fs from 'node:fs';

// Summarizes untracked integration output; never writes a repository receipt.
const filename = process.argv[2];
if (!filename) throw new Error('Usage: node integration_test/host_audience_profile_summary.mjs <integration_response_data.json>');
const report = JSON.parse(fs.readFileSync(filename, 'utf8'));
if (!report.fixture?.profileMode) throw new Error('Expected an actual Flutter profile-mode run.');
const phases = [...new Set([
  ...Object.keys(report).filter(key => key.endsWith('_frames')).map(key => key.replace(/_frames$/, '')),
  ...report.fixture.events.map(event => event.phase),
])];
console.log(JSON.stringify({
  platform: report.fixture.platform,
  syntheticDelays: {
    formsMs: report.fixture.formsDelayMs,
    responsesMs: report.fixture.responsesDelayMs,
    groupsPageMs: report.fixture.groupPageDelayMs,
    peopleFirstPageMs: report.fixture.peopleFirstPageMs,
    summaryMs: report.fixture.summaryMs,
    messagingMs: report.fixture.messagingMs,
    largeListPageMs: report.fixture.largeListPageMs,
  },
  phases: phases.map(phase => {
    const events = report.fixture.events.filter(event => event.phase === phase);
    const starts = events.filter(event => event.event.endsWith('.start'));
    const requests = Object.fromEntries([...new Set(starts.map(event => event.event))]
      .map(name => [name.replace('.start', ''), starts.filter(event => event.event === name).length]));
    const frames = report[`${phase}_frames`];
    return {
      phase,
      requests,
      visibleWaitMs: events.find(event => event.event === 'visible')?.elapsedMs,
      visibleWaitsMs: events.filter(event => event.event === 'visible').length > 1
        ? events.filter(event => event.event === 'visible').map(event => event.elapsedMs) : undefined,
      allRowsLoadedMs: events.find(event => event.event === 'allRowsLoaded')?.elapsedMs,
      // Payload markers record UTF-8 JSON bytes, independently of duration markers.
      syntheticPayloadBytes: events.filter(event => event.event.endsWith('.payloadBytes'))
        .reduce((total, event) => total + event.elapsedMs, 0),
      decodeTotalMs: events.filter(event => event.event.endsWith('.decodeMs'))
        .reduce((total, event) => total + event.elapsedMs, 0),
      decodeWorstMs: Math.max(0, ...events.filter(event => event.event.endsWith('.decodeMs'))
        .map(event => event.elapsedMs)),
      firstFormsToResponsesStartMs: events.find(event => event.event === 'responses.start')?.atMs -
        events.find(event => event.event === 'forms.start')?.atMs || undefined,
      frames: frames && {
        count: frames.frame_count,
        buildP99Ms: frames['99th_percentile_frame_build_time_millis'],
        rasterP99Ms: frames['99th_percentile_frame_rasterizer_time_millis'],
        worstBuildMs: frames.worst_frame_build_time_millis,
        buildBudgetMisses: frames.missed_frame_build_budget_count,
        rasterBudgetMisses: frames.missed_frame_rasterizer_budget_count,
      },
    };
  }),
}, null, 2));
