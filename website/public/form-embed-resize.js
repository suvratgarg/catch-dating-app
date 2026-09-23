/* Catch public form iframe installer v1. No answer, identity, or token access. */
(function () {
  var frame = document.currentScript && document.currentScript.previousElementSibling;
  if (!frame || frame.tagName !== "IFRAME") return;
  var url;
  try { url = new URL(frame.src); } catch (_) { return; }
  var id = url.searchParams.get("embedId");
  if (!id || !/^[A-Za-z0-9_-]{1,80}$/.test(id) ||
      url.searchParams.get("embed") !== "1") return;
  function resize(event) {
    var data = event.data;
    if (event.origin !== url.origin || event.source !== frame.contentWindow ||
        !data || typeof data !== "object" || Array.isArray(data) ||
        Object.keys(data).sort().join(",") !== "embedId,height,type,version" ||
        data.type !== "catch:form:resize" || data.version !== 1 ||
        data.embedId !== id || !Number.isInteger(data.height) ||
        data.height < 320 || data.height > 4000) return;
    frame.style.height = data.height + "px";
  }
  window.addEventListener("message", resize);
})();
