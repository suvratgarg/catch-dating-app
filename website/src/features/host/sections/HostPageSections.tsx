import {hostPageCopy} from "@content/host";
import {WaitlistSection} from "../../../shared/ui/primitives";
import {HostApplicationFlow} from "../application/HostApplicationFlow";

export function HostApplySection() {
  return (
    <WaitlistSection
      introReveal={false}
      id="founding-hosts"
      titleId="host-apply-title"
      title={hostPageCopy.apply.title}
      body={hostPageCopy.apply.body}
    >
      <HostApplicationFlow />
    </WaitlistSection>
  );
}
