export function LoopList({
  items,
  modifier,
}: {
  items: Array<{step: string; title: string; body: string}>;
  modifier?: string;
}) {
  return (
    <ol className={`loop-list ${modifier ?? ""}`.trim()}>
      {items.map((item) => (
        <li data-reveal key={item.step}>
          <span>{item.step}</span>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </li>
      ))}
    </ol>
  );
}
