import type {HTMLAttributes, ReactNode} from "react";
import styles from "./CatchPageBody.module.css";

/** Spacing steps, named after the Flutter `CatchSpacing` constants. */
export type CatchSpacingStep =
  | "s0"
  | "s1"
  | "s2"
  | "s3"
  | "s4"
  | "s5"
  | "s6"
  | "s7"
  | "s8"
  | "s9"
  | "s10"
  | "s11"
  | "s12"
  | "s16";

export type CatchPageBodyElement = "div" | "main" | "section";

export interface CatchPageBodyProps
  extends Omit<HTMLAttributes<HTMLElement>, "className" | "style"> {
  as?: CatchPageBodyElement;
  children: ReactNode;
  /** Centres the body at the content width, as Flutter's slivers recipe does. */
  constrainToContentWidth?: boolean;
  /** Applies the page gutter on both sides. */
  gutter?: boolean;
  /** Bottom inset; defaults to `CatchSpacing.screenPb` (s5). */
  pb?: CatchSpacingStep;
  /** Top inset; defaults to `CatchSpacing.screenPt` (the page body start). */
  pt?: CatchSpacingStep;
}

/**
 * Owns a page's insets: the page gutter and the body's top and bottom space,
 * as Flutter's `CatchPageBody.screen`. Nested content keeps its own geometry.
 */
export function CatchPageBody({
  as: Element = "div",
  children,
  constrainToContentWidth = false,
  gutter = true,
  pb,
  pt,
  ...props
}: CatchPageBodyProps) {
  return (
    <Element
      {...props}
      className={styles.body}
      data-constrained={constrainToContentWidth || undefined}
      data-gutter={gutter || undefined}
      data-pb={pb}
      data-pt={pt}
    >
      {children}
    </Element>
  );
}
