import type {Meta, StoryObj} from "@storybook/react-vite";
import {
  Activity,
  BarChart3,
  CalendarDays,
  CheckCircle2,
  ClipboardList,
  Eye,
  FileWarning,
  Image as ImageIcon,
  Link2,
  LineChart,
  Lock,
  Megaphone,
  RefreshCw,
  Send,
  ShieldCheck,
  Sparkles,
  Upload,
} from "lucide-react";
import {
  AdminButton,
  AdminCard,
  AdminChecklistStack,
  AdminCommandRow,
  AdminCommandStack,
  AdminDiffList,
  AdminDiffRow,
  AdminEditorGrid,
  AdminEditorPanel,
  AdminEditorSection,
  AdminEventSupplyDetail,
  AdminEventSupplyDetailStack,
  AdminEventSupplyEmptyState,
  AdminEventSupplyLinks,
  AdminEventSupplyReviewGrid,
  AdminFeatureDropCaptureThumb,
  AdminFeatureDropControlGrid,
  AdminFeatureDropFeatureEditor,
  AdminFeatureDropFeatureList,
  AdminFeatureDropPreviewCard,
  AdminFeatureDropPreviewGrid,
  AdminFeatureDropWideField,
  AdminFilterBar,
  AdminMutedCell,
  AdminOverviewAnalyticsClearButton,
  AdminOverviewBarChart,
  AdminOverviewLineChart,
  AdminOverviewMainGrid,
  AdminOverviewQueueActionHint,
  AdminOverviewQueueColumns,
  AdminOverviewQueueDecisionButton,
  AdminOverviewQueueDetailPanel,
  AdminOverviewQueueHeading,
  AdminOverviewQueueItems,
  AdminOverviewQueueList,
  AdminOverviewQueueRow,
  AdminOverviewQueueRowActions,
  AdminOverviewValueSignals,
  AdminSignalBars,
  AdminPublishingFormShell,
  AdminPublishingLoadbar,
  AdminQueryList,
  AdminQueryRow,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminStateRow,
  AdminSurfacePreview,
  AdminTag,
  AdminTagList,
  AdminTextField,
  AdminTextareaField,
  AdminWorkspace,
  AlertRow,
  DataTable,
  DecisionFooter,
  EmptyState,
  Panel,
  QualityList,
  QualityRow,
  StateRow,
  StatusChip,
} from "../shared/ui/AdminPrimitives";

const imageData =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'%3E%3Crect width='320' height='180' fill='%23f6f1e8'/%3E%3Ccircle cx='88' cy='84' r='42' fill='%236756ff'/%3E%3Crect x='154' y='54' width='110' height='18' rx='9' fill='%23191824'/%3E%3Crect x='154' y='88' width='78' height='14' rx='7' fill='%237c7a86'/%3E%3Crect x='154' y='118' width='96' height='14' rx='7' fill='%23d96c52'/%3E%3C/svg%3E";

const noop = () => undefined;
const recordDecision = async () => undefined;

