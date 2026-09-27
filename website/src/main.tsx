import {StrictMode} from "react";
import {createRoot} from "react-dom/client";
import App from "./App";
import {WebsiteQueryProvider} from "./shared/query/queryClient";
import "./styles.css";
import {captureOfferCredential} from "./features/eventOffers/offerCredential";

captureOfferCredential(window.location, (path) =>
  window.history.replaceState({...window.history.state, catchOfferPaymentId: null, catchOfferGrantId: null}, "", path),
    window.history.state);

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <WebsiteQueryProvider>
      <App />
    </WebsiteQueryProvider>
  </StrictMode>
);
