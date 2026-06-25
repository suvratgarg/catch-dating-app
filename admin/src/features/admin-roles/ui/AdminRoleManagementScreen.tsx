import {
  CheckCircle2,
  Clock3,
  Lock,
  RefreshCw,
  ShieldCheck,
  UserCheck,
} from "lucide-react";
import type {
  AdminRoleAssignmentRow,
  AdminRoleClaim,
  AdminUserRoleRecord,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminTag,
  AlertRow,
  CheckboxField,
  DataTable,
  EmptyState,
  Panel,
  SelectField,
  StateRow,
  StatusChip,
  TableActionButton,
  TextareaField,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import {
  type AdminRoleAssignmentStatusFilter,
  type AdminRoleChangeRecord,
  type AdminRoleScopeContract,
  useAdminRoleManagementController,
} from "../controllers/useAdminRoleManagementController";

const assignmentStatusOptions: Array<{
  label: string;
  value: AdminRoleAssignmentStatusFilter;
}> = [
  {label: "Active", value: "active"},
  {label: "Revoked", value: "revoked"},
  {label: "All", value: "all"},
];

export function AdminRoleManagementScreen({
  currentUserUid,
  onError,
  onNotice,
}: {
  currentUserUid: string | null;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useAdminRoleManagementController({
    currentUserUid,
    onError,
    onNotice,
  });
  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Admin role management state">
        <Metric label="Loaded user" value={controller.selectedUser ? 1 : 0} />
        <Metric label="Selected roles" value={controller.selectedRoles.length} />
        <Metric label="Recent changes" value={controller.recentChanges.length} />
        <Metric
          label="Save blocked"
          tone={controller.selectedUser && controller.validationIssue ?
            "attention" :
            "normal"}
          value={controller.selectedUser && controller.validationIssue ? 1 : 0}
        />
      </section>

      <Panel
        className="span-2"
        icon={<UserCheck size={18} strokeWidth={1.9} />}
        title="Admin role lookup"
        action="adminOwner"
      >
        <div className="workbench-toolbar">
          <TextField
            label="Firebase Auth uid"
            onChange={controller.setTargetUid}
            placeholder="admin-owner"
            value={controller.targetUid}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.load()}
            variant="primary"
          >
            {controller.isLoading ? "Loading" : "Load roles"}
          </AdminButton>
        </div>
        <RoleScopeContractPanel contract={controller.scopeContract} />
      </Panel>

      <section className="publishing-editor-grid">
        <RoleEditorPanel
          isSaving={controller.isSaving}
          note={controller.note}
          roleOptions={controller.roleOptions}
          selectedRoles={controller.selectedRoles}
          selectedUser={controller.selectedUser}
          validationIssue={controller.validationIssue}
          onNoteChange={controller.setNote}
          onRoleToggle={controller.toggleRole}
          onSave={() => void controller.save()}
        />
        <div className="workbench-stack">
          <RoleDetailPanel selectedUser={controller.selectedUser} />
          <AssignmentRegisterPanel
            filter={controller.assignmentFilter}
            generatedAt={controller.assignmentGeneratedAt}
            isLoading={controller.isAssignmentListLoading}
            rows={controller.assignmentRows}
            onFilterChange={controller.setAssignmentFilter}
            onRefresh={controller.refreshAssignments}
            onSelect={controller.selectAssignment}
          />
          <RecentChangesPanel changes={controller.recentChanges} />
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Authority boundary"
            action="audited"
          >
            <div className="quality-list">
              <StateRow label="Read callable" value="adminGetAdminUserRoles" />
              <StateRow label="Write callable" value="adminSetAdminUserRoles" />
              <StateRow label="Required role" value="adminOwner" />
              <StateRow label="Assignment register" value="adminRoleAssignments/{uid}" />
              <StateRow label="Protection" value="Cannot remove your own adminOwner claim" />
              <StateRow label="Directory" value="Bounded assignment register; no email/name search" />
            </div>
          </Panel>
        </div>
      </section>
    </div>
  );
}

