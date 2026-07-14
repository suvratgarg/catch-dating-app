export class OperationDomainError extends Error {
  constructor(
    readonly code: string,
    message: string
  ) {
    super(message);
    this.name = "OperationDomainError";
  }
}

export class OperationConflictError extends OperationDomainError {
  constructor(code: string, message: string) {
    super(code, message);
    this.name = "OperationConflictError";
  }
}

export class OperationNotFoundError extends OperationDomainError {
  constructor(entity: string, id: string) {
    super("not_found", `${entity} ${id} was not found`);
    this.name = "OperationNotFoundError";
  }
}
