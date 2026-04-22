(function () {
  const prefersReducedMotion = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;

  function initHeaderState() {
    const header = document.querySelector(".site-header");
    if (!header) return;

    const syncHeader = function () {
      header.classList.toggle("is-scrolled", window.scrollY > 18);
    };

    syncHeader();
    window.addEventListener("scroll", syncHeader, {passive: true});
  }

  function initRevealAnimations() {
    const revealItems = document.querySelectorAll("[data-reveal]");
    revealItems.forEach(function (item, index) {
      item.style.transitionDelay = `${(index % 4) * 80}ms`;
    });

    if (prefersReducedMotion || !("IntersectionObserver" in window)) {
      revealItems.forEach(function (item) {
        item.classList.add("is-visible");
      });
      return;
    }

    const observer = new IntersectionObserver(
      function (entries, currentObserver) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-visible");
          currentObserver.unobserve(entry.target);
        });
      },
      {
        threshold: 0.15,
        rootMargin: "0px 0px -40px 0px",
      }
    );

    revealItems.forEach(function (item) {
      observer.observe(item);
    });
  }

  function initHeroParallax() {
    if (prefersReducedMotion) return;
    if (!window.matchMedia("(pointer: fine)").matches) return;

    const visual = document.querySelector(".hero__visual");
    if (!visual) return;

    const floaters = visual.querySelectorAll("[data-float]");
    if (!floaters.length) return;

    const resetFloaters = function () {
      floaters.forEach(function (floater) {
        floater.style.setProperty("--float-x", "0px");
        floater.style.setProperty("--float-y", "0px");
      });
    };

    resetFloaters();

    visual.addEventListener("pointermove", function (event) {
      const bounds = visual.getBoundingClientRect();
      const relativeX = (event.clientX - bounds.left) / bounds.width - 0.5;
      const relativeY = (event.clientY - bounds.top) / bounds.height - 0.5;

      floaters.forEach(function (floater) {
        const depth = Number(floater.getAttribute("data-depth") || "0.4");
        floater.style.setProperty(
          "--float-x",
          `${Math.round(relativeX * depth * 24)}px`
        );
        floater.style.setProperty(
          "--float-y",
          `${Math.round(relativeY * depth * 20)}px`
        );
      });
    });

    visual.addEventListener("pointerleave", resetFloaters);
  }

  function initWaitlistForm() {
    const form = document.querySelector("[data-waitlist-form]");
    if (!(form instanceof HTMLFormElement)) return;

    const status = form.querySelector("[data-form-status]");
    const submitButton = form.querySelector("button[type='submit']");
    const citySelect = form.elements.namedItem("city");
    const customCityField = form.querySelector("[data-custom-city]");
    const customCityInput = form.elements.namedItem("customCity");

    const updateCustomCityVisibility = function () {
      if (
        !(citySelect instanceof HTMLSelectElement) ||
        !(customCityField instanceof HTMLElement)
      ) {
        return;
      }

      const showCustomCity = citySelect.value === "Other";
      customCityField.hidden = !showCustomCity;

      if (customCityInput instanceof HTMLInputElement) {
        customCityInput.required = showCustomCity;
        if (!showCustomCity) customCityInput.value = "";
      }
    };

    const setStatus = function (message, tone) {
      if (!(status instanceof HTMLElement)) return;
      status.textContent = message;
      status.classList.remove("is-error", "is-success");
      if (tone) status.classList.add(tone);
    };

    updateCustomCityVisibility();
    if (citySelect instanceof HTMLSelectElement) {
      citySelect.addEventListener("change", updateCustomCityVisibility);
    }

    form.addEventListener("submit", async function (event) {
      event.preventDefault();

      const payload = new FormData(form);
      const cityValue =
        payload.get("city") === "Other"
          ? String(payload.get("customCity") || "").trim()
          : String(payload.get("city") || "").trim();

      const body = {
        fullName: String(payload.get("fullName") || "").trim(),
        email: String(payload.get("email") || "").trim(),
        city: cityValue,
        role: String(payload.get("role") || "").trim(),
        instagram: String(payload.get("instagram") || "").trim(),
        website: String(payload.get("website") || "").trim(),
      };

      if (!body.fullName || !body.email || !body.city || !body.role) {
        setStatus("Please fill out your name, email, city, and role.", "is-error");
        return;
      }

      if (!(submitButton instanceof HTMLButtonElement)) return;

      submitButton.disabled = true;
      submitButton.textContent = "Joining...";
      setStatus("", "");

      try {
        const response = await fetch("/api/join-waitlist", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });

        const data = await response.json().catch(function () {
          return {};
        });

        if (!response.ok) {
          throw new Error(
            typeof data.error === "string"
              ? data.error
              : "We couldn't save your spot. Please try again."
          );
        }

        form.reset();
        updateCustomCityVisibility();

        if (data.alreadyJoined) {
          setStatus(
            "You're already on the list. We refreshed your details.",
            "is-success"
          );
        } else {
          setStatus(
            "You're in. We'll reach out when Catch opens in your city.",
            "is-success"
          );
        }
      } catch (error) {
        const message =
          error instanceof Error
            ? error.message
            : "We couldn't save your spot. Please try again.";
        setStatus(message, "is-error");
      } finally {
        submitButton.disabled = false;
        submitButton.textContent = "Join the waitlist";
      }
    });
  }

  initHeaderState();
  initRevealAnimations();
  initHeroParallax();
  initWaitlistForm();
})();
