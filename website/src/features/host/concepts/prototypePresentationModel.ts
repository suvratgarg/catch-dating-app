import { prototypeInteractionContent } from '@content/prototypeInteractionContent';

export const prototypeTierRotationMs = 4200;
export const prototypeConsoleTickMs = 1600;
export type PrototypeMotionContext = { reducedMotion: boolean; documentHidden: boolean; finePointer: boolean };
export type PrototypeTierState = { activeIndex: number; pinned: boolean };
export const initialPrototypeTierState: PrototypeTierState = { activeIndex: 0, pinned: false };
export type PrototypeTierAction =
  | { type: 'select-card'; index: number }
  | { type: 'select-ring'; index: number }
  | { type: 'hover'; index: number }
  | { type: 'tick' };

export function reducePrototypeTier(state: PrototypeTierState, action: PrototypeTierAction, context: PrototypeMotionContext, count = 3): PrototypeTierState {
  if (count <= 0) return state;
  if (action.type === 'tick') {
    return state.pinned || context.reducedMotion || context.documentHidden ? state : { ...state, activeIndex: (state.activeIndex + 1) % count };
  }
  if (action.type === 'hover' && !context.finePointer) return state;
  const index = action.type === 'select-ring' ? count - 1 - action.index : action.index;
  if (!Number.isInteger(index) || index < 0 || index >= count) return state;
  return { activeIndex: index, pinned: state.pinned || action.type !== 'hover' };
}

export function prototypeActiveRingIndex(state: PrototypeTierState, count = 3): number {
  return count - 1 - state.activeIndex;
}

export type PrototypeConsoleState = { visibleRows: number; checkIns: number };
export function createPrototypeConsoleState(reducedMotion = false): PrototypeConsoleState {
  return { visibleRows: reducedMotion ? prototypeInteractionContent.console.rows.length : 0, checkIns: prototypeInteractionContent.console.initialCheckIns };
}

export function tickPrototypeConsole(state: PrototypeConsoleState, context: Pick<PrototypeMotionContext, 'reducedMotion' | 'documentHidden'>): PrototypeConsoleState {
  if (context.reducedMotion || context.documentHidden) return state;
  const rows = prototypeInteractionContent.console.rows;
  if (state.visibleRows >= rows.length) return { ...state, visibleRows: 0 };
  const row = rows[state.visibleRows];
  return { visibleRows: state.visibleRows + 1, checkIns: state.checkIns + (row.checkIn ? 1 : 0) };
}
