<!-- GENERATED FROM design/features/host_feature_responsibilities.json. DO NOT EDIT. -->

# Host Audience

Own the participant relationship system as one destination: People, saved Audiences, Forms, Responses, and organizer Applications, with shared organizer scope and deliberate handoff to Inbox for delivery.

## Ownership

- Primary route: `hostAudienceScreen` (`/host/audience`)
- Target root: `lib/hosts/audience`
- Migration status: target boundary defined; implementation still lives in listed legacy Host roots
- Responsibility contract updated: 2026-09-01

Current implementation roots:

- `lib/hosts/presentation/customers`
- `lib/hosts/presentation/forms`
- `lib/hosts/presentation/applications`

## This feature owns

- Own the /host/audience destination and its People, Audiences, Forms, and Responses peer modes; Forms must not return as a global tab.
- Own customer directory, identity, private memory, tags, notes, attendance history, merge review, and contact administration.
- Own reusable audience definitions, exact previews, reach summaries, archive, and the vocabulary that decides who belongs to a group.
- Own form templates, drafts, builder state, publication, share links, responses, analytics, exports, and automation configuration or recovery.
- Own organizer application queues and review routing as participant intake.
- Pass saved-audience or contact identity to Inbox without implementing message delivery.

## This feature does not own

- Conversation threads, campaign delivery, provider send adapters, or sender onboarding; those belong to Inbox.
- Event inventory, event-management mutations, organizer profile settings, or payout setup.
- High-spender segmentation until canonical completed non-refunded payment totals are projected into indexed contact traits.

## Routes

Owned routes:

- `hostAudienceScreen` — `/host/audience`
- `hostAddCustomerScreen` — `/host/audience/people/new`
- `hostCreateSavedAudienceScreen` — `/host/audience/audiences/new`
- `hostSavedAudienceDetailScreen` — `/host/audience/audiences/:audienceId`
- `hostFormTemplatesScreen` — `/host/audience/forms/new`
- `hostFormResponseDetailScreen` — `/host/audience/responses/:responseId`
- `hostFormBuilderScreen` — `/host/audience/forms/:formId`
- `hostFormPreviewScreen` — `/host/audience/forms/:formId/preview`
- `hostFormShareScreen` — `/host/audience/forms/:formId/share`
- `hostFormAnalyticsScreen` — `/host/audience/forms/:formId/analytics`
- `hostFormAutomationsScreen` — `/host/audience/forms/:formId/automations`
- `hostApplicationsScreen` — `/host/audience/applications`
- `hostApplicationDetailScreen` — `/host/audience/applications/:applicationId`
- `hostCustomerDetailScreen` — `/host/audience/people/:contactId`

Typed handoffs:

- `hostInboxScreen` — `/host/inbox`
- `hostAppEventDetailScreen` — `/host/organizers/:clubId/events/:eventId`

## Key code owners

| Owner | Source | Responsibility |
|---|---|---|
| `HostCustomersScreen` | `lib/hosts/presentation/customers/host_customers_screen.dart` | Feature-contract actions: switch_customers_view, retry_directory, switch_organizer, search_customers, open_customer_filters, filter_customers, sort_customers, message_filtered_customers, review_whatsapp_sender_setup, open_customer, review_duplicate_customers. |
| `HostSavedAudiencesWorkspace` | `lib/hosts/presentation/customers/host_saved_audiences_workspace.dart` | Feature-contract actions: search_saved_audiences, open_saved_audience_create, open_saved_audience_detail. |
| `HostSavedAudienceEditorScreen` | `lib/hosts/presentation/customers/host_saved_audience_editor.dart` | Feature-contract actions: save_saved_audience, refresh_saved_audience_preview, archive_saved_audience. |
| `HostAddCustomerScreen` | `lib/hosts/presentation/customers/host_customer_editor.dart` | Structural owner from feature.host_customers. |
| `HostCustomersDirectoryController` | `lib/hosts/presentation/customers/host_customers_controller.dart` | Feature-contract actions: load_more. |
| `HostCustomersController` | `lib/hosts/presentation/customers/host_customers_controller.dart` | Feature-contract actions: export_customers, create_customer, manage_customer, start_conversation. |
| `HostCustomerDetailScreen` | `lib/hosts/presentation/customers/host_customer_detail_screen.dart` | Feature-contract actions: open_customer_event, undo_customer_merge, retry_customer_detail, open_personal_whatsapp_handoff. |
| `HostCustomerMemorySection` | `lib/hosts/presentation/customers/host_customer_memory.dart` | Feature-contract actions: edit_contact_tags, create_contact_note, edit_contact_note. |
| `HostContactMergeReviewSheet` | `lib/hosts/presentation/customers/host_contact_merge_review.dart` | Feature-contract actions: decide_duplicate_customer. |
| `HostAudienceView` | `lib/hosts/presentation/host_audience_view.dart` | Closed peer-mode vocabulary for People, Audiences, Forms, and Responses. |
| `HostFormsScreen` | `lib/hosts/presentation/forms/host_forms_screen.dart` | Forms and Responses route composition inside Audience. |
| `HostFormsDirectoryController` | `lib/hosts/presentation/forms/host_forms_controller.dart` | Organizer form inventory state. |
| `HostFormEditorController` | `lib/hosts/presentation/forms/host_forms_controller.dart` | Draft/editor state and publication actions. |
| `HostFormResponsesController` | `lib/hosts/presentation/forms/host_form_operations_controller.dart` | Response list and review-facing projection. |
| `HostFormAutomationsController` | `lib/hosts/presentation/forms/host_form_operations_controller.dart` | Automation configuration and run recovery. |
| `HostApplicationsDirectoryController` | `lib/hosts/presentation/applications/host_applications_controller.dart` | Organizer application intake queue. |