function RoleScopeContractPanel({
  contract,
}: {
  contract: AdminRoleScopeContract;
}) {
  return (
    <div className="intake-section">
      <AlertRow
        icon={<ShieldCheck size={16} strokeWidth={1.9} />}
        title={contract.statusLabel}
        tone={contract.canLoad ? "neutral" : "warning"}
      >
        {contract.statusDetail}
      </AlertRow>
      <div className="quality-list">
        <StateRow label="Normalized uid" value={contract.normalizedUid} />
        <StateRow label="Assignment path" value={contract.assignmentPath} />
        <StateRow label="Sources" value={contract.sourceOfTruth.join(", ")} />
      </div>
      <div className="intake-section-title">Not Supported Here</div>
      <div className="intake-tags">
        {contract.blockedInputs.map((input) => (
          <AdminTag key={input}>{input}</AdminTag>
        ))}
        {contract.blockedActions.map((action) => (
          <AdminTag key={action} tone="muted">{action}</AdminTag>
        ))}
      </div>
    </div>
  );
}

function RoleEditorPanel({
  isSaving,
  note,
  onNoteChange,
  onRoleToggle,
  onSave,
  roleOptions,
  selectedRoles,
  selectedUser,
  validationIssue,
}: {
  isSaving: boolean;
  note: string;
  onNoteChange: (value: string) => void;
  onRoleToggle: (role: AdminRoleClaim, checked: boolean) => void;
  onSave: () => void;
  roleOptions: readonly AdminRoleClaim[];
  selectedRoles: AdminRoleClaim[];
  selectedUser: AdminUserRoleRecord | null;
  validationIssue: string | null;
}) {
  return (
    <Panel
      className="publishing-editor-panel"
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Role assignment"
      action={selectedUser ? selectedUser.targetUid : "No user"}
    >
      {selectedUser ? (
        <div className="publishing-form">
          <fieldset className="editor-section">
            <legend>Admin roles</legend>
            <div className="form-grid two">
              {roleOptions.map((role) => (
                <CheckboxField
                  checked={selectedRoles.includes(role)}
                  key={role}
                  label={role}
                  onChange={(checked) => onRoleToggle(role, checked)}
                />
              ))}
            </div>
          </fieldset>
          <fieldset className="editor-section">
            <legend>Audit note</legend>
            <TextareaField
              label="Review note"
              onChange={onNoteChange}
              placeholder="Record who requested the role change and why."
              rows={5}
              value={note}
            />
            <StateRow label="Note length" value={`${note.trim().length}/1000`} />
            <StateRow label="Save check" value={validationIssue ?? "Ready"} />
          </fieldset>
          <AdminButton
            disabled={Boolean(validationIssue) || isSaving}
            icon={<CheckCircle2 size={15} strokeWidth={1.9} />}
            onClick={onSave}
            variant="primary"
          >
            {isSaving ? "Saving roles" : "Save role changes"}
          </AdminButton>
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Load a Firebase Auth uid to inspect and edit admin roles.
        </EmptyState>
      )}
    </Panel>
  );
}

