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
  SelectField,
  StateRow,
  TableActionButton,
  TextareaField,
  TextField,
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
          <TextField
            label="Organizer ID"
            onChange={controller.setOrganizerId}
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
            <AdminToolbar>
              <SelectField
                label="SKU"
                onChange={(value) => controller.setGrantField(
                  "sku",
                  value as OrganizerEntitlementSku
                )}
                options={skuOptions(catalog)}
                value={controller.grantForm.sku}
              />
              <SelectField
                label="Unit"
                onChange={(value) => controller.setGrantField(
                  "unit",
                  value as OrganizerEntitlementUnit
                )}
                options={unitOptions}
                value={controller.grantForm.unit}
              />
              <TextField
                inputMode="numeric"
                label="Quantity"
                onChange={(value) => controller.setGrantField("quantity", value)}
                value={controller.grantForm.quantity}
              />
              <TextField
                label="Valid from (optional)"
                onChange={(value) => controller.setGrantField("validFrom", value)}
                type="datetime-local"
                value={controller.grantForm.validFrom}
              />
              <TextField
                label="Valid until (optional)"
                onChange={(value) => controller.setGrantField("validUntil", value)}
                type="datetime-local"
                value={controller.grantForm.validUntil}
              />
              <SelectField
                label="Source"
                onChange={(value) => controller.setGrantField(
                  "source",
                  value as OrganizerEntitlementSource
                )}
                options={sourceOptions}
                value={controller.grantForm.source}
              />
              <TextField
                label="Invoice receipt reference"
                onChange={(value) => controller.setGrantField("receiptRef", value)}
                placeholder="INV-2026-0042"
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
            <TextareaField
              label="Grant note"
              onChange={(value) => controller.setGrantField("note", value)}
              rows={2}
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
              Record entitlement grant
            </AdminButton>
          </AdminWorkbenchStack>
        </Panel>

        {revokeTarget ? (
          <Panel
            icon={<BadgeCheck size={17} strokeWidth={1.9} />}
            title={`Revoke ${revokeTarget.skuLabel}`}
            action={revokeTarget.grantId}
          >
            <AdminWorkbenchStack compact>
              <TextareaField
                label="Revoke reason"
                onChange={controller.setRevokeReason}
                rows={2}
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
                  Revoke grant
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
