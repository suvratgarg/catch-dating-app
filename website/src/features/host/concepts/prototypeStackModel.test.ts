import { describe, expect, it } from 'vitest';
import { prototypeStackGroups, prototypeStackTools } from '@content/prototypeStackContent';
import { initialPrototypeStackState, projectPrototypeStack, reducePrototypeStack, type PrototypeStackState, type PrototypeStackToolId } from './prototypeStackModel';

function choose(...selectedIds: PrototypeStackToolId[]): PrototypeStackState {
  return { ...initialPrototypeStackState, selectedIds };
}

describe('retained stack audit behavior', () => {
  it('preserves all 37 distinct tools in eight nonempty groups', () => {
    expect(prototypeStackTools).toHaveLength(37);
    expect(new Set(prototypeStackTools.map((tool) => tool.id)).size).toBe(37);
    expect(prototypeStackGroups).toHaveLength(8);
    expect(projectPrototypeStack(initialPrototypeStackState).visibleGroups).toHaveLength(8);
  });
  it('starts alongside with an empty receipt and no statistics', () => {
    expect(projectPrototypeStack(initialPrototypeStackState)).toMatchObject({ count: 0, tierId: 'alongside', statistics: '', selected: [] });
  });
  it('preserves source order regardless of selection order and ignores unknown or repeated ids', () => {
    const state = choose('multiday', 'gforms', 'luma', 'gforms');
    expect(projectPrototypeStack(state).selected.map((tool) => tool.id)).toEqual(['luma', 'gforms', 'multiday']);
    expect(projectPrototypeStack({ ...state, selectedIds: [...state.selectedIds, 'untrusted'] as PrototypeStackToolId[] }).count).toBe(3);
  });
  it('searches name, job and blurb case-insensitively and hides empty groups', () => {
    expect(projectPrototypeStack({ ...choose('luma'), query: '  RAZORPAY ' }).visibleGroups.map((group) => group.id)).toEqual(['payments']);
    expect(projectPrototypeStack({ ...initialPrototypeStackState, query: 'master sheet' }).visibleGroups[0].tools.map((tool) => tool.id)).toEqual(['gsheets', 'excel']);
    expect(projectPrototypeStack({ ...initialPrototypeStackState, query: 'general-purpose' }).visibleGroups[0].tools.map((tool) => tool.id)).toEqual(['eventbrite']);
    expect(projectPrototypeStack({ ...initialPrototypeStackState, query: 'not-a-tool' }).visibleGroups).toEqual([]);
  });
  it('filtering never deselects hidden tools or removes their receipts', () => {
    const state = reducePrototypeStack(choose('luma', 'paper'), { type: 'search', query: 'razorpay' });
    expect(projectPrototypeStack(state)).toMatchObject({ count: 2, kept: 1, retired: 1 });
  });
  it('counts replacement groups, not tool count, for the booking threshold', () => {
    expect(projectPrototypeStack(choose('gforms', 'typeform', 'fillout', 'tally')).tierId).toBe('alongside');
    expect(projectPrototypeStack(choose('gforms', 'upi')).tierId).toBe('alongside');
    expect(projectPrototypeStack(choose('gforms', 'upi', 'paper')).tierId).toBe('booking');
  });
  it('no platform selects booking; program scope overrides every other choice', () => {
    expect(projectPrototypeStack(choose('noplatform')).tierId).toBe('booking');
    expect(projectPrototypeStack(choose('noplatform', 'gforms', 'upi', 'paper', 'multiday')).tierId).toBe('managed');
  });
  it('keeps program and no-platform selections separate from kept/retired totals', () => {
    expect(projectPrototypeStack(choose('luma', 'gforms', 'noplatform', 'multiday'))).toMatchObject({ count: 4, kept: 1, retired: 1, statistics: '1 retired · 1 kept' });
  });
  it('adds network explanation without changing the recommendation, except for managed scope', () => {
    const alone = projectPrototypeStack(choose('igads'));
    expect(alone.tierId).toBe('alongside');
    expect(alone.tierExplanation).toContain('CrossPaths');
    const managed = projectPrototypeStack(choose('igads', 'multiday'));
    expect(managed.network).toBe(true);
    expect(managed.tierExplanation).not.toContain('CrossPaths');
  });
  it('toggles selections and collapses recreated receipt details', () => {
    const selected = reducePrototypeStack(initialPrototypeStackState, { type: 'toggle-tool', id: 'luma' });
    const expanded = reducePrototypeStack(selected, { type: 'toggle-detail', id: 'luma' });
    expect(expanded.expandedIds).toEqual(['luma']);
    expect(reducePrototypeStack(expanded, { type: 'toggle-detail', id: 'luma' }).expandedIds).toEqual([]);
    expect(reducePrototypeStack(expanded, { type: 'toggle-tool', id: 'paper' }).expandedIds).toEqual([]);
    expect(reducePrototypeStack(expanded, { type: 'toggle-tool', id: 'luma' }).selectedIds).toEqual([]);
    expect(reducePrototypeStack(initialPrototypeStackState, { type: 'toggle-detail', id: 'luma' })).toBe(initialPrototypeStackState);
  });
});
