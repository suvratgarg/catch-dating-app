import fs from 'node:fs';

// Summarizes untracked integration output; never writes a repository receipt.
const filename = process.argv[2];
if (!filename) throw new Error('Usage: node tool/perf/host_audience_profile_summary.mjs <integration_response_data.json>');
const report = JSON.parse(fs.readFileSync(filename, 'utf8'));
if (!report.fixture?.profileMode) throw new Error('Expected an actual Flutter profile-mode run.');
const phases = [...new Set(report.fixture.events.map(event => event.phase))];
console.log(JSON.stringify({
  platform: report.fixture.platform,
  syntheticDelays: {
    formsMs: report.fixture.formsDelayMs,
    responsesMs: report.fixture.responsesDelayMs,
    groupsPageMs: report.fixture.groupPageDelayMs,
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
