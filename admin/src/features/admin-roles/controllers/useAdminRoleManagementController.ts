import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminListAdminRoleAssignmentsPayload,
  AdminRoleAssignmentRow,
  AdminRoleClaim,
  AdminSetAdminUserRolesResponse,
  AdminUserRoleRecord,
} from "../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {
  loadAdminRoleAssignments,
  loadAdminUserRoles,
  saveAdminUserRoles,
} from "../api/adminRoleRepository";
import {
  adminRolePolicies,
  adminRolePolicyList,
  type AdminRolePolicy,
} from "./adminRolePolicies";

export type AdminRoleAssignmentStatusFilter =
  NonNullable<AdminListAdminRoleAssignmentsPayload["status"]>;

export interface AdminRoleScopeContract {
  canLoad: boolean;
  normalizedUid: string | null;
  assignmentPath: string | null;
  statusLabel: string;
  statusDetail: string;
  isSelfTarget: boolean;
  sourceOfTruth: string[];
  blockedInputs: string[];
  blockedActions: string[];
}

export interface AdminRoleDiff {
  added: AdminRoleClaim[];
  removed: AdminRoleClaim[];
}

export interface AdminRoleSaveReceipt {
  targetUid: string;
  assignmentPath: string;
  beforeRoles: AdminRoleClaim[];
  afterRoles: AdminRoleClaim[];
}

export interface AdminRoleManagementController {
  assignmentFilter: AdminRoleAssignmentStatusFilter;
  assignmentGeneratedAt: string | null;
  assignmentRows: AdminRoleAssignmentRow[];
  assignmentVisibleRows: AdminRoleAssignmentRow[];
  assignmentQuery: string;
  assignmentCapped: boolean;
  highRiskConfirmed: boolean;
  hasHighRiskChange: boolean;
  isAssignmentListLoading: boolean;
  isLoading: boolean;
  isSaving: boolean;
  note: string;
  roleDiff: AdminRoleDiff;
  rolePolicies: readonly AdminRolePolicy[];
  saveReceipt: AdminRoleSaveReceipt | null;
  selectedRoles: AdminRoleClaim[];
  selectedTargetUid: string | null;
  selectedUnavailable: boolean;
  selectedUser: AdminUserRoleRecord | null;
  scopeContract: AdminRoleScopeContract;
  targetUid: string;
  validationIssue: string | null;
  load: (nextTargetUid?: string) => Promise<boolean>;
  refreshAssignments: () => Promise<void>;
  save: () => Promise<boolean>;
  selectAssignment: (row: AdminRoleAssignmentRow) => void;
  setAssignmentFilter: (value: AdminRoleAssignmentStatusFilter) => void;
  setAssignmentQuery: (value: string) => void;
  setHighRiskConfirmed: (value: boolean) => void;
  setNote: (value: string) => void;
  setTargetUid: (value: string) => void;
  toggleRole: (role: AdminRoleClaim, checked: boolean) => void;
}

