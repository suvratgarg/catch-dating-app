import {
  adminRoleClaimKeys,
  type AdminRoleClaim,
} from "../../../shared/types/adminTypes";

export interface AdminRolePolicy {
  role: AdminRoleClaim;
  label: string;
  capability: string;
  risk: "standard" | "high" | "critical";
  confirmationRequired: boolean;
}

export const adminRolePolicies: Record<AdminRoleClaim, AdminRolePolicy> = {
  admin: {
    role: "admin",
    label: "Admin operator",
    capability: "Broad operational access across non-owner admin workflows.",
    risk: "high",
    confirmationRequired: true,
  },
  adminOwner: {
    role: "adminOwner",
    label: "Admin owner",
    capability: "Role governance and owner-only administrative authority.",
    risk: "critical",
    confirmationRequired: true,
  },
  safetyReviewer: {
    role: "safetyReviewer",
    label: "Safety reviewer",
    capability: "Safety queue evidence, assignment, and governed case decisions.",
    risk: "high",
    confirmationRequired: true,
  },
  support: {
    role: "support",
    label: "Support",
    capability: "Support-scoped operational reads and approved support workflows.",
    risk: "standard",
    confirmationRequired: false,
  },
  finance: {
    role: "finance",
    label: "Finance",
    capability: "Recognized claim; dedicated Finance surface authorization remains contract-first deferred.",
    risk: "high",
    confirmationRequired: true,
  },
  analyticsViewer: {
    role: "analyticsViewer",
    label: "Analytics viewer",
    capability: "Read-only product and host analytics surfaces.",
    risk: "standard",
    confirmationRequired: false,
  },
};

export const adminRolePolicyList = adminRoleClaimKeys.map(
  (role) => adminRolePolicies[role]
);
