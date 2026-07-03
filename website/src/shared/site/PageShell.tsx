import type {HTMLAttributes, ReactNode} from "react";

function classNames(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

export function PageShell({
  children,
  pageClassName,
  ...props
}: Omit<HTMLAttributes<HTMLDivElement>, "className"> & {
  children: ReactNode;
  pageClassName: string;
}) {
  return (
    <div {...props} className={classNames("page-shell", pageClassName)}>
      {children}
    </div>
  );
}

export function WebsitePageMain({
  children,
  ...props
}: Omit<HTMLAttributes<HTMLElement>, "className"> & {
  children: ReactNode;
}) {
  return <main {...props}>{children}</main>;
}
