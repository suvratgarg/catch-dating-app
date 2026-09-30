import {interpolateContent} from '@content/interpolate';
import { prototypeStackGroups, prototypeStackTiers, prototypeStackTools } from '@content/prototypeStackContent';
import { prototypeInteractionContent } from '@content/prototypeInteractionContent';

export type PrototypeStackTool = (typeof prototypeStackTools)[number];
export type PrototypeStackToolId = PrototypeStackTool['id'];
export type PrototypeStackTier = keyof typeof prototypeStackTiers;
export type PrototypeStackState = {
  readonly selectedIds: readonly PrototypeStackToolId[];
  readonly expandedIds: readonly PrototypeStackToolId[];
  readonly query: string;
};
export const initialPrototypeStackState: PrototypeStackState = { selectedIds: [], expandedIds: [], query: '' };

export type PrototypeStackAction =
  | { type: 'toggle-tool'; id: PrototypeStackToolId }
  | { type: 'toggle-detail'; id: PrototypeStackToolId }
  | { type: 'search'; query: string };

export function reducePrototypeStack(state: PrototypeStackState, action: PrototypeStackAction): PrototypeStackState {
  if (action.type === 'search') return { ...state, query: action.query };
  if (!prototypeStackTools.some((tool) => tool.id === action.id)) return state;
  if (action.type === 'toggle-detail') {
    if (!state.selectedIds.includes(action.id)) return state;
    return { ...state, expandedIds: toggleId(state.expandedIds, action.id) };
  }
  const selectedIds = toggleId(state.selectedIds, action.id);
  // Prototype rebuilds receipt rows after every selection, collapsing detail.
  return { ...state, selectedIds, expandedIds: [] };
}

function toggleId(ids: readonly PrototypeStackToolId[], id: PrototypeStackToolId): readonly PrototypeStackToolId[] {
  return ids.includes(id) ? ids.filter((candidate) => candidate !== id) : [...ids, id];
}

export function projectPrototypeStack(state: PrototypeStackState) {
  const selected = prototypeStackTools.filter((tool) => state.selectedIds.includes(tool.id));
  const query = state.query.trim().toLowerCase();
  const visibleGroups = prototypeStackGroups.flatMap((group) => {
    const tools = prototypeStackTools.filter((tool) => tool.group === group.id &&
      (!query || [tool.name, tool.job, tool.blurb].some((value) => value.toLowerCase().includes(query))));
    return tools.length ? [{ ...group, tools }] : [];
  });
  const replacementGroups = new Set(selected.filter((tool) => tool.kind === 'replace').map((tool) => tool.group));
  const managed = selected.some((tool) => tool.kind === 'program');
  const booking = selected.some((tool) => tool.kind === 'none') || replacementGroups.size >= 3;
  const tierId: PrototypeStackTier = managed ? 'managed' : booking ? 'booking' : 'alongside';
  const network = selected.some((tool) => 'network' in tool && tool.network);
  const retired = selected.filter((tool) => tool.kind === 'replace').length;
  const kept = selected.filter((tool) => tool.kind === 'keep').length;
  return {
    visibleGroups,
    selected,
    expandedIds: state.expandedIds.filter((id) => selected.some((tool) => tool.id === id)),
    count: selected.length,
    countLabel: interpolateContent(prototypeInteractionContent.stack.selectedCount, {count: selected.length}),
    retired,
    kept,
    statistics: selected.length ? interpolateContent(prototypeInteractionContent.stack.statistics, {retired, kept}) : '',
    tierId,
    tier: prototypeStackTiers[tierId],
    tierExplanation: prototypeStackTiers[tierId].why + (network && !managed ? prototypeInteractionContent.stack.networkSuffix : ''),
    network,
  };
}