## Shared dependencies

- `lib/hosts/data/host_crm_repository.dart` — Current shared Host data seam for organizer contacts and saved audiences until A3 relocates it.
- `lib/hosts/data/host_forms_repository.dart` — Current shared Host data seam for forms, responses, exports, and automations until A3 relocates it.
- `lib/core/presentation/host_app_shell.dart` — The shell owns global destination navigation and organizer scope.

## Data contracts

- `contracts/callable_responses/create_organizer_contact_response.schema.json`
- `contracts/callable_responses/export_organizer_contacts_response.schema.json`
- `contracts/callable_responses/get_organizer_contact_detail_response.schema.json`
- `contracts/callable_responses/list_organizer_contact_merge_candidates_response.schema.json`
- `contracts/callable_responses/list_organizer_contacts_response.schema.json`
- `contracts/callable_responses/list_organizer_saved_audiences_response.schema.json`
- `contracts/callable_responses/mutate_organizer_contact_response.schema.json`
- `contracts/callable_responses/organizer_contact_note_response.schema.json`
- `contracts/callable_responses/organizer_messaging_setup_response.schema.json`
- `contracts/callable_responses/organizer_saved_audience_response.schema.json`
- `contracts/callable_responses/preview_organizer_saved_audience_response.schema.json`
- `contracts/callable_responses/review_organizer_contact_merge_candidate_response.schema.json`
- `contracts/callables/archive_organizer_saved_audience_payload.schema.json`
- `contracts/callables/create_organizer_contact_note_payload.schema.json`
- `contracts/callables/create_organizer_contact_payload.schema.json`
- `contracts/callables/export_organizer_contacts_payload.schema.json`
- `contracts/callables/get_organizer_contact_detail_payload.schema.json`
- `contracts/callables/list_organizer_contact_merge_candidates_payload.schema.json`
- `contracts/callables/list_organizer_contacts_payload.schema.json`
- `contracts/callables/list_organizer_saved_audiences_payload.schema.json`
- `contracts/callables/mutate_organizer_contact_note_payload.schema.json`
- `contracts/callables/mutate_organizer_contact_payload.schema.json`
- `contracts/callables/preview_organizer_saved_audience_payload.schema.json`
- `contracts/callables/review_organizer_contact_merge_candidate_payload.schema.json`
- `contracts/callables/start_organizer_contact_conversation_payload.schema.json`
- `contracts/callables/upsert_organizer_saved_audience_payload.schema.json`
- `contracts/firestore/organizer_applications.schema.json`
- `contracts/firestore/organizer_contact_channel_states.schema.json`
- `contracts/firestore/organizer_contact_event_edges.schema.json`
- `contracts/firestore/organizer_contact_merge_receipts.schema.json`
- `contracts/firestore/organizer_contact_merge_review_decisions.schema.json`
- `contracts/firestore/organizer_contact_notes.schema.json`
- `contracts/firestore/organizer_contact_tag_vocabularies.schema.json`
- `contracts/firestore/organizer_contact_traits.schema.json`
- `contracts/firestore/organizer_contacts.schema.json`
- `contracts/firestore/organizer_form_automation_rules.schema.json`
- `contracts/firestore/organizer_form_automation_runs.schema.json`
- `contracts/firestore/organizer_form_responses.schema.json`
- `contracts/firestore/organizer_form_versions.schema.json`
- `contracts/firestore/organizer_forms.schema.json`
- `contracts/firestore/organizer_saved_audiences.schema.json`
- `contracts/firestore/payments.schema.json`
- `contracts/shared/organizer_form_common.schema.json`
- `contracts/shared/organizer_form_response_common.schema.json`

## Focused tests

- `test/hosts/host_customers_screen_state_test.dart`
- `test/hosts/forms/host_forms_screen_test.dart`
- `test/hosts/forms/host_form_builder_screen_test.dart`
- `test/hosts/forms/host_form_response_detail_screen_test.dart`
- `test/hosts/host_operations_screen_test.dart`

## Maintenance

Do not edit this file directly. Update `design/features/host_feature_responsibilities.json`, then run:

```sh
node tool/design/build_host_feature_responsibilities.mjs
node tool/design/build_host_feature_responsibilities.mjs --check
```

The generator cross-checks the Host shell order, typed route contract, feature-contract action owners, Dart symbols, data-contract paths, and focused tests.
