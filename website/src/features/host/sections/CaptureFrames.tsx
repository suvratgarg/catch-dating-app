import {
  CaptureCard as CanonicalCaptureCard,
  type CaptureRecord,
  PhoneCaptureShell,
} from "../../../shared/ui/primitives";

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
    <PhoneCaptureShell
      caption={capture?.caption ?? `${fallbackStep} in the Catch app`}
      captureSlotId={id}
    >
      <img
        src={imagePath}
        alt={capture?.alt ?? `${fallbackStep} app screenshot`}
        loading="lazy"
      />
    </PhoneCaptureShell>
  );
}
