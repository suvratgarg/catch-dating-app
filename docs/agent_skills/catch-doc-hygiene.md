# catch-doc-hygiene

Use for docs consolidation, deletion, drift cleanup, and source-of-truth updates.

Read: `docs/README.md` and the owner document for the changed topic.

Optional orientation:
`node tool/agent/context_pack.mjs --task doc-hygiene --paths docs`.

Loop: identify the durable owner doc, fold in current guidance, delete or mark
stale docs, update the docs index, validate source frontmatter and references,
then run `node tool/docs/check_doc_metadata.mjs --base <base>` plus the focused
documentation checks. Do not create a parallel metadata catalog.

Failure modes to avoid: adding a new doc when an owner exists, deleting docs
while leaving stale references, and keeping temporary trackers after their
decisions have migrated.
