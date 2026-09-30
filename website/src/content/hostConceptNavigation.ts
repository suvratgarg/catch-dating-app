// Canonical destinations; prototype source URLs are provenance only.
export const hostConceptRoutes = [
  {
    "id": "host_overview",
    "slug": "index",
    "path": "/host/overview/"
  },
  {
    "id": "host_platform",
    "slug": "host",
    "path": "/host/platform/"
  },
  {
    "id": "host_planners",
    "slug": "planners",
    "path": "/host/planners/"
  },
  {
    "id": "host_mixers",
    "slug": "mixers",
    "path": "/host/mixers/"
  },
  {
    "id": "host_clubs",
    "slug": "clubs",
    "path": "/host/clubs/"
  },
  {
    "id": "host_directory",
    "slug": "directory",
    "path": "/host/directory/"
  },
  {
    "id": "host_claim",
    "slug": "claim",
    "path": "/host/claim/"
  },
  {
    "id": "host_apply",
    "slug": "apply",
    "path": "/host/apply/"
  },
  {
    "id": "host_stack",
    "slug": "stack",
    "path": "/host/stack/"
  }
] as const;
export const hostConceptCopy = {
  eyebrow: 'Catch Host · content preview',
  notice: 'Illustrative concept content. Features, integrations, pricing and predicted outcomes here are discussion material, not a production availability promise.',
  contact: 'Discuss a supported walkthrough',
  headerContact: 'Request walkthrough',
  workflows: 'Explore workflows',
  live: 'Current live-event pilot',
  directory: 'Search current organiser listings',
  directorySearch: 'Search organisers',
  directoryPlaceholder: 'Search organisers, formats, cities…',
  directorySearchNote: 'This search opens the current directory. Sample cards below are fictional and are not claim authority.',
  claim: 'Continue to the existing claim flow',
  apply: 'Continue to the existing host application',
  consumer: 'Current consumer website',
  original: 'Source concept sections',
  noResults: 'No tools match this filter.',
  details: 'Show mapping details',
  hideDetails: 'Hide mapping details',
  tiers: 'Illustrative adoption levels',
  replay: 'Replay fictional activity',
  pause: 'Pause fictional activity',
  resume: 'Resume fictional activity',
  checkIns: 'Fictional check-ins',
  selectedTier: 'Selected adoption level',
  retained: 'Retained concept destination',
  nav: [
    {href:'/host/workflows/',label:'Workflows'},
    {href:'/host/platform/',label:'Capabilities'},
    {href:'/host/stack/',label:'Stack audit'},
    {href:'/host/directory/',label:'Directory concept'},
  ],
  additionalLinks: [
    {href:'/host/overview/',label:'Concept overview'},
    {href:'/host/claim/',label:'Claim concept'},
    {href:'/host/apply/',label:'Pilot application concept'},
  ],
  personaLinks: [
    {href:'/host/planners/',label:'Planners'},
    {href:'/host/mixers/',label:'Mixers'},
    {href:'/host/clubs/',label:'Clubs'},
  ],
} as const;