export function useAdminRoleManagementController({
  currentUserUid,
  onError,
  onNotice,
  onSelectTargetUid,
  selectedTargetUid,
}: {
  currentUserUid: string | null;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onSelectTargetUid?: (targetUid: string) => void;
  selectedTargetUid?: string | null;
}): AdminRoleManagementController {
  const queryClient = useQueryClient();
  const [fallbackTargetUid, setFallbackTargetUid] = useState<string | null>(null);
  const controlledTargetUid = selectedTargetUid === undefined ?
    fallbackTargetUid : selectedTargetUid;
  const normalizedSelectedUid = normalizeUid(controlledTargetUid ?? "");
  const [targetUid, setTargetUid] = useState("");
  const [selectedRoles, setSelectedRoles] = useState<AdminRoleClaim[]>([]);
  const [note, setNote] = useState("");
  const [highRiskConfirmed, setHighRiskConfirmed] = useState(false);
  const [saveReceipt, setSaveReceipt] = useState<AdminRoleSaveReceipt | null>(null);
  const [assignmentFilter, setAssignmentFilter] =
    useState<AdminRoleAssignmentStatusFilter>("active");
  const [assignmentQuery, setAssignmentQuery] = useState("");
  const assignmentQueryResult = useQuery({
    queryKey: adminQueryKeys.adminRoles.assignments(assignmentFilter),
    queryFn: () => loadAdminRoleAssignments({status: assignmentFilter, limit: 50}),
  });
  const userQuery = useQuery({
    enabled: normalizedSelectedUid !== null,
    queryKey: adminQueryKeys.adminRoles.user(normalizedSelectedUid ?? "__none__"),
    queryFn: () => loadAdminUserRoles({targetUid: normalizedSelectedUid!}),
  });
  const saveMutation = useMutation({mutationFn: saveAdminUserRoles});
  const assignmentRows = assignmentQueryResult.data?.rows ?? [];
  const assignmentVisibleRows = useMemo(
    () => filterAssignmentRows(assignmentRows, assignmentQuery),
    [assignmentQuery, assignmentRows]
  );
  const selectedUser = normalizedSelectedUid &&
    userQuery.data?.user.targetUid === normalizedSelectedUid ?
    userQuery.data.user : null;

  useEffect(() => {
    setSelectedRoles(selectedUser?.roles ?? []);
    setNote("");
    setHighRiskConfirmed(false);
    setSaveReceipt(null);
  }, [selectedUser?.targetUid]);

  useEffect(() => {
    if (assignmentQueryResult.isError) {
      onError(messageFromError(assignmentQueryResult.error, "Unable to load the admin role assignment register."));
      return;
    }
    if (userQuery.isError) {
      onError(messageFromError(userQuery.error, "Unable to load roles for this exact uid."));
      return;
    }
    onError(null);
  }, [
    assignmentQueryResult.error,
    assignmentQueryResult.isError,
    onError,
    userQuery.error,
    userQuery.isError,
  ]);

  const roleDiff = useMemo(
    () => roleDifference(selectedUser?.roles ?? [], selectedRoles),
    [selectedRoles, selectedUser?.roles]
  );
  const hasHighRiskChange = [...roleDiff.added, ...roleDiff.removed]
    .some((role) => adminRolePolicies[role].confirmationRequired);
  const validationIssue = useMemo(() => validateRoleChange({
    currentUserUid,
    hasHighRiskChange,
    highRiskConfirmed,
    note,
    selectedRoles,
    selectedUser,
  }), [
    currentUserUid,
    hasHighRiskChange,
    highRiskConfirmed,
    note,
    selectedRoles,
    selectedUser,
  ]);
  const scopeContract = useMemo(
    () => buildAdminRoleScopeContract(controlledTargetUid ?? targetUid, currentUserUid),
    [controlledTargetUid, currentUserUid, targetUid]
  );

  const navigateToTarget = useCallback((uid: string) => {
    if (onSelectTargetUid) onSelectTargetUid(uid);
    else setFallbackTargetUid(uid);
  }, [onSelectTargetUid]);

  const load = useCallback(async (nextTargetUid = targetUid) => {
    const contract = buildAdminRoleScopeContract(nextTargetUid, currentUserUid);
    if (!contract.normalizedUid) {
      onError(contract.statusDetail);
      return false;
    }
    setTargetUid(contract.normalizedUid);
    navigateToTarget(contract.normalizedUid);
    onError(null);
    return true;
  }, [currentUserUid, navigateToTarget, onError, targetUid]);

  const refreshAssignments = useCallback(async () => {
    await assignmentQueryResult.refetch();
  }, [assignmentQueryResult]);

  const save = useCallback(async () => {
    if (!selectedUser || validationIssue) {
      onError(validationIssue ?? "Load an admin user before saving role changes.");
      return false;
    }
    try {
      const response: AdminSetAdminUserRolesResponse = await saveMutation.mutateAsync({
        targetUid: selectedUser.targetUid,
        roles: selectedRoles,
        note: note.trim(),
      });
      queryClient.setQueryData(
        adminQueryKeys.adminRoles.user(response.user.targetUid),
        response
      );
      setSelectedRoles(response.afterRoles);
      setSaveReceipt({
        targetUid: response.user.targetUid,
        assignmentPath: response.user.assignmentPath,
        beforeRoles: response.beforeRoles,
        afterRoles: response.afterRoles,
      });
      await queryClient.invalidateQueries({
        queryKey: adminQueryKeys.adminRoles.assignments(assignmentFilter),
      });
      setNote("");
      setHighRiskConfirmed(false);
      onError(null);
      onNotice(`Role assignment saved for ${response.user.targetUid}.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save admin role changes."));
      return false;
    }
  }, [
    assignmentFilter,
    note,
    onError,
    onNotice,
    queryClient,
    saveMutation,
    selectedRoles,
    selectedUser,
    validationIssue,
  ]);

  const toggleRole = useCallback((role: AdminRoleClaim, checked: boolean) => {
    if (
      role === "adminOwner" && !checked && currentUserUid &&
      selectedUser?.targetUid === currentUserUid
    ) {
      onError("You cannot remove your own adminOwner claim.");
      return;
    }
    setSelectedRoles((current) => checked ?
      current.includes(role) ? current : [...current, role] :
      current.filter((item) => item !== role));
    setHighRiskConfirmed(false);
    onError(null);
  }, [currentUserUid, onError, selectedUser?.targetUid]);

  const selectAssignment = useCallback((row: AdminRoleAssignmentRow) => {
    setTargetUid(row.targetUid);
    navigateToTarget(row.targetUid);
  }, [navigateToTarget]);

  return {
    assignmentFilter,
    assignmentGeneratedAt: assignmentQueryResult.data?.generatedAt ?? null,
    assignmentRows,
    assignmentVisibleRows,
    assignmentQuery,
    assignmentCapped: assignmentRows.length >= 50,
    highRiskConfirmed,
    hasHighRiskChange,
    isAssignmentListLoading: assignmentQueryResult.isPending || assignmentQueryResult.isFetching,
    isLoading: userQuery.isPending && normalizedSelectedUid !== null,
    isSaving: saveMutation.isPending,
    note,
    roleDiff,
    rolePolicies: adminRolePolicyList,
    saveReceipt,
    selectedRoles,
    selectedTargetUid: controlledTargetUid ?? null,
    selectedUnavailable: Boolean(
      controlledTargetUid &&
      !selectedUser &&
      (normalizedSelectedUid === null || !userQuery.isPending)
    ),
    selectedUser,
    scopeContract,
    targetUid,
    validationIssue,
    load,
    refreshAssignments,
    save,
    selectAssignment,
    setAssignmentFilter,
    setAssignmentQuery,
    setHighRiskConfirmed,
    setNote,
    setTargetUid,
    toggleRole,
  };
}

export function buildAdminRoleScopeContract(
  input: string,
  currentUserUid: string | null
): AdminRoleScopeContract {
  const normalizedUid = normalizeUid(input);
  const isSelfTarget = Boolean(normalizedUid && currentUserUid && normalizedUid === currentUserUid);
  const base = {
    isSelfTarget,
    sourceOfTruth: ["Firebase Auth custom claims", "adminRoleAssignments/{uid}", "adminAuditLogs/{id}"],
    blockedInputs: ["Email search", "Display-name search", "Phone lookup", "Unbounded Auth directory"],
    blockedActions: ["Remove your own adminOwner claim", "Edit non-admin custom claims", "Change account disabled state"],
  };
  if (!normalizedUid) {
    return {
      ...base,
      canLoad: false,
      normalizedUid: null,
      assignmentPath: null,
      statusLabel: "Exact Firebase Auth uid required",
      statusDetail: "Role lookup accepts one exact Firebase Auth uid; it does not search email, display name, phone, or Auth directories.",
    };
  }
  return {
    ...base,
    canLoad: true,
    normalizedUid,
    assignmentPath: `adminRoleAssignments/${normalizedUid}`,
    statusLabel: isSelfTarget ? "Self-owner protection active" : "Exact uid target",
    statusDetail: isSelfTarget ?
      "The signed-in owner cannot remove their own adminOwner claim." :
      "The read and write are scoped to this uid and the governed Catch claim allowlist.",
  };
}

function validateRoleChange({
  currentUserUid,
  hasHighRiskChange,
  highRiskConfirmed,
  note,
  selectedRoles,
  selectedUser,
}: {
  currentUserUid: string | null;
  hasHighRiskChange: boolean;
  highRiskConfirmed: boolean;
  note: string;
  selectedRoles: AdminRoleClaim[];
  selectedUser: AdminUserRoleRecord | null;
}): string | null {
  if (!selectedUser) return "Load an admin user before saving role changes.";
  if (currentUserUid && selectedUser.targetUid === currentUserUid && !selectedRoles.includes("adminOwner")) {
    return "You cannot remove your own adminOwner claim.";
  }
  if (sameRoles(selectedUser.roles, selectedRoles)) return "Change at least one admin role before saving.";
  if (!note.trim()) return "Add a review note before saving role changes.";
  if (note.trim().length > 1000) return "Review note must be 1000 characters or fewer.";
  if (hasHighRiskChange && !highRiskConfirmed) return "Confirm the high-risk role change before saving.";
  return null;
}

function filterAssignmentRows(rows: AdminRoleAssignmentRow[], query: string) {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    const haystack = [row.targetUid, row.email, row.displayName, row.status,
      row.roles.join(" ")].filter(Boolean).join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function roleDifference(before: AdminRoleClaim[], after: AdminRoleClaim[]): AdminRoleDiff {
  const beforeSet = new Set(before);
  const afterSet = new Set(after);
  return {
    added: after.filter((role) => !beforeSet.has(role)),
    removed: before.filter((role) => !afterSet.has(role)),
  };
}

function normalizeUid(value: string): string | null {
  const uid = value.trim();
  return /^[A-Za-z0-9_-]{3,128}$/u.test(uid) ? uid : null;
}

function sameRoles(before: AdminRoleClaim[], after: AdminRoleClaim[]): boolean {
  if (before.length !== after.length) return false;
  const beforeSet = new Set(before);
  return after.every((role) => beforeSet.has(role));
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
