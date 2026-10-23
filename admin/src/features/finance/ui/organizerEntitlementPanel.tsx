import {CatchField} from "@catch/web-ui";
import {
  BadgeCheck,
  CircleDollarSign,
  ReceiptText,
  ShieldCheck,
  TicketCheck,
} from "lucide-react";
import {
  AdminButton,
  AdminRowTitle,
  AdminTableRow,
  AdminToolbar,
  AdminWorkbenchStack,
  AlertRow,
  DataTable,
  EmptyState,
  Panel,
  QualityList,
  selectOptionLabeller,
  selectOptionValues,
  StateRow,
  TableActionButton,
} from "../../../shared/ui/AdminPrimitives";
import type {
  OrganizerEntitlementController,
  OrganizerEntitlementSku,
  OrganizerEntitlementSource,
  OrganizerEntitlementUnit,
} from "../controllers/useOrganizerEntitlementController";

type EntitlementGrantRow =
  NonNullable<OrganizerEntitlementController["entitlement"]>["grants"][number];

type EntitlementSkuCatalog =
  NonNullable<OrganizerEntitlementController["entitlement"]>["skuCatalog"];

const skuValues: OrganizerEntitlementSku[] = [
  "wedding_essentials",
  "wedding_pro",
  "wedding_signature",
  "wedding_transport_addon",
  "planner_annual",
];

const unitOptions: Array<{label: string; value: OrganizerEntitlementUnit}> = [
  {label: "Per program", value: "program"},
  {label: "Per organizer year", value: "organizerYear"},
];

const sourceOptions: Array<{label: string; value: OrganizerEntitlementSource}> = [
  {label: "Manual invoice", value: "manualInvoice"},
  {label: "Checkout", value: "checkout"},
  {label: "Promo", value: "promo"},
];

