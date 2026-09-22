import {useMutation} from "@tanstack/react-query";
import {useCallback, useRef, useState} from "react";
import type {AdminGrantOrganizerEntitlementCallablePayload} from
  "../../../generated/contracts/adminGrantOrganizerEntitlementCallablePayload";
import type {AdminRevokeOrganizerEntitlementGrantCallablePayload} from
  "../../../generated/contracts/adminRevokeOrganizerEntitlementGrantCallablePayload";
import type {OrganizerEntitlementCallableResponse} from
  "../../../generated/contracts/organizerEntitlementCallableResponse";
import {useAdminPendingOperationGuard} from
  "../../../shared/pendingOperation";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {
  grantOrganizerEntitlement,
  loadOrganizerEntitlement,
  revokeOrganizerEntitlementGrant,
} from "../api/financeOpsRepository";

export type OrganizerEntitlementSku =
  AdminGrantOrganizerEntitlementCallablePayload["sku"];
export type OrganizerEntitlementUnit =
  AdminGrantOrganizerEntitlementCallablePayload["unit"];
export type OrganizerEntitlementSource =
  AdminGrantOrganizerEntitlementCallablePayload["source"];

export interface OrganizerEntitlementGrantForm {
  sku: OrganizerEntitlementSku;
  unit: OrganizerEntitlementUnit;
  quantity: string;
  validFrom: string;
  validUntil: string;
  source: OrganizerEntitlementSource;
  receiptRef: string;
  note: string;
}

export interface OrganizerEntitlementController {
  organizerId: string;
  entitlement: OrganizerEntitlementCallableResponse | null;
  grantForm: OrganizerEntitlementGrantForm;
  revokeTargetGrantId: string | null;
  revokeReason: string;
  isLoading: boolean;
  isGranting: boolean;
  isRevoking: boolean;
  grantDisabledReason: string | null;
  revokeDisabledReason: string | null;
  setOrganizerId: (value: string) => void;
  setGrantField: <K extends keyof OrganizerEntitlementGrantForm>(
    key: K,
    value: OrganizerEntitlementGrantForm[K]
  ) => void;
  setRevokeTargetGrantId: (value: string | null) => void;
  setRevokeReason: (value: string) => void;
  load: () => Promise<boolean>;
  grant: () => Promise<boolean>;
  revoke: () => Promise<boolean>;
}

const defaultGrantForm: OrganizerEntitlementGrantForm = {
  sku: "wedding_pro",
  unit: "program",
  quantity: "1",
  validFrom: "",
  validUntil: "",
  source: "manualInvoice",
  receiptRef: "",
  note: "",
};

const organizerEntitlementKeys = {
  load: () =>
    [...adminQueryKeys.all, "finance", "organizer-entitlement-load"] as const,
  grant: () =>
    [...adminQueryKeys.all, "finance", "organizer-entitlement-grant"] as const,
  revoke: () =>
    [...adminQueryKeys.all, "finance", "organizer-entitlement-revoke"] as const,
};