const meta = {
  title: "Admin Dashboard/Operations Primitives",
  parameters: {
    catchComponentRegistry: {
      path: "design/admin/components.json",
    },
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

export const AdminOverviewMainGridStory: Story = {
  name: "Overview main grid",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_main_grid",
      states: ["summary-and-detail"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewMainGrid aria-label="Admin overview">
        <AdminCard>
          <AdminStateRow label="Queued" value="12" />
          <AdminStateRow label="Escalated" value="3" />
        </AdminCard>
        <AdminOverviewQueueDetailPanel>
          <QualityList>
            <QualityRow icon={<Activity size={16} />} tone="success">
              Queue freshness under five minutes.
            </QualityRow>
          </QualityList>
        </AdminOverviewQueueDetailPanel>
      </AdminOverviewMainGrid>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueColumnsStory: Story = {
  name: "Queue columns",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_columns",
      states: ["two-columns"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueColumns>
        <AdminOverviewQueueList>
          <AdminOverviewQueueHeading count="8" owner="Publishing" title="Ready" />
        </AdminOverviewQueueList>
        <AdminOverviewQueueDetailPanel>
          <StateRow label="Selected" value="Organizer packet" />
        </AdminOverviewQueueDetailPanel>
      </AdminOverviewQueueColumns>
    </AdminWorkspace>
  ),
};

export const AdminOverviewAnalyticsClearButtonStory: Story = {
  name: "Analytics clear button",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_analytics_clear_button",
      states: ["default"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewAnalyticsClearButton onClick={noop}>
        Clear filters
      </AdminOverviewAnalyticsClearButton>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueListStory: Story = {
  name: "Queue list",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_list",
      states: ["with-heading"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueList>
        <AdminOverviewQueueHeading
          count="5"
          owner="Publishing"
          title="Publishing queue"
        />
        <AdminOverviewQueueItems>
          <AdminOverviewQueueRow intent="neutral">Organizer profile ready</AdminOverviewQueueRow>
        </AdminOverviewQueueItems>
      </AdminOverviewQueueList>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueHeadingStory: Story = {
  name: "Queue heading",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_heading",
      states: ["count", "owner"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueHeading count="14" owner="Safety" title="Needs review" />
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueItemsStory: Story = {
  name: "Queue items",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_items",
      states: ["stacked"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueItems>
        <AdminOverviewQueueRow intent="warning">Policy evidence pending</AdminOverviewQueueRow>
        <AdminOverviewQueueRow intent="neutral">Source links verified</AdminOverviewQueueRow>
      </AdminOverviewQueueItems>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueRowStory: Story = {
  name: "Queue row",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_row",
      states: ["neutral", "warning", "selected"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueItems>
        <AdminOverviewQueueRow intent="neutral">Standard review item</AdminOverviewQueueRow>
        <AdminOverviewQueueRow intent="warning">Needs evidence follow-up</AdminOverviewQueueRow>
        <AdminOverviewQueueRow intent="danger" selected>
          Policy escalation selected
        </AdminOverviewQueueRow>
      </AdminOverviewQueueItems>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueRowActionsStory: Story = {
  name: "Queue row actions",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_row_actions",
      states: ["actions"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueRowActions>
        <AdminButton>Open</AdminButton>
        <AdminButton variant="primary">Assign</AdminButton>
      </AdminOverviewQueueRowActions>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueActionHintStory: Story = {
  name: "Queue action hint",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_action_hint",
      states: ["hint"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueActionHint>Review source evidence first</AdminOverviewQueueActionHint>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueDecisionButtonStory: Story = {
  name: "Queue decision button",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_decision_button",
      states: ["default"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueDecisionButton onClick={noop}>
        Mark reviewed
      </AdminOverviewQueueDecisionButton>
    </AdminWorkspace>
  ),
};

export const AdminOverviewQueueDetailPanelStory: Story = {
  name: "Queue detail panel",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_queue_detail_panel",
      states: ["details"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewQueueDetailPanel aria-label="Queue detail">
        <StateRow label="Owner" value="Ops" />
        <StateRow label="Status" value="Needs source check" />
      </AdminOverviewQueueDetailPanel>
    </AdminWorkspace>
  ),
};

export const AdminOverviewLineChartStory: Story = {
  name: "Overview line chart",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_line_chart",
      states: ["with-data", "empty"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewLineChart
        emptyLabel="No trend data"
        points={[
          {label: "Mon", value: 42},
          {label: "Tue", value: 68},
          {label: "Wed", value: 57},
          {label: "Thu", value: 81},
        ]}
      />
      <AdminOverviewLineChart emptyLabel="No trend data" points={[]} />
    </AdminWorkspace>
  ),
};

export const AdminOverviewBarChartStory: Story = {
  name: "Overview bar chart",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_bar_chart",
      states: ["with-data", "empty"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewBarChart
        emptyLabel="No volume data"
        points={[
          {label: "Leads", value: 22},
          {label: "Ready", value: 15},
          {label: "Blocked", value: 6},
        ]}
      />
      <AdminOverviewBarChart emptyLabel="No volume data" points={[]} />
    </AdminWorkspace>
  ),
};

export const AdminOverviewValueSignalsStory: Story = {
  name: "Overview value signals",
  parameters: {
    catchComponent: {
      id: "shared_admin_overview_value_signals",
      states: ["mixed-tones"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminOverviewValueSignals
        signals={[
          {label: "Readiness", tone: "green", value: 84},
          {label: "Quality", tone: "teal", value: 71},
          {label: "Risk", tone: "orange", value: 38},
          {label: "Blocked", tone: "red", value: 12},
        ]}
      />
    </AdminWorkspace>
  ),
};

export const AdminSignalBarsStory: Story = {
  name: "Signal bars",
  parameters: {
    catchComponent: {
      id: "shared_admin_signal_bars",
      states: ["neutral", "semantic", "zero"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminSignalBars
        ariaLabel="Open cases by queue"
        eyebrow="Open by queue · aggregate"
        signals={[
          {label: "User reports", tone: "neutral", value: 12},
          {label: "High priority", tone: "red", value: 4},
          {label: "Medium priority", tone: "orange", value: 2},
          {label: "Watch", tone: "neutral", value: 0},
        ]}
      />
    </AdminWorkspace>
  ),
};

export const AdminPublishingLoadbarStory: Story = {
  name: "Publishing loadbar",
  parameters: {
    catchComponent: {
      id: "shared_admin_publishing_loadbar",
      states: ["loaded"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminPublishingLoadbar>
        <span>Publication packet loaded</span>
        <StatusChip tone="success">Synced</StatusChip>
      </AdminPublishingLoadbar>
    </AdminWorkspace>
  ),
};

export const AdminSurfacePreviewStory: Story = {
  name: "Surface preview",
  parameters: {
    catchComponent: {
      id: "shared_admin_surface_preview",
      states: ["listing-preview"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminSurfacePreview>
        <AdminTagList>
          <AdminTag>public listing</AdminTag>
          <AdminTag tone="ready">claim CTA</AdminTag>
        </AdminTagList>
        <QualityRow icon={<Eye size={16} />} tone="success">
          Preview copy matches the generated route payload.
        </QualityRow>
      </AdminSurfacePreview>
    </AdminWorkspace>
  ),
};

export const AdminMutedCellStory: Story = {
  name: "Muted cell",
  parameters: {
    catchComponent: {
      id: "shared_admin_muted_cell",
      states: ["inline"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminMutedCell>Last checked 3 minutes ago</AdminMutedCell>
    </AdminWorkspace>
  ),
};

export const AdminEventSupplyReviewGridStory: Story = {
  name: "Event supply review grid",
  parameters: {
    catchComponent: {
      id: "shared_admin_event_supply_review_grid",
      states: ["table-and-detail"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEventSupplyReviewGrid>
        <DataTable ariaLabel="Event supply review" compact variant="workbench">
          <tbody>
            <tr>
              <td>Venue import</td>
              <td><StatusChip tone="warning">Review</StatusChip></td>
            </tr>
          </tbody>
        </DataTable>
        <AdminEventSupplyDetail>
          <StateRow label="Source" value="Partner feed" />
        </AdminEventSupplyDetail>
      </AdminEventSupplyReviewGrid>
    </AdminWorkspace>
  ),
};

export const AdminEventSupplyDetailStackStory: Story = {
  name: "Event supply detail stack",
  parameters: {
    catchComponent: {
      id: "shared_admin_event_supply_detail_stack",
      states: ["stacked"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEventSupplyDetailStack>
        <StateRow label="Matched organizer" value="Rooftop Social" />
        <StateRow label="Confidence" value="High" />
      </AdminEventSupplyDetailStack>
    </AdminWorkspace>
  ),
};

export const AdminEventSupplyDetailStory: Story = {
  name: "Event supply detail",
  parameters: {
    catchComponent: {
      id: "shared_admin_event_supply_detail",
      states: ["aside"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEventSupplyDetail>
        <QualityList>
          <QualityRow icon={<CalendarDays size={16} />} tone="success">
            Event timing is inside the publication window.
          </QualityRow>
        </QualityList>
      </AdminEventSupplyDetail>
    </AdminWorkspace>
  ),
};

export const AdminEventSupplyLinksStory: Story = {
  name: "Event supply links",
  parameters: {
    catchComponent: {
      id: "shared_admin_event_supply_links",
      states: ["actions"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEventSupplyLinks>
        <AdminButton icon={<Link2 size={16} />}>Source</AdminButton>
        <AdminButton icon={<Eye size={16} />}>Preview</AdminButton>
      </AdminEventSupplyLinks>
    </AdminWorkspace>
  ),
};

export const AdminCommandStackStory: Story = {
  name: "Command stack",
  parameters: {
    catchComponent: {
      id: "shared_admin_command_stack",
      states: ["commands"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminCommandStack>
        <AdminCommandRow>
          <strong>Refresh dashboard</strong>
          <AdminButton icon={<RefreshCw size={16} />}>Run</AdminButton>
        </AdminCommandRow>
        <AdminCommandRow>
          <strong>Publish selected</strong>
          <AdminButton variant="primary">Publish</AdminButton>
        </AdminCommandRow>
      </AdminCommandStack>
    </AdminWorkspace>
  ),
};

export const AdminCommandRowStory: Story = {
  name: "Command row",
  parameters: {
    catchComponent: {
      id: "shared_admin_command_row",
      states: ["with-action"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminCommandRow>
        <span>Regenerate route manifest</span>
        <AdminButton>Queue job</AdminButton>
      </AdminCommandRow>
    </AdminWorkspace>
  ),
};

export const AdminChecklistStackStory: Story = {
  name: "Checklist stack",
  parameters: {
    catchComponent: {
      id: "shared_admin_checklist_stack",
      states: ["checks"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminChecklistStack>
        <AlertRow icon={<CheckCircle2 size={16} />} title="Route contract" tone="success">
          Public path is present.
        </AlertRow>
        <AlertRow icon={<FileWarning size={16} />} title="Claim copy" tone="warning">
          Needs owner review.
        </AlertRow>
      </AdminChecklistStack>
    </AdminWorkspace>
  ),
};

export const AdminEditorGridStory: Story = {
  name: "Editor grid",
  parameters: {
    catchComponent: {
      id: "shared_admin_editor_grid",
      states: ["section", "div"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEditorGrid aria-label="Publishing editor">
        <AdminTextField label="Title" value="Friday Social" onChange={noop} />
        <AdminTextField label="Slug" value="friday-social" onChange={noop} />
      </AdminEditorGrid>
      <AdminEditorGrid as="div">
        <AdminTextareaField
          label="Review note"
          rows={3}
          value="Approved with source evidence."
          onChange={noop}
        />
      </AdminEditorGrid>
    </AdminWorkspace>
  ),
};

export const AdminFilterBarStory: Story = {
  name: "Filter bar",
  parameters: {
    catchComponent: {
      id: "shared_admin_filter_bar",
      states: ["controls"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFilterBar ariaLabel="Overview filters">
        <AdminButton selected>All</AdminButton>
        <AdminButton>Blocked</AdminButton>
        <AdminOverviewAnalyticsClearButton onClick={noop}>
          Reset
        </AdminOverviewAnalyticsClearButton>
      </AdminFilterBar>
    </AdminWorkspace>
  ),
};

export const AdminEventSupplyEmptyStateStory: Story = {
  name: "Event supply empty state",
  parameters: {
    catchComponent: {
      id: "shared_admin_event_supply_empty_state",
      states: ["empty"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEventSupplyEmptyState icon={<CalendarDays size={18} />}>
        Select an event candidate to inspect its source evidence.
      </AdminEventSupplyEmptyState>
    </AdminWorkspace>
  ),
};

export const AdminDiffListStory: Story = {
  name: "Diff list",
  parameters: {
    catchComponent: {
      id: "shared_admin_diff_list",
      states: ["rows"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminDiffList>
        <AdminDiffRow field="Title" before="Old meetup" after="Friday Social" />
        <AdminDiffRow field="CTA" before="Join" after="Claim listing" />
      </AdminDiffList>
    </AdminWorkspace>
  ),
};

export const AdminDiffRowStory: Story = {
  name: "Diff row",
  parameters: {
    catchComponent: {
      id: "shared_admin_diff_row",
      states: ["before-after"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminDiffRow field="Status" before="Draft" after="Ready" />
    </AdminWorkspace>
  ),
};

export const AdminRoadmapListStory: Story = {
  name: "Roadmap list",
  parameters: {
    catchComponent: {
      id: "shared_admin_roadmap_list",
      states: ["items"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminRoadmapList>
        <AdminRoadmapListItem>Move public route copy to generated contract.</AdminRoadmapListItem>
        <AdminRoadmapListItem>Promote claim CTA once ownership is verified.</AdminRoadmapListItem>
      </AdminRoadmapList>
    </AdminWorkspace>
  ),
};

export const AdminRoadmapListItemStory: Story = {
  name: "Roadmap list item",
  parameters: {
    catchComponent: {
      id: "shared_admin_roadmap_list_item",
      states: ["single"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminRoadmapListItem>Backfill listing screenshots after route launch.</AdminRoadmapListItem>
    </AdminWorkspace>
  ),
};

export const AdminQueryListStory: Story = {
  name: "Query list",
  parameters: {
    catchComponent: {
      id: "shared_admin_query_list",
      states: ["rows"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminQueryList>
        <AdminQueryRow>
          <strong>Publishing queue</strong>
          <span>Ready organizers by confidence tier.</span>
        </AdminQueryRow>
        <AdminQueryRow>
          <strong>Claim requests</strong>
          <span>Open claims needing staff review.</span>
        </AdminQueryRow>
      </AdminQueryList>
    </AdminWorkspace>
  ),
};

export const AdminQueryRowStory: Story = {
  name: "Query row",
  parameters: {
    catchComponent: {
      id: "shared_admin_query_row",
      states: ["query"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminQueryRow>
        <strong>Recent public listings</strong>
        <span>Generated route status, owner, and last publish time.</span>
      </AdminQueryRow>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropFeatureListStory: Story = {
  name: "Feature drop feature list",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_feature_list",
      states: ["features"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropFeatureList>
        <AdminFeatureDropFeatureEditor>
          <strong>Organizer profiles</strong>
          <AdminTagList>
            <AdminTag tone="ready">ready</AdminTag>
            <AdminTag>public route</AdminTag>
          </AdminTagList>
        </AdminFeatureDropFeatureEditor>
      </AdminFeatureDropFeatureList>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropFeatureEditorStory: Story = {
  name: "Feature drop feature editor",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_feature_editor",
      states: ["fields"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropFeatureEditor>
        <AdminTextField label="Feature title" value="Claim-ready profiles" onChange={noop} />
        <AdminTextareaField
          label="Feature copy"
          rows={3}
          value="Public listing copy backed by source evidence and owner handoff."
          onChange={noop}
        />
      </AdminFeatureDropFeatureEditor>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropControlGridStory: Story = {
  name: "Feature drop control grid",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_control_grid",
      states: ["controls"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropControlGrid>
        <AdminTextField label="Campaign" value="Organizer launch" onChange={noop} />
        <AdminTextField label="Audience" value="Hosts" onChange={noop} />
        <AdminFeatureDropWideField>
          <AdminTextareaField
            label="Announcement copy"
            rows={3}
            value="Invite verified organizers to claim and maintain their public listing."
            onChange={noop}
          />
        </AdminFeatureDropWideField>
      </AdminFeatureDropControlGrid>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropWideFieldStory: Story = {
  name: "Feature drop wide field",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_wide_field",
      states: ["wide-field"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropControlGrid>
        <AdminFeatureDropWideField>
          <AdminTextareaField
            label="Long-form copy"
            rows={4}
            value="Use this area for the complete launch narrative."
            onChange={noop}
          />
        </AdminFeatureDropWideField>
      </AdminFeatureDropControlGrid>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropPreviewGridStory: Story = {
  name: "Feature drop preview grid",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_preview_grid",
      states: ["cards"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropPreviewGrid>
        <AdminFeatureDropPreviewCard>
          <AdminFeatureDropCaptureThumb src={imageData} alt="Organizer feature preview" />
          <figcaption>Organizer claim launch</figcaption>
        </AdminFeatureDropPreviewCard>
        <AdminFeatureDropPreviewCard>
          <EmptyState icon={<ImageIcon size={18} />}>Awaiting capture</EmptyState>
        </AdminFeatureDropPreviewCard>
      </AdminFeatureDropPreviewGrid>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropPreviewCardStory: Story = {
  name: "Feature drop preview card",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_preview_card",
      states: ["image", "empty"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropPreviewCard>
        <AdminFeatureDropCaptureThumb src={imageData} alt="Feature capture" />
        <figcaption>Claim CTA preview</figcaption>
      </AdminFeatureDropPreviewCard>
    </AdminWorkspace>
  ),
};

export const AdminFeatureDropCaptureThumbStory: Story = {
  name: "Feature drop capture thumb",
  parameters: {
    catchComponent: {
      id: "shared_admin_feature_drop_capture_thumb",
      states: ["image"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminFeatureDropCaptureThumb src={imageData} alt="Feature capture thumbnail" />
    </AdminWorkspace>
  ),
};

export const AdminPublishingFormShellStory: Story = {
  name: "Publishing form shell",
  parameters: {
    catchComponent: {
      id: "shared_admin_publishing_form_shell",
      states: ["fields"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminPublishingFormShell>
        <AdminEditorSection>
          <legend>Publishing details</legend>
          <AdminTextField label="Public title" value="Rooftop Social" onChange={noop} />
          <AdminTextareaField label="Summary" rows={3} value="Verified organizer profile." onChange={noop} />
        </AdminEditorSection>
      </AdminPublishingFormShell>
    </AdminWorkspace>
  ),
};

export const AdminEditorSectionStory: Story = {
  name: "Editor section",
  parameters: {
    catchComponent: {
      id: "shared_admin_editor_section",
      states: ["fieldset"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEditorSection>
        <legend>Review fields</legend>
        <AdminTextField label="Canonical owner" value="Organizer team" onChange={noop} />
      </AdminEditorSection>
    </AdminWorkspace>
  ),
};

export const PanelStory: Story = {
  name: "Panel",
  parameters: {
    catchComponent: {
      id: "shared_panel",
      states: ["default", "action"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <Panel
        action={<AdminButton>Inspect</AdminButton>}
        icon={<ShieldCheck size={18} />}
        title="Publication guardrails"
      >
        <QualityList>
          <QualityRow icon={<Lock size={16} />}>Claim handoff remains staff reviewed.</QualityRow>
        </QualityList>
      </Panel>
    </AdminWorkspace>
  ),
};

export const AdminEditorPanelStory: Story = {
  name: "Editor panel",
  parameters: {
    catchComponent: {
      id: "shared_admin_editor_panel",
      states: ["editor", "wide"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <AdminEditorPanel
        action={<AdminButton variant="primary">Save</AdminButton>}
        icon={<ClipboardList size={18} />}
        span={2}
        title="Listing editor"
      >
        <AdminEditorGrid as="div">
          <AdminTextField label="Listing title" value="Rooftop Social" onChange={noop} />
          <AdminTextField label="Path" value="/organizers/rooftop-social" onChange={noop} />
        </AdminEditorGrid>
      </AdminEditorPanel>
    </AdminWorkspace>
  ),
};

export const StateRowStory: Story = {
  name: "State row",
  parameters: {
    catchComponent: {
      id: "shared_state_row",
      states: ["with-value", "empty"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <StateRow label="Canonical path" value="/organizers/rooftop-social" />
      <StateRow label="Owner claim" value={null} />
    </AdminWorkspace>
  ),
};

export const DecisionFooterStory: Story = {
  name: "Decision footer",
  parameters: {
    catchComponent: {
      id: "shared_decision_footer",
      states: ["editable", "approved", "blocked"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <DecisionFooter
        defaultNote="Reviewed by staff."
        edits={{publicListing: true}}
        note="Approve once claim copy is final."
        showExportReady
        targetId="organizer-rooftop-social"
        targetType="organizer"
        onDecision={recordDecision}
        onNoteChange={noop}
      />
      <DecisionFooter
        defaultNote="Already approved."
        edits={{}}
        localDecision={{
          decisionPath: "reviewDecisions/organizer-rooftop-social",
          decisionStatus: "approved",
        }}
        note=""
        targetId="organizer-rooftop-social"
        targetType="organizer"
        onDecision={recordDecision}
        onNoteChange={noop}
      />
      <DecisionFooter
        approvalDisabledReason="Source evidence is missing."
        defaultNote="Blocked until evidence is attached."
        edits={{needsEvidence: true}}
        note="Waiting on source URL."
        targetId="event-import-1"
        targetType="event"
        onDecision={recordDecision}
        onNoteChange={noop}
      />
    </AdminWorkspace>
  ),
};