export function renderOrganizerEntitlementPanel(
  controller: OrganizerEntitlementController
) {
  const entitlement = controller.entitlement;
  const catalog = entitlement?.skuCatalog ?? null;
  const selectedSku = catalog?.[controller.grantForm.sku] ?? null;
  const revokeTarget = entitlement?.grants.find((grant) =>
    grant.grantId === controller.revokeTargetGrantId) ?? null;
  return (
    <Panel
      span={2}
      icon={<ReceiptText size={18} strokeWidth={1.9} />}
      title="Organizer entitlements"
      action="Manual invoice ledger"
    >
      <AdminWorkbenchStack compact>
        <AlertRow
          icon={<ShieldCheck size={16} strokeWidth={1.9} />}
          title="Ledger writes only"
          tone="neutral"
        >
          Grant and revoke record the reconciled invoice decision against the
          organizer entitlement ledger. They cannot bill, refund, collect a
          payment, contact a provider, or grant dispatch authority.
        </AlertRow>
        <AdminToolbar>
          <CatchField
            recipe="input"
            title="Organizer ID"
            onChanged={controller.setOrganizerId}
            value={controller.organizerId}
          />
          <AdminButton
            disabled={controller.isLoading}
            loading={controller.isLoading}
            loadingLabel="Loading"
            onClick={() => void controller.load()}
            variant="primary"
          >
            Load entitlements
          </AdminButton>
        </AdminToolbar>

        {entitlement ? (
          <>
            <QualityList>
              <StateRow
                label="Ledger"
                value={`revision ${entitlement.revision} · catalog v${entitlement.catalogVersion}`}
              />
              <StateRow
                label="Flight days used"
                value={formatCount(entitlement.meters.flightDaysUsed)}
              />
              <StateRow
                label="WhatsApp conversations used"
                value={formatCount(entitlement.meters.waConversationsUsed)}
              />
            </QualityList>
            <EntitlementGrantTable
              controller={controller}
              grants={entitlement.grants}
            />
          </>
        ) : null}

        <Panel
          icon={<TicketCheck size={17} strokeWidth={1.9} />}
          title="Grant an entitlement"
          action="Idempotent on operation id"
        >
          <AdminWorkbenchStack compact>
            {controller.pendingGrant ? (
              <AlertRow
                icon={<ShieldCheck size={16} strokeWidth={1.9} />}
                title="Grant outcome needs reconciliation"
                tone="warning"
              >
                Retry the frozen {controller.pendingGrant.sku} grant for
                {` ${controller.pendingGrant.organizerId}`} with operation
                {` ${controller.pendingGrant.operationId}`}. Form edits cannot
                replace this request until its result is confirmed. Load the
                ledger to check whether it was recorded.
              </AlertRow>
            ) : null}
            <AdminToolbar>
              <CatchField
                recipe="select"
                title="SKU"
                onChanged={(value) => controller.setGrantField(
                  "sku",
                  (value ?? "") as OrganizerEntitlementSku
                )}
                values={selectOptionValues(skuOptions(catalog))}
                itemLabelBuilder={selectOptionLabeller(skuOptions(catalog))}
                value={controller.grantForm.sku}
              />
              <CatchField
                recipe="select"
                title="Unit"
                onChanged={(value) => controller.setGrantField(
                  "unit",
                  (value ?? "") as OrganizerEntitlementUnit
                )}
                values={selectOptionValues(unitOptions)}
                itemLabelBuilder={selectOptionLabeller(unitOptions)}
                value={controller.grantForm.unit}
              />
              <CatchField
                recipe="input"
                title="Quantity"
                onChanged={(value) => controller.setGrantField("quantity", value)}
                value={controller.grantForm.quantity}
                keyboardType="number"
              />
              <CatchField
                recipe="input"
                title="Valid from (optional)"
                onChanged={(value) => controller.setGrantField("validFrom", value)}
                value={controller.grantForm.validFrom}
                keyboardType="datetime"
              />
              <CatchField
                recipe="input"
                title="Valid until (optional)"
                onChanged={(value) => controller.setGrantField("validUntil", value)}
                value={controller.grantForm.validUntil}
                keyboardType="datetime"
              />
              <CatchField
                recipe="select"
                title="Source"
                onChanged={(value) => controller.setGrantField(
                  "source",
                  (value ?? "") as OrganizerEntitlementSource
                )}
                values={selectOptionValues(sourceOptions)}
                itemLabelBuilder={selectOptionLabeller(sourceOptions)}
                value={controller.grantForm.source}
              />
              <CatchField
                recipe="input"
                title="Invoice receipt reference"
                onChanged={(value) => controller.setGrantField("receiptRef", value)}
                inputHint="INV-2026-0042"
                value={controller.grantForm.receiptRef}
              />
            </AdminToolbar>
            {selectedSku ? (
              <QualityList>
                <StateRow label="SKU" value={selectedSku.label} />
                <StateRow label="List price" value={priceLabel(selectedSku)} />
                <StateRow label="Limits" value={limitLabel(selectedSku)} />
                <StateRow
                  label="Included meters"
                  value={`${formatCount(selectedSku.includedFlightDays)} flight days · ${formatCount(selectedSku.includedWaConversations)} WhatsApp conversations`}
                />
              </QualityList>
            ) : null}
            <CatchField
              recipe="input"
              title="Grant note"
              onChanged={(value) => controller.setGrantField("note", value)}
              maxLines={2}
              value={controller.grantForm.note}
            />
            {controller.grantDisabledReason ? (
              <AlertRow
                icon={<CircleDollarSign size={16} strokeWidth={1.9} />}
                title="Grant not ready"
                tone="warning"
              >
                {controller.grantDisabledReason}
              </AlertRow>
            ) : null}
            <AdminButton
              disabled={Boolean(controller.grantDisabledReason) || controller.isGranting}
              loading={controller.isGranting}
              loadingLabel="Recording"
              onClick={() => void controller.grant()}
              variant="primary"
            >
              {controller.pendingGrant ?
                "Retry pending grant" : "Record entitlement grant"}
            </AdminButton>
          </AdminWorkbenchStack>
        </Panel>

        {revokeTarget || controller.pendingRevoke ? (
          <Panel
            icon={<BadgeCheck size={17} strokeWidth={1.9} />}
            title={revokeTarget ? `Revoke ${revokeTarget.skuLabel}` :
              "Reconcile pending revocation"}
            action={revokeTarget?.grantId ??
              controller.pendingRevoke?.grantId}
          >
            <AdminWorkbenchStack compact>
              {controller.pendingRevoke ? (
                <AlertRow
                  icon={<ShieldCheck size={16} strokeWidth={1.9} />}
                  title="Revocation outcome needs reconciliation"
                  tone="warning"
                >
                  Retry the frozen revocation of
                  {` ${controller.pendingRevoke.grantId}`} for
                  {` ${controller.pendingRevoke.organizerId}`} with operation
                  {` ${controller.pendingRevoke.operationId}`}. Load the ledger
                  to check whether it was recorded.
                </AlertRow>
              ) : null}
              <CatchField
                recipe="input"
                title="Revoke reason"
                onChanged={controller.setRevokeReason}
                maxLines={2}
                value={controller.revokeReason}
              />
              {controller.revokeDisabledReason ? (
                <AlertRow
                  icon={<ShieldCheck size={16} strokeWidth={1.9} />}
                  title="Revoke not ready"
                  tone="warning"
                >
                  {controller.revokeDisabledReason}
                </AlertRow>
              ) : null}
              <AdminToolbar>
                <AdminButton
                  disabled={Boolean(controller.revokeDisabledReason) || controller.isRevoking}
                  loading={controller.isRevoking}
                  loadingLabel="Revoking"
                  onClick={() => void controller.revoke()}
                  variant="primary"
                >
                  {controller.pendingRevoke ?
                    "Retry pending revocation" : "Revoke grant"}
                </AdminButton>
                <AdminButton
                  onClick={() => controller.setRevokeTargetGrantId(null)}
                >
                  Keep grant
                </AdminButton>
              </AdminToolbar>
            </AdminWorkbenchStack>
          </Panel>
        ) : null}
      </AdminWorkbenchStack>
    </Panel>
  );
}

