import { describe, expect, it } from 'vitest';
import { createPrototypeConsoleState, initialPrototypeTierState, prototypeActiveRingIndex, reducePrototypeTier, tickPrototypeConsole } from './prototypePresentationModel';

const activeContext = { reducedMotion: false, documentHidden: false, finePointer: true };

describe('retained tier selector', () => {
  it('maps reverse DOM ring order to card order and pins explicit selection', () => {
    const state = reducePrototypeTier(initialPrototypeTierState, { type: 'select-ring', index: 0 }, activeContext);
    expect(state).toEqual({ activeIndex: 2, pinned: true });
    expect(prototypeActiveRingIndex(state)).toBe(0);
    expect(reducePrototypeTier(state, { type: 'tick' }, activeContext)).toBe(state);
  });
  it('rotates and wraps until pinned, skips hidden and reduced-motion contexts', () => {
    let state = initialPrototypeTierState;
    for (let i = 0; i < 3; i++) state = reducePrototypeTier(state, { type: 'tick' }, activeContext);
    expect(state.activeIndex).toBe(0);
    expect(reducePrototypeTier(state, { type: 'tick' }, { ...activeContext, documentHidden: true })).toBe(state);
    expect(reducePrototypeTier(state, { type: 'tick' }, { ...activeContext, reducedMotion: true })).toBe(state);
  });
  it('fine-pointer hover selects without pinning, while coarse pointers ignore hover', () => {
    const hovered = reducePrototypeTier(initialPrototypeTierState, { type: 'hover', index: 1 }, activeContext);
    expect(hovered).toEqual({ activeIndex: 1, pinned: false });
    expect(reducePrototypeTier(hovered, { type: 'tick' }, activeContext).activeIndex).toBe(2);
    expect(reducePrototypeTier(initialPrototypeTierState, { type: 'hover', index: 1 }, { ...activeContext, finePointer: false })).toBe(initialPrototypeTierState);
  });
  it('ignores invalid indices and zero-length selectors', () => {
    expect(reducePrototypeTier(initialPrototypeTierState, { type: 'select-card', index: -1 }, activeContext)).toBe(initialPrototypeTierState);
    expect(reducePrototypeTier(initialPrototypeTierState, { type: 'select-ring', index: 0 }, activeContext, 0)).toBe(initialPrototypeTierState);
  });
});

describe('retained fictional console replay', () => {
  it('reveals six rows, increments only check-ins and loops feed without resetting original counter behavior', () => {
    let state = createPrototypeConsoleState();
    const counts: number[] = [];
    for (let i = 0; i < 6; i++) {
      state = tickPrototypeConsole(state, activeContext);
      counts.push(state.checkIns);
    }
    expect(counts).toEqual([32, 32, 32, 33, 33, 33]);
    state = tickPrototypeConsole(state, activeContext);
    expect(state).toEqual({ visibleRows: 0, checkIns: 33 });
    expect(tickPrototypeConsole(state, activeContext)).toEqual({ visibleRows: 1, checkIns: 34 });
  });
  it('shows all rows without changing the counter for reduced motion and pauses when hidden', () => {
    const reduced = createPrototypeConsoleState(true);
    expect(reduced).toEqual({ visibleRows: 6, checkIns: 31 });
    expect(tickPrototypeConsole(reduced, { ...activeContext, reducedMotion: true })).toBe(reduced);
    const normal = createPrototypeConsoleState();
    expect(tickPrototypeConsole(normal, { ...activeContext, documentHidden: true })).toBe(normal);
  });
});
