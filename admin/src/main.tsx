import React from "react";
import ReactDOM from "react-dom/client";
import {App} from "./App";
import {AdminQueryProvider} from "./shared/query/queryClient";
import "./styles.css";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <AdminQueryProvider>
      <App />
    </AdminQueryProvider>
  </React.StrictMode>
);
