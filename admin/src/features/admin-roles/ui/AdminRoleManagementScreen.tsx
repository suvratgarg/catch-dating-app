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
  AdminEditorGrid,
  AdminEditorPanel,
  AdminEditorSection,
  AdminFieldGrid,
  AdminMetricCard,
  AdminMetricGrid,
  AdminPublishingFormShell,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminTag,
  AdminToolbar,
  AdminWorkbenchStack,
  AlertRow,
  CheckboxField,
  DataTable,
  EmptyState,
  Panel,
  QualityList,
  SelectField,
  StateRow,
  StatusChip,
  TableActionButton,
  TextareaField,
  TextField,
  AdminTagList,
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminRowTitle,
  AdminTagRow,
} from "../../../shared/ui/AdminPrimitives";
import {
  type AdminRoleManagementController,
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
  return <AdminRoleManagementWorkspace controller={controller} />;
}

export function AdminRoleManagementWorkspace({
  controller,
}: {
  controller: AdminRoleManagementController;
}) {
  return (
    <AdminWorkbenchStack>
      <AdminMetricGrid ariaLabel="Admin role management state">
        <AdminMetricCard label="Loaded user" value={controller.selectedUser ? 1 : 0} />
        <AdminMetricCard label="Selected roles" value={controller.selectedRoles.length} />
        <AdminMetricCard label="Recent changes" value={controller.recentChanges.length} />
        <AdminMetricCard
          label="Save blocked"
          tone={controller.selectedUser && controller.validationIssue ?
            "attention" :
            "normal"}
          value={controller.selectedUser && controller.validationIssue ? 1 : 0}
        />
      </AdminMetricGrid>
      <Panel
        span={2}
        icon={<UserCheck size={18} strokeWidth={1.9} />}
        title="Admin role lookup"
        action="adminOwner"
      >
        <AdminToolbar>
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
        </AdminToolbar>
        <RoleScopeContractPanel contract={controller.scopeContract} />
      </Panel>
      <AdminEditorGrid>
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
        <AdminWorkbenchStack>
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
            <QualityList>
              <StateRow label="Read callable" value="adminGetAdminUserRoles" />
              <StateRow label="Write callable" value="adminSetAdminUserRoles" />
              <StateRow label="Required role" value="adminOwner" />
              <StateRow label="Assignment register" value="adminRoleAssignments/{uid}" />
              <StateRow label="Protection" value="Cannot remove your own adminOwner claim" />
              <StateRow label="Directory" value="Bounded assignment register; no email/name search" />
            </QualityList>
          </Panel>
        </AdminWorkbenchStack>
      </AdminEditorGrid>
    </AdminWorkbenchStack>
  );
}

function RoleScopeContractPanel({
  contract,
}: {
  contract: AdminRoleScopeContract;
}) {
  return (
    <AdminIntakeSection>
      <AlertRow
        icon={<ShieldCheck size={16} strokeWidth={1.9} />}
        title={contract.statusLabel}
        tone={contract.canLoad ? "neutral" : "warning"}
      >
        {contract.statusDetail}
      </AlertRow>
      <QualityList>
        <StateRow label="Normalized uid" value={contract.normalizedUid} />
        <StateRow label="Assignment path" value={contract.assignmentPath} />
        <StateRow label="Sources" value={contract.sourceOfTruth.join(", ")} />
      </QualityList>
      <AdminIntakeSectionTitle>Not Supported Here</AdminIntakeSectionTitle>
      <AdminTagList>
        {contract.blockedInputs.map((input) => (
          <AdminTag key={input}>{input}</AdminTag>
        ))}
        {contract.blockedActions.map((action) => (
          <AdminTag key={action} tone="muted">{action}</AdminTag>
        ))}
      </AdminTagList>
    </AdminIntakeSection>
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
    <AdminEditorPanel
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Role assignment"
      action={selectedUser ? selectedUser.targetUid : "No user"}
    >
      {selectedUser ? (
        <AdminPublishingFormShell>
          <AdminEditorSection>
            <legend>Admin roles</legend>
            <AdminFieldGrid columns={2}>
              {roleOptions.map((role) => (
                <CheckboxField
                  checked={selectedRoles.includes(role)}
                  key={role}
                  label={role}
                  onChange={(checked) => onRoleToggle(role, checked)}
                />
              ))}
            </AdminFieldGrid>
          </AdminEditorSection>
          <AdminEditorSection>
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
          </AdminEditorSection>
          <AdminButton
            disabled={Boolean(validationIssue) || isSaving}
            icon={<CheckCircle2 size={15} strokeWidth={1.9} />}
            onClick={onSave}
            variant="primary"
          >
            {isSaving ? "Saving roles" : "Save role changes"}
          </AdminButton>
        </AdminPublishingFormShell>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Load a Firebase Auth uid to inspect and edit admin roles.
        </EmptyState>
      )}
    </AdminEditorPanel>
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
      <AdminToolbar compact>
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
      </AdminToolbar>
      <StateRow
        label="Source"
        value={`adminRoleAssignments${generatedAt ? ` / ${formatDateTime(generatedAt)}` : ""}`}
      />
      {rows.length === 0 ? (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          No admin role assignments match this filter.
        </EmptyState>
      ) : (
        <DataTable compact variant="workbench">
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
                  <AdminRowTitle compact>
                    <strong>{row.email ?? row.targetUid}</strong>
                    <span>
                      {row.displayName ?? row.targetUid} · {
                        formatDateTime(row.updatedAt)
                      }
                    </span>
                  </AdminRowTitle>
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
        <QualityList>
          <StateRow label="UID" value={selectedUser.targetUid} />
          <StateRow label="Email" value={selectedUser.email ?? "none"} />
          <StateRow label="Display name" value={selectedUser.displayName ?? "none"} />
          <StateRow label="Auth disabled" value={selectedUser.disabled ? "yes" : "no"} />
          <StateRow label="Assignment doc" value={selectedUser.assignmentPath} />
          <StateRow
            label="Current roles"
            value={
              selectedUser.roles.length > 0 ? (
                <AdminTagRow as="span">
                  {selectedUser.roles.map((role) => (
                    <StatusChip key={role}>{role}</StatusChip>
                  ))}
                </AdminTagRow>
              ) : "none"
            }
          />
        </QualityList>
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
        <AdminRoadmapList>
          {changes.map((change) => (
            <AdminRoadmapListItem
              key={`${change.targetUid}:${change.afterRoles.join(",")}`}
            >
              <CheckCircle2 size={15} strokeWidth={1.9} />
              <span>
                <strong>{change.targetUid}</strong> ·{" "}
                {roleList(change.beforeRoles)} to {roleList(change.afterRoles)}
              </span>
            </AdminRoadmapListItem>
          ))}
        </AdminRoadmapList>
      )}
    </Panel>
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
