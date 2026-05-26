// One-import entrypoint for schema-derived contracts used by app code/tests.
//
// Generated outputs remain owned by `tool/contracts/generate_schema_contracts.mjs`;
// this barrel only provides a stable import path.

export 'core/schema_contracts/generated/callable_request_dtos.g.dart';
export 'core/schema_contracts/generated/profile_schema_contracts.g.dart'
    hide
        schemaPhotoPromptAnswerSchema,
        schemaProfilePhotoSchema,
        schemaProfilePromptAnswerSchema,
        schemaUpdateUserProfileCallablePayloadSchema;
export 'core/schema_contracts/generated/schema_contracts.g.dart';