export function useOrganizerEntitlementController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}): OrganizerEntitlementController {
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const loadMutation = useMutation({
    mutationKey: organizerEntitlementKeys.load(),
    mutationFn: loadOrganizerEntitlement,
  });
  const grantMutation = useMutation({
    mutationKey: organizerEntitlementKeys.grant(),
    mutationFn: grantOrganizerEntitlement,
  });
  const revokeMutation = useMutation({
    mutationKey: organizerEntitlementKeys.revoke(),
    mutationFn: revokeOrganizerEntitlementGrant,
  });
  const [organizerId, setOrganizerIdState] = useState("");
  const [entitlement, setEntitlement] =
    useState<OrganizerEntitlementCallableResponse | null>(null);
  const [grantForm, setGrantForm] = useState(defaultGrantForm);
  const [revokeTargetGrantId, setRevokeTargetGrantId] =
    useState<string | null>(null);
  const [revokeReason, setRevokeReason] = useState("");
  const grantRetry = useRef<{
    signature: string;
    payload: AdminGrantOrganizerEntitlementCallablePayload;
  } | null>(null);
  const revokeRetry = useRef<{
    signature: string;
    payload: AdminRevokeOrganizerEntitlementGrantCallablePayload;
  } | null>(null);

  const setOrganizerId = useCallback((value: string) => {
    setOrganizerIdState(value);
    setEntitlement(null);
    setRevokeTargetGrantId(null);
    grantRetry.current = null;
    revokeRetry.current = null;
  }, []);

  const setGrantField = useCallback(<
    K extends keyof OrganizerEntitlementGrantForm,
  >(key: K, value: OrganizerEntitlementGrantForm[K]) => {
    setGrantForm((current) => {
      const next = {...current, [key]: value};
      if (key === "sku") {
        const catalogUnit = entitlement?.skuCatalog[value as OrganizerEntitlementSku]?.unit;
        if (catalogUnit) next.unit = catalogUnit;
      }
      return next;
    });
    grantRetry.current = null;
  }, [entitlement]);

  const load = useCallback(async () => {
    const trimmedOrganizerId = organizerId.trim();
    if (!trimmedOrganizerId) {
      onError("Enter the organizer identifier.");
      return false;
    }
    try {
      const response = await loadMutation.mutateAsync({
        organizerId: trimmedOrganizerId,
      });
      setOrganizerIdState(trimmedOrganizerId);
      setEntitlement(response);
      setRevokeTargetGrantId(null);
      grantRetry.current = null;
      revokeRetry.current = null;
      onError(null);
      onNotice("Current organizer entitlement ledger loaded.");
      return true;
    } catch (error) {
      setEntitlement(null);
      onError(messageFromError(
        error,
        "Unable to load the organizer entitlement ledger."
      ));
      return false;
    }
  }, [loadMutation, onError, onNotice, organizerId]);

  const grantDisabledReason = grantBlocker({grantForm, organizerId});
  const grant = useCallback(async () => {
    const trimmedOrganizerId = organizerId.trim();
    if (grantDisabledReason) {
      onError(grantDisabledReason);
      return false;
    }
    const withoutOperationId = {
      organizerId: trimmedOrganizerId,
      sku: grantForm.sku,
      unit: grantForm.unit,
      quantityTotal: parseCountValue(grantForm.quantity)!,
      source: grantForm.source,
      ...(grantForm.validFrom.trim() ?
        {validFromMillis: Date.parse(grantForm.validFrom)} : {}),
      ...(grantForm.validUntil.trim() ?
        {validUntilMillis: Date.parse(grantForm.validUntil)} : {}),
      ...(grantForm.receiptRef.trim() ?
        {receiptRef: grantForm.receiptRef.trim()} : {}),
      ...(grantForm.note.trim() ? {note: grantForm.note.trim()} : {}),
    };
    const signature = JSON.stringify(withoutOperationId);
    const payload = grantRetry.current?.signature === signature ?
      grantRetry.current.payload : {
        operationId: createOperationId("entitlement-grant"),
        ...withoutOperationId,
      };
    grantRetry.current = {signature, payload};
    const operation = beginOperation();
    if (!operation) return false;
    try {
      const result = await grantMutation.mutateAsync(payload);
      grantRetry.current = null;
      setRevokeTargetGrantId(null);
      setRevokeReason("");
      onError(null);
      onNotice(result.replayed ?
        "That grant operation was already recorded; the ledger was refreshed." :
        `Entitlement grant recorded at revision ${result.revision}. It grants no dispatch authority.`);
      if (entitlement) {
        try {
          setEntitlement(await loadMutation.mutateAsync({
            organizerId: trimmedOrganizerId,
          }));
        } catch {
          setEntitlement(null);
        }
      }
      return true;
    } catch (error) {
      onError(messageFromError(
        error,
        "Unable to record the entitlement grant."
      ));
      return false;
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    endOperation,
    entitlement,
    grantDisabledReason,
    grantForm,
    grantMutation,
    loadMutation,
    onError,
    onNotice,
    organizerId,
  ]);

  const revokeDisabledReason = revokeBlocker({
    entitlement,
    revokeReason,
    revokeTargetGrantId,
  });
  const revoke = useCallback(async () => {
    const trimmedOrganizerId = organizerId.trim();
    if (!entitlement || !revokeTargetGrantId || revokeDisabledReason) {
      onError(revokeDisabledReason ?? "Choose a grant to revoke.");
      return false;
    }
    const withoutOperationId = {
      organizerId: trimmedOrganizerId,
      grantId: revokeTargetGrantId,
      reason: revokeReason.trim(),
    };
    const signature = JSON.stringify(withoutOperationId);
    const payload = revokeRetry.current?.signature === signature ?
      revokeRetry.current.payload : {
        operationId: createOperationId("entitlement-revoke"),
        ...withoutOperationId,
      };
    revokeRetry.current = {signature, payload};
    const operation = beginOperation();
    if (!operation) return false;
    try {
      const result = await revokeMutation.mutateAsync(payload);
      revokeRetry.current = null;
      setRevokeTargetGrantId(null);
      setRevokeReason("");
      onError(null);
      onNotice(result.replayed ?
        "That revoke operation was already recorded; the ledger was refreshed." :
        `Entitlement grant revoked at revision ${result.revision}.`);
      try {
        setEntitlement(await loadMutation.mutateAsync({
          organizerId: trimmedOrganizerId,
        }));
      } catch {
        setEntitlement(null);
      }
      return true;
    } catch (error) {
      onError(messageFromError(
        error,
        "Unable to revoke the entitlement grant."
      ));
      return false;
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    endOperation,
    entitlement,
    loadMutation,
    onError,
    onNotice,
    organizerId,
    revokeDisabledReason,
    revokeMutation,
    revokeReason,
    revokeTargetGrantId,
  ]);

  return {
    organizerId,
    entitlement,
    grantForm,
    revokeTargetGrantId,
    revokeReason,
    isLoading: loadMutation.isPending,
    isGranting: grantMutation.isPending,
    isRevoking: revokeMutation.isPending,
    grantDisabledReason,
    revokeDisabledReason,
    setOrganizerId,
    setGrantField,
    setRevokeTargetGrantId,
    setRevokeReason,
    load,
    grant,
    revoke,
  };
}

export function parseCountValue(value: string): number | null {
  const trimmed = value.trim();
  if (!/^\d+$/u.test(trimmed)) return null;
  const parsed = Number(trimmed);
  return Number.isSafeInteger(parsed) && parsed >= 1 && parsed <= 1_000_000 ?
    parsed : null;
}

function grantBlocker({
  grantForm,
  organizerId,
}: {
  grantForm: OrganizerEntitlementGrantForm;
  organizerId: string;
}): string | null {
  if (!organizerId.trim()) return "Enter the organizer identifier.";
  if (parseCountValue(grantForm.quantity) === null) {
    return "Enter a whole grant quantity of 1 or more.";
  }
  const validFrom = grantForm.validFrom.trim() ?
    Date.parse(grantForm.validFrom) : null;
  if (grantForm.validFrom.trim() && !Number.isSafeInteger(validFrom)) {
    return "Valid-from must be a real date-time.";
  }
  const validUntil = grantForm.validUntil.trim() ?
    Date.parse(grantForm.validUntil) : null;
  if (grantForm.validUntil.trim() && !Number.isSafeInteger(validUntil)) {
    return "Valid-until must be a real date-time.";
  }
  if (validFrom !== null && validUntil !== null && validUntil <= validFrom) {
    return "Valid-until must be after valid-from.";
  }
  if (grantForm.source === "manualInvoice" && !grantForm.receiptRef.trim()) {
    return "Manual invoice grants need the invoice receipt reference.";
  }
  return null;
}

function revokeBlocker({
  entitlement,
  revokeReason,
  revokeTargetGrantId,
}: {
  entitlement: OrganizerEntitlementCallableResponse | null;
  revokeReason: string;
  revokeTargetGrantId: string | null;
}): string | null {
  if (!entitlement) return "Load the current entitlement ledger first.";
  if (!revokeTargetGrantId) return "Choose a grant to revoke.";
  const grant = entitlement.grants.find((entry) =>
    entry.grantId === revokeTargetGrantId);
  if (!grant) return "The chosen grant is no longer in this ledger.";
  if (grant.revoked) return "This entitlement grant is already revoked.";
  if (!revokeReason.trim()) return "Add a revoke reason.";
  return null;
}

function createOperationId(prefix: string): string {
  const entropy = globalThis.crypto?.randomUUID?.() ??
    `${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;
  return `${prefix}-${entropy}`.replace(/[^A-Za-z0-9_-]+/gu, "-");
}

function messageFromError(error: unknown, fallback: string): string {
  if (error instanceof Error && error.message.trim()) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
