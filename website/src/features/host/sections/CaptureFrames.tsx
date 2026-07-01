import type {CaptureRecord} from "../../../app/usePageLifecycle";
import {
  CaptureCard as CanonicalCaptureCard,
} from "../../../components/site";

export type HostCaptureMap = Record<string, CaptureRecord>;

export function CaptureCard({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: HostCaptureMap;
}) {
  return <CanonicalCaptureCard id={id} fallbackStep={fallbackStep} captures={captures} />;
}

export function PhoneCaptureFrame({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: HostCaptureMap;
}) {
  const capture = captures[id];
  const imagePath = capture?.webPath ?? `/assets/app-screenshots/placeholders/${id}.svg`;

  return (
    <figure className="phone-capture" data-capture-slot={id}>
      <div className="phone-capture__device">
        <span className="phone-capture__notch" aria-hidden="true" />
        <div className="phone-capture__screen">
          <img
            src={imagePath}
            alt={capture?.alt ?? `${fallbackStep} app screenshot`}
            loading="lazy"
          />
        </div>
      </div>
      <figcaption>{capture?.caption ?? `${fallbackStep} in the Catch app`}</figcaption>
    </figure>
  );
}