function EntitlementGrantTable({
  controller,
  grants,
}: {
  controller: OrganizerEntitlementController;
  grants: EntitlementGrantRow[];
}) {
  if (grants.length === 0) {
    return (
      <EmptyState variant="workbench" icon={<ReceiptText size={16} strokeWidth={1.9} />}>
        No entitlement grants are recorded for this organizer.
      </EmptyState>
    );
  }
  return (
    <DataTable ariaLabel="Organizer entitlement grants" variant="workbench">
      <thead>
        <tr>
          <th>Grant</th>
          <th>Unit</th>
          <th>Remaining</th>
          <th>Window</th>
          <th>Source</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        {grants.map((grant) => (
          <AdminTableRow key={grant.grantId}>
            <td>
              <AdminRowTitle>
                <strong>{grant.skuLabel}</strong>
                <span>{grant.grantId}</span>
              </AdminRowTitle>
            </td>
            <td>{unitLabel(grant.unit)}</td>
            <td>{`${formatCount(grant.quantityRemaining)} of ${formatCount(grant.quantityTotal)}`}</td>
            <td>{windowLabel(grant)}</td>
            <td>{sourceLabel(grant.source)}</td>
            <td>{statusLabel(grant)}</td>
            <td>
              {grant.revoked ? null : (
                <TableActionButton onClick={() =>
                  controller.setRevokeTargetGrantId(grant.grantId)}>
                  Revoke
                </TableActionButton>
              )}
            </td>
          </AdminTableRow>
        ))}
      </tbody>
    </DataTable>
  );
}

function skuOptions(catalog: EntitlementSkuCatalog | null) {
  return skuValues.map((sku) => ({
    label: catalog?.[sku]?.label ?? sku,
    value: sku,
  }));
}

function statusLabel(grant: EntitlementGrantRow): string {
  if (grant.revoked) return "revoked";
  if (grant.active) return "active";
  if (grant.quantityRemaining <= 0) return "exhausted";
  if (grant.validFromMillis > Date.now()) return "scheduled";
  return "inactive";
}

function windowLabel(grant: EntitlementGrantRow): string {
  const from = formatMillis(grant.validFromMillis);
  const until = grant.validUntilMillis === null ?
    "open" : formatMillis(grant.validUntilMillis);
  return `${from} → ${until}`;
}

function unitLabel(unit: OrganizerEntitlementUnit): string {
  return unit === "organizerYear" ? "organizer year" : "program";
}

function sourceLabel(source: OrganizerEntitlementSource): string {
  return source === "manualInvoice" ? "manual invoice" :
    source === "checkout" ? "checkout" : "promo";
}

function priceLabel(sku: EntitlementSkuCatalog[string]): string {
  if (sku.priceMinor === null) return "Quote only";
  return `${sku.currency} ${new Intl.NumberFormat("en-IN").format(
    Math.round(sku.priceMinor / 100)
  )}`;
}

function limitLabel(sku: EntitlementSkuCatalog[string]): string {
  const parts: Array<[string, number | null]> = [
    ["guests", sku.limits.guests],
    ["functions", sku.limits.functions],
    ["staff", sku.limits.staffAssignments],
    ["moments/function", sku.limits.momentsPerFunction],
  ];
  return parts.map(([label, value]) =>
    `${label} ${value === null ? "unlimited" : formatCount(value)}`
  ).join(" · ");
}

function formatMillis(value: number): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "malformed";
  return new Intl.DateTimeFormat("en-IN", {dateStyle: "medium"}).format(date);
}

function formatCount(value: number): string {
  return new Intl.NumberFormat("en-IN").format(value);
}
