import type {ReactNode} from "react";
import "../src/styles.css";
import "./next.css";
export default function RootLayout({children}: {children: ReactNode}) {
  return <html lang="en"><body>{children}</body></html>;
}
