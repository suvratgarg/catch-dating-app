import type {AnimationItem} from "lottie-web/build/player/lottie_light";
import {
  type HTMLAttributes,
  useEffect,
  useRef,
} from "react";

export interface LottieAnimationControlProps
  extends Omit<HTMLAttributes<HTMLDivElement>, "children"> {
  autoplay?: boolean;
  loop?: boolean;
  progress?: number | null;
  reducedMotion?: boolean;
  reducedMotionProgress?: number;
  source: string;
}

/**
 * Lightweight, renderer-neutral Lottie host.
 *
 * The player is loaded only when a motion surface mounts, keeping it out of
 * unrelated route chunks. Surface adapters own sizing and visual treatment.
 */
export function LottieAnimationControl({
  autoplay = true,
  loop = true,
  progress = null,
  reducedMotion = false,
  reducedMotionProgress = 0.5,
  source,
  ...props
}: LottieAnimationControlProps) {
  const hostRef = useRef<HTMLDivElement>(null);
  const animationRef = useRef<AnimationItem | null>(null);
  const progressRef = useRef(progress);
  progressRef.current = progress;

  useEffect(() => {
    const host = hostRef.current;
    if (!host) return;
    let cancelled = false;
    let animation: AnimationItem | null = null;

    void import("lottie-web/build/player/lottie_light").then(({default: lottie}) => {
      if (cancelled) return;
      animation = lottie.loadAnimation({
        autoplay: autoplay && !reducedMotion && progressRef.current === null,
        container: host,
        loop,
        path: source,
        renderer: "svg",
        rendererSettings: {
          preserveAspectRatio: "xMidYMid slice",
          progressiveLoad: true,
        },
      });
      animationRef.current = animation;
      animation.addEventListener("DOMLoaded", () => {
        const requestedProgress = progressRef.current ??
          (reducedMotion ? reducedMotionProgress : null);
        if (requestedProgress !== null) {
          seekToProgress(animation!, requestedProgress);
        }
      });
    });

    return () => {
      cancelled = true;
      if (animationRef.current === animation) animationRef.current = null;
      animation?.destroy();
    };
  }, [autoplay, loop, reducedMotion, reducedMotionProgress, source]);

  useEffect(() => {
    const animation = animationRef.current;
    if (!animation || progress === null) return;
    seekToProgress(animation, progress);
  }, [progress]);

  return <div {...props} aria-hidden="true" ref={hostRef} />;
}

function seekToProgress(animation: AnimationItem, progress: number) {
  const boundedProgress = Math.min(1, Math.max(0, progress));
  animation.goToAndStop(animation.getDuration(true) * boundedProgress, true);
}
