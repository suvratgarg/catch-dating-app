// Safety callable request DTOs.
//
// These classes are generated from contracts/callables/{block,unblock,report}_user_payload.schema.json
// by tool/contracts/generate_schema_contracts.mjs. Their toJson() output is
// validated against the source schemas by test/core/callable_dto_contracts_test.dart.
//
// This file exists so callers can import the safety DTOs at this stable path;
// the actual class definitions live in the generated file.

export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        BlockUserCallableRequest,
        UnblockUserCallableRequest,
        ReportUserCallableRequest;
