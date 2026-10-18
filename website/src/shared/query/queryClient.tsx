import {createWebQueryClient} from "@catch/web-config/query";
import {QueryClientProvider} from "@tanstack/react-query";
import {type ReactNode, useState} from "react";

export function WebsiteQueryProvider({children}: {children: ReactNode}) {
  const [client] = useState(createWebQueryClient);
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
