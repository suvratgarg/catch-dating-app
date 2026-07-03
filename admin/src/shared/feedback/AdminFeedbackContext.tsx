import {createContext, type ReactNode, useContext, useMemo} from "react";

interface AdminFeedbackContextValue {
  setError: (message: string | null) => void;
  setNotice: (message: string | null) => void;
}

const AdminFeedbackContext = createContext<AdminFeedbackContextValue | null>(null);

export function AdminFeedbackProvider({
  children,
  onError,
  onNotice,
}: {
  children: ReactNode;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const value = useMemo(
    () => ({setError: onError, setNotice: onNotice}),
    [onError, onNotice]
  );
  return (
    <AdminFeedbackContext.Provider value={value}>
      {children}
    </AdminFeedbackContext.Provider>
  );
}

export function useAdminFeedback() {
  const value = useContext(AdminFeedbackContext);
  if (!value) {
    throw new Error("useAdminFeedback must be used inside AdminFeedbackProvider.");
  }
  return value;
}
