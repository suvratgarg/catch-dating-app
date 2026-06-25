import {useCallback, useEffect, useMemo, useState} from "react";
import {
  AdminRoleAssignmentRow,
  AdminListAdminRoleAssignmentsPayload,
  adminRoleClaimKeys,
  type AdminRoleClaim,
  type AdminSetAdminUserRolesResponse,
  type AdminUserRoleRecord,
} from "../../../shared/types/adminTypes";
import {
  loadAdminRoleAssignments,
  loadAdminUserRoles,
  saveAdminUserRoles,
} from "../api/adminRoleRepository";

export interface AdminRoleChangeRecord {
  targetUid: string;
  beforeRoles: AdminRoleClaim[];
  afterRoles: AdminRoleClaim[];
}

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

export function useAdminRoleManagementController({
  currentUserUid,
  onError,
  onNotice,
}: {
  currentUserUid: string | null;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [targetUid, setTargetUid] = useState(currentUserUid ?? "admin-owner");
  const [selectedUser, setSelectedUser] =
    useState<AdminUserRoleRecord | null>(null);
  const [selectedRoles, setSelectedRoles] = useState<AdminRoleClaim[]>([]);
  const [note, setNote] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [recentChanges, setRecentChanges] = useState<AdminRoleChangeRecord[]>(
    []
  );
  const [assignmentRows, setAssignmentRows] = useState<AdminRoleAssignmentRow[]>(
    []
  );
  const [assignmentFilter, setAssignmentFilter] =
    useState<AdminRoleAssignmentStatusFilter>("active");
  const [assignmentGeneratedAt, setAssignmentGeneratedAt] =
    useState<string | null>(null);
  const [isAssignmentListLoading, setIsAssignmentListLoading] =
    useState(false);

  const validationIssue = useMemo(
    () => validateRoleChange({
      currentUserUid,
      note,
      selectedRoles,
      selectedUser,
    }),
    [currentUserUid, note, selectedRoles, selectedUser]
  );
  const scopeContract = useMemo(
    () => buildAdminRoleScopeContract(targetUid, currentUserUid),
    [currentUserUid, targetUid]
  );

  const load = useCallback(async (nextTargetUid = targetUid) => {
    const contract = buildAdminRoleScopeContract(nextTargetUid, currentUserUid);
    if (!contract.normalizedUid) {
      onError(contract.statusDetail);
      return false;
    }
    setIsLoading(true);
    try {
      const response = await loadAdminUserRoles({
        targetUid: contract.normalizedUid,
      });
      setSelectedUser(response.user);
      setSelectedRoles(response.user.roles);
      setTargetUid(response.user.targetUid);
      setNote("");
      onError(null);
      onNotice(`Loaded admin roles for ${response.user.targetUid}.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to load admin user roles."));
      return false;
    } finally {
      setIsLoading(false);
    }
  }, [currentUserUid, onError, onNotice, targetUid]);

  const refreshAssignments = useCallback(async () => {
    setIsAssignmentListLoading(true);
    try {
      const response = await loadAdminRoleAssignments({
        status: assignmentFilter,
        limit: 50,
      });
      setAssignmentRows(response.rows);
      setAssignmentGeneratedAt(response.generatedAt);
      onError(null);
    } catch (error) {
      onError(messageFromError(
        error,
        "Unable to load admin role assignment register."
      ));
    } finally {
      setIsAssignmentListLoading(false);
    }
  }, [assignmentFilter, onError]);

  useEffect(() => {
    void refreshAssignments();
  }, [refreshAssignments]);

  const save = useCallback(async () => {
    if (!selectedUser) {
      onError("Load an admin user before saving role changes.");
      return false;
    }
    const issue = validationIssue;
    if (issue) {
      onError(issue);
      return false;
    }
    setIsSaving(true);
    try {
      const response: AdminSetAdminUserRolesResponse =
        await saveAdminUserRoles({
          targetUid: selectedUser.targetUid,
          roles: selectedRoles,
          note: note.trim(),
        });
      setSelectedUser(response.user);
      setSelectedRoles(response.afterRoles);
      setRecentChanges((current) => [{
        targetUid: response.user.targetUid,
        beforeRoles: response.beforeRoles,
        afterRoles: response.afterRoles,
      }, ...current].slice(0, 6));
      await refreshAssignments();
      setNote("");
      onError(null);
      onNotice(`Saved admin roles for ${response.user.targetUid}.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save admin role changes."));
      return false;
    } finally {
      setIsSaving(false);
    }
  }, [
    note,
    onError,
    onNotice,
    refreshAssignments,
    selectedRoles,
    selectedUser,
    validationIssue,
  ]);

  const toggleRole = useCallback((role: AdminRoleClaim, checked: boolean) => {
    setSelectedRoles((current) => {
      if (checked) {
        return current.includes(role) ? current : [...current, role];
      }
      return current.filter((item) => item !== role);
    });
  }, []);

  const selectAssignment = useCallback((row: AdminRoleAssignmentRow) => {
    setTargetUid(row.targetUid);
    void load(row.targetUid);
  }, [load]);

  return {
    assignmentFilter,
    assignmentGeneratedAt,
    assignmentRows,
    isLoading,
    isAssignmentListLoading,
    isSaving,
    note,
    recentChanges,
    refreshAssignments,
    roleOptions: adminRoleClaimKeys,
    selectedRoles,
    selectedUser,
    scopeContract,
    targetUid,
    validationIssue,
    load,
    save,
    selectAssignment,
    setNote,
    setAssignmentFilter,
    setTargetUid,
    toggleRole,
  };
}

export function buildAdminRoleScopeContract(
  input: string,
  currentUserUid: string | null
): AdminRoleScopeContract {
  const normalizedUid = normalizeUid(input);
  const isSelfTarget = Boolean(
    normalizedUid && currentUserUid && normalizedUid === currentUserUid
  );
  const base = {
    isSelfTarget,
    sourceOfTruth: [
      "Firebase Auth custom claims",
      "adminRoleAssignments/{uid}",
      "adminAuditLogs/{id}",
    ],
    blockedInputs: [
      "Email search",
      "Display-name search",
      "Phone lookup",
      "Unbounded all-admin directory",
      "Backfill manually assigned legacy claims",
    ],
    blockedActions: [
      "Remove your own adminOwner claim",
      "Edit non-admin custom claims",
      "Change account disabled state",
      "Run support or safety user actions",
    ],
  };
  if (!normalizedUid) {
    return {
      ...base,
      canLoad: false,
      normalizedUid: null,
      assignmentPath: null,
      statusLabel: "Exact Firebase Auth uid required",
      statusDetail:
        "Admin role management only accepts one exact Firebase Auth uid. It does not search email, display name, phone, or admin directories.",
    };
  }
  return {
    ...base,
    canLoad: true,
    normalizedUid,
    assignmentPath: `adminRoleAssignments/${normalizedUid}`,
    statusLabel: isSelfTarget ? "Self-target guarded" : "Exact admin role target",
    statusDetail: isSelfTarget ?
      "This target is the signed-in admin owner. The backend and UI prevent removing your own adminOwner claim." :
      "Role reads and writes are scoped to this one Firebase Auth uid and the Catch admin claim allowlist.",
  };
}

function validateRoleChange({
  currentUserUid,
  note,
  selectedRoles,
  selectedUser,
}: {
  currentUserUid: string | null;
  note: string;
  selectedRoles: AdminRoleClaim[];
  selectedUser: AdminUserRoleRecord | null;
}): string | null {
  if (!selectedUser) return "Load an admin user before saving role changes.";
  if (
    currentUserUid &&
    selectedUser.targetUid === currentUserUid &&
    !selectedRoles.includes("adminOwner")
  ) {
    return "You cannot remove your own adminOwner claim.";
  }
  if (sameRoles(selectedUser.roles, selectedRoles)) {
    return "Change at least one admin role before saving.";
  }
  if (!note.trim()) return "Add a review note before saving role changes.";
  if (note.trim().length > 1000) {
    return "Review note must be 1000 characters or fewer.";
  }
  return null;
}

function normalizeUid(value: string): string | null {
  const uid = value.trim();
  if (!/^[A-Za-z0-9_-]{3,128}$/u.test(uid)) return null;
  return uid;
}

function sameRoles(
  beforeRoles: AdminRoleClaim[],
  afterRoles: AdminRoleClaim[]
): boolean {
  if (beforeRoles.length !== afterRoles.length) return false;
  const before = new Set(beforeRoles);
  return afterRoles.every((role) => before.has(role));
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
