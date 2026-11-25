const toggle = document.getElementById("nav-toggle");
const menu = document.getElementById("nav-menu");

if (toggle && menu) {
  toggle.addEventListener("click", () => {
    const open = menu.classList.toggle("open");
    toggle.setAttribute("aria-expanded", String(open));
  });

  menu.querySelectorAll("a").forEach((a) =>
    a.addEventListener("click", () => {
      menu.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    })
  );
}

const header = document.getElementById("site-header");
if (header) {
  const onScroll = () => {
    header.classList.toggle("scrolled", window.scrollY > 10);
  };
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();
}

/* ============================================================
 * Screenshot gallery:
 *  - mobile/tablet: swipeable, snap-scrolling carousel with
 *    arrows + dots (native touch swipe, no library needed)
 *  - desktop: CSS grid; clicking any image opens the lightbox
 * Lightbox: fullscreen viewer with prev/next, keyboard support,
 * wheel / button / double-click zoom and drag-to-pan.
 * ============================================================ */
(function () {
  const track = document.getElementById("gallery-track");
  if (!track) return;

  const slides = Array.from(track.children);
  const n = slides.length;
  const btns = slides
    .map((s) => s.querySelector(".gallery-btn"))
    .filter(Boolean);
  const srcs = btns.map((b) => {
    const img = b.querySelector("img");
    return (img && img.getAttribute("src")) || "";
  });
  const alts = btns.map((b) => {
    const img = b.querySelector("img");
    return (img && img.getAttribute("alt")) || "Screenshot of FOSS Warn";
  });
  const captions = slides.map((s) => {
    const c = s.querySelector(".gallery-caption");
    return (c && c.textContent.trim()) || "";
  });

  const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
  const isCarousel = () => track.scrollWidth > track.clientWidth + 10;
  const step = () =>
    n > 1 ? slides[1].offsetLeft - slides[0].offsetLeft : track.clientWidth;
  const currentIndex = () => clamp(Math.round(track.scrollLeft / step()), 0, n - 1);

  /* ---------- dots (carousel) ---------- */
  const dotsWrap = document.getElementById("gallery-dots");
  const dots = [];
  if (dotsWrap) {
    slides.forEach((_, i) => {
      const d = document.createElement("button");
      d.type = "button";
      d.className = "gallery-dot";
      d.setAttribute("aria-label", `Go to screenshot ${i + 1}`);
      d.addEventListener("click", () => {
        track.scrollTo({ left: slides[i].offsetLeft, behavior: "smooth" });
      });
      dotsWrap.appendChild(d);
      dots.push(d);
    });
    dots[0]?.classList.add("active");
  }

  const syncDots = () => {
    if (!isCarousel()) return;
    const i = currentIndex();
    dots.forEach((d, di) => d.classList.toggle("active", di === i));
  };
  let raf = 0;
  track.addEventListener(
    "scroll",
    () => {
      if (raf) return;
      raf = requestAnimationFrame(() => {
        raf = 0;
        syncDots();
      });
    },
    { passive: true }
  );
  window.addEventListener("resize", syncDots);
  window.addEventListener("load", syncDots);
  if ("ResizeObserver" in window) {
    const ro = new ResizeObserver(syncDots);
    ro.observe(track);
  }

  /* ---------- arrows & keyboard (carousel) ---------- */
  const scrollBySlide = (dir) =>
    track.scrollBy({ left: dir * step(), behavior: "smooth" });

  document
    .querySelector(".gallery-arrow-prev")
    ?.addEventListener("click", () => scrollBySlide(-1));
  document
    .querySelector(".gallery-arrow-next")
    ?.addEventListener("click", () => scrollBySlide(1));

  track.addEventListener("keydown", (e) => {
    if (!isCarousel()) return;
    if (e.key === "ArrowLeft") {
      e.preventDefault();
      scrollBySlide(-1);
    } else if (e.key === "ArrowRight") {
      e.preventDefault();
      scrollBySlide(1);
    }
  });

  /* Suppress a click that follows a swipe so the lightbox does not open */
  btns.forEach((b) => {
    let moved = false,
      sx = 0,
      sy = 0;
    b.addEventListener("pointerdown", (e) => {
      moved = false;
      sx = e.clientX;
      sy = e.clientY;
    });
    b.addEventListener("pointermove", (e) => {
      if (Math.hypot(e.clientX - sx, e.clientY - sy) > 10) moved = true;
    });
    b.addEventListener("pointercancel", () => {
      moved = true;
    });
    b.addEventListener("click", (e) => {
      if (moved) {
        e.preventDefault();
        e.stopPropagation();
      }
    });
  });

  /* ---------- Lightbox ---------- */
  const lb = document.getElementById("lightbox");
  const stage = document.getElementById("lightbox-stage");
  const lbImg = document.getElementById("lightbox-img");
  const lbClose = document.getElementById("lb-close");
  const lbPrev = document.getElementById("lb-prev");
  const lbNext = document.getElementById("lb-next");
  const lbCounter = document.getElementById("lb-counter");
  const lbCaption = document.getElementById("lb-caption");
  const lbDotsWrap = document.getElementById("lb-dots");
  const zoomIn = document.getElementById("lb-zoom-in");
  const zoomOut = document.getElementById("lb-zoom-out");
  const zoomReset = document.getElementById("lb-zoom-reset");
  const zoomLabel = document.getElementById("lb-zoom-label");

  let index = 0;
  let open = false;

  /* zoom state (transform-origin is the image centre) */
  let scale = 1,
    tx = 0,
    ty = 0;
  const MIN_SCALE = 1;
  const MAX_SCALE = 5;

  const applyTransform = () => {
    lbImg.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    const natural = lbImg.naturalWidth || 1080;
    const pct = Math.round((scale * lbImg.offsetWidth) / natural * 100);
    zoomLabel.textContent = scale <= 1.001 ? "Fit" : `${clamp(pct, 100, 999)}%`;
    const zoomed = scale > 1.001;
    stage.style.cursor = zoomed ? "grab" : "zoom-in";
    lbImg.style.cursor = zoomed ? "grab" : "zoom-in";
  };

  const clampPan = () => {
    const w = lbImg.offsetWidth * scale;
    const h = lbImg.offsetHeight * scale;
    const sw = stage.clientWidth;
    const sh = stage.clientHeight;
    const hx = Math.max(0, (w - sw) / 2);
    const hy = Math.max(0, (h - sh) / 2);
    tx = clamp(tx, -hx, hx);
    ty = clamp(ty, -hy, hy);
  };

  const zoomTo = (target, px, py) => {
    target = clamp(target, MIN_SCALE, MAX_SCALE);
    if (target === scale && Number.isFinite(px)) return;
    const rect = stage.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    if (!Number.isFinite(px)) px = cx;
    if (!Number.isFinite(py)) py = cy;
    const u = (px - cx - tx) / scale;
    const v = (py - cy - ty) / scale;
    scale = target;
    tx = px - cx - u * scale;
    ty = py - cy - v * scale;
    clampPan();
    applyTransform();
  };

  const resetZoom = () => {
    scale = 1;
    tx = 0;
    ty = 0;
    applyTransform();
  };

  const animateZoom = () => {
    lbImg.style.transition = "transform .18s ease";
    setTimeout(() => {
      lbImg.style.transition = "";
    }, 200);
  };

  /* ---------- lightbox dots ---------- */
  const lbDots = [];
  if (lbDotsWrap) {
    slides.forEach((_, i) => {
      const d = document.createElement("button");
      d.type = "button";
      d.className = "lightbox-dot";
      d.setAttribute("aria-label", `Go to screenshot ${i + 1}`);
      d.addEventListener("click", () => goTo(i));
      lbDotsWrap.appendChild(d);
      lbDots.push(d);
    });
  }

  /* ---------- navigation ---------- */
  function goTo(i) {
    index = (i + n) % n;
    lbImg.src = srcs[index];
    lbImg.alt = `${alts[index]} — ${index + 1} of ${n}`;
    lbCounter.textContent = `${index + 1} / ${n}`;
    if (lbCaption) lbCaption.textContent = captions[index];
    lbDots.forEach((d, di) => d.classList.toggle("active", di === index));
    resetZoom();
    if (lbImg.complete && lbImg.naturalWidth) applyTransform();
  }

  function openLightbox(i) {
    open = true;
    goTo(i);
    lb.hidden = false;
    lb.classList.add("open");
    document.body.style.overflow = "hidden";
    lbClose.focus();
  }

  function closeLightbox() {
    if (!open) return;
    open = false;
    lb.classList.remove("open");
    lb.hidden = true;
    document.body.style.overflow = "";
    resetZoom();
    lbClose.blur();
  }

  btns.forEach((b, i) =>
    b.addEventListener("click", () => openLightbox(i))
  );

  lbClose?.addEventListener("click", closeLightbox);
  lbPrev?.addEventListener("click", () => goTo(index - 1));
  lbNext?.addEventListener("click", () => goTo(index + 1));

  zoomIn?.addEventListener("click", () => {
    animateZoom();
    zoomTo(scale * 1.5);
  });
  zoomOut?.addEventListener("click", () => {
    animateZoom();
    zoomTo(scale / 1.5);
  });
  zoomReset?.addEventListener("click", () => {
    animateZoom();
    resetZoom();
  });

  /* ---------- fullscreen "maximize" (desktop) ---------- */
  const lbFull = document.getElementById("lb-fullscreen");
  if (lbFull && lb && typeof lb.requestFullscreen === "function") {
    lbFull.addEventListener("click", () => {
      if (document.fullscreenElement) {
        document.exitFullscreen().catch(() => {});
      } else {
        lb.requestFullscreen().catch(() => {});
      }
    });
  } else if (lbFull) {
    lbFull.hidden = true; // Fullscreen API not available
  }
  document.addEventListener("fullscreenchange", () => {
    if (!lbFull) return;
    const fs = document.fullscreenElement === lb;
    lbFull.setAttribute("aria-pressed", String(fs));
    lbFull.setAttribute(
      "aria-label",
      fs ? "Exit fullscreen" : "Maximize viewer (fullscreen)"
    );
  });

  /* ---------- zoom interactions ---------- */
  stage.addEventListener(
    "wheel",
    (e) => {
      if (!open) return;
      e.preventDefault();
      const rect = stage.getBoundingClientRect();
      const factor = e.deltaY < 0 ? 1.25 : 1 / 1.25;
      zoomTo(scale * factor, e.clientX - rect.left, e.clientY - rect.top);
    },
    { passive: false }
  );

  let drag = null; // pan state (zoomed)
  let touch0 = null; // swipe state (fit)
  let suppressClick = false;

  stage.addEventListener("pointerdown", (e) => {
    if (e.target.closest(".lightbox-btn")) return;
    if (scale > 1.001) {
      drag = { x: e.clientX, y: e.clientY, tx, ty, moved: false };
      stage.setPointerCapture(e.pointerId);
      stage.style.cursor = "grabbing";
    } else {
      touch0 = { x: e.clientX, y: e.clientY, moved: false };
    }
  });

  stage.addEventListener("pointermove", (e) => {
    if (drag) {
      tx = drag.tx + (e.clientX - drag.x);
      ty = drag.ty + (e.clientY - drag.y);
      if (Math.abs(e.clientX - drag.x) + Math.abs(e.clientY - drag.y) > 6) {
        drag.moved = true;
      }
      clampPan();
      applyTransform();
    } else if (touch0) {
      if (Math.hypot(e.clientX - touch0.x, e.clientY - touch0.y) > 10) {
        touch0.moved = true;
      }
    }
  });

  const endDrag = (e) => {
    if (drag) {
      if (drag.moved) suppressClick = true;
      drag = null;
      stage.style.cursor = scale > 1.001 ? "grab" : "zoom-in";
    }
    if (touch0) {
      if (e.type !== "pointercancel" && e.clientX !== undefined) {
        const dx = e.clientX - touch0.x;
        const dy = e.clientY - touch0.y;
        if (touch0.moved && Math.abs(dx) > 48 && Math.abs(dx) > Math.abs(dy) * 1.2) {
          if (dx < 0) goTo(index + 1);
          else goTo(index - 1);
        }
      }
      touch0 = null;
    }
  };
  stage.addEventListener("pointerup", endDrag);
  stage.addEventListener("pointercancel", endDrag);

  stage.addEventListener("click", (e) => {
    if (suppressClick) {
      suppressClick = false;
      return;
    }
    if (e.target === lbImg && scale > 1.001) {
      animateZoom();
      resetZoom();
      return;
    }
    if (e.target === stage) closeLightbox(); // clicked the backdrop
  });

  stage.addEventListener("dblclick", (e) => {
    const rect = stage.getBoundingClientRect();
    if (scale > 1.001) {
      animateZoom();
      resetZoom();
    } else {
      animateZoom();
      zoomTo(3, e.clientX - rect.left, e.clientY - rect.top);
    }
  });

  lbImg.addEventListener("load", () => {
    if (open) applyTransform();
  });

  /* ---------- keyboard ---------- */
  document.addEventListener("keydown", (e) => {
    if (!open) return;
    if (e.key === "Escape") {
      if (document.fullscreenElement) {
        document.exitFullscreen().catch(() => {});
        return;
      }
      e.preventDefault();
      closeLightbox();
    } else if (e.key === "ArrowRight") {
      e.preventDefault();
      goTo(index + 1);
    } else if (e.key === "ArrowLeft") {
      e.preventDefault();
      goTo(index - 1);
    } else if (e.key === "+" || e.key === "=") {
      e.preventDefault();
      animateZoom();
      zoomTo(scale * 1.5);
    } else if (e.key === "-") {
      e.preventDefault();
      animateZoom();
      zoomTo(scale / 1.5);
    } else if (e.key === "0") {
      e.preventDefault();
      animateZoom();
      resetZoom();
    }
  });

  /* Keep Tab inside the lightbox while it is open */
  lb.addEventListener("keydown", (e) => {
    if (e.key !== "Tab" || !open) return;
    const els = Array.from(lb.querySelectorAll("button"));
    if (!els.length) return;
    const first = els[0];
    const last = els[els.length - 1];
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  });
})();