function AssignmentRegisterPanel({
  filter,
  generatedAt,
  isLoading,
  onFilterChange,
  onRefresh,
  onSelect,
  rows,
}: {
  filter: AdminRoleAssignmentStatusFilter;
  generatedAt: string | null;
  isLoading: boolean;
  onFilterChange: (value: AdminRoleAssignmentStatusFilter) => void;
  onRefresh: () => void;
  onSelect: (row: AdminRoleAssignmentRow) => void;
  rows: AdminRoleAssignmentRow[];
}) {
  return (
    <Panel
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Access register"
      action={isLoading ? "Loading" : `${rows.length} ${filter}`}
    >
      <div className="workbench-toolbar compact">
        <SelectField
          label="Status"
          onChange={(value) =>
            onFilterChange(value as AdminRoleAssignmentStatusFilter)}
          options={assignmentStatusOptions}
          value={filter}
        />
        <AdminButton
          disabled={isLoading}
          icon={<RefreshCw size={15} strokeWidth={1.9} />}
          onClick={onRefresh}
        >
          Refresh
        </AdminButton>
      </div>
      <StateRow
        label="Source"
        value={`adminRoleAssignments${generatedAt ? ` / ${formatDateTime(generatedAt)}` : ""}`}
      />
      {rows.length === 0 ? (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          No admin role assignments match this filter.
        </EmptyState>
      ) : (
        <DataTable className="workbench-table compact">
          <thead>
            <tr>
              <th>User</th>
              <th>Roles</th>
              <th>Status</th>
              <th>Select</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.targetUid}>
                <td>
                  <div className="row-title compact">
                    <strong>{row.email ?? row.targetUid}</strong>
                    <span>
                      {row.displayName ?? row.targetUid} · {
                        formatDateTime(row.updatedAt)
                      }
                    </span>
                  </div>
                </td>
                <td>{roleList(row.roles)}</td>
                <td>
                  <AdminTag tone={row.status === "active" ? "neutral" : "muted"}>
                    {row.status}
                  </AdminTag>
                </td>
                <td>
                  <TableActionButton onClick={() => onSelect(row)}>
                    Load
                  </TableActionButton>
                </td>
              </tr>
            ))}
          </tbody>
        </DataTable>
      )}
    </Panel>
  );
}

function RoleDetailPanel({
  selectedUser,
}: {
  selectedUser: AdminUserRoleRecord | null;
}) {
  return (
    <Panel
      icon={<UserCheck size={18} strokeWidth={1.9} />}
      title="User detail"
      action={selectedUser?.disabled ? "disabled" : "active"}
    >
      {selectedUser ? (
        <div className="quality-list">
          <StateRow label="UID" value={selectedUser.targetUid} />
          <StateRow label="Email" value={selectedUser.email ?? "none"} />
          <StateRow label="Display name" value={selectedUser.displayName ?? "none"} />
          <StateRow label="Auth disabled" value={selectedUser.disabled ? "yes" : "no"} />
          <StateRow label="Assignment doc" value={selectedUser.assignmentPath} />
          <StateRow
            label="Current roles"
            value={
              selectedUser.roles.length > 0 ? (
                <span className="tag-row">
                  {selectedUser.roles.map((role) => (
                    <StatusChip key={role}>{role}</StatusChip>
                  ))}
                </span>
              ) : "none"
            }
          />
        </div>
      ) : (
        <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
          No user loaded.
        </EmptyState>
      )}
    </Panel>
  );
}

function RecentChangesPanel({
  changes,
}: {
  changes: AdminRoleChangeRecord[];
}) {
  return (
    <Panel
      icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
      title="Recent changes"
      action={`${changes.length} local`}
    >
      {changes.length === 0 ? (
        <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
          No role changes in this session.
        </EmptyState>
      ) : (
        <div className="roadmap-list">
          {changes.map((change) => (
            <div
              className="roadmap-list-item"
              key={`${change.targetUid}:${change.afterRoles.join(",")}`}
            >
              <CheckCircle2 size={15} strokeWidth={1.9} />
              <span>
                <strong>{change.targetUid}</strong> ·{" "}
                {roleList(change.beforeRoles)} to {roleList(change.afterRoles)}
              </span>
            </div>
          ))}
        </div>
      )}
    </Panel>
  );
}

function Metric({
  label,
  tone = "normal",
  value,
}: {
  label: string;
  tone?: "normal" | "attention";
  value: number;
}) {
  return (
    <article className={`metric-card ${tone === "attention" ? "attention" : ""}`}>
      <span>{label}</span>
      <div className="metric-value">{value}</div>
    </article>
  );
}

function roleList(roles: AdminRoleClaim[]): string {
  return roles.length > 0 ? roles.join(", ") : "none";
}

function formatDateTime(value: string | null): string {
  if (!value) return "not recorded";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}
