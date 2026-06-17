$files = Get-ChildItem -Path "outputs" -Filter "*.html"

$langCss = @'
    .lang-switcher {
      position: relative;
      flex-shrink: 0;
      z-index: 40;
    }
    .lang-toggle {
      min-width: 52px;
      height: 42px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 0 14px;
      border: 1px solid rgba(255,255,255,.16);
      border-radius: 999px;
      background: rgba(255,255,255,.05);
      color: rgba(255,255,255,.92);
      font: inherit;
      font-size: 13px;
      font-weight: 700;
      cursor: pointer;
      transition: background .2s ease, color .2s ease, border-color .2s ease, transform .2s ease, box-shadow .2s ease;
      backdrop-filter: blur(10px);
    }
    .lang-toggle:hover,
    .lang-switcher.open .lang-toggle {
      background: rgba(255,255,255,.1);
      color: #fff;
      border-color: rgba(48,228,127,.42);
      transform: translateY(-1px);
      box-shadow: 0 14px 32px rgba(0,0,0,.18);
    }
    .lang-globe {
      font-size: 15px;
      line-height: 1;
    }
    .lang-current {
      font-size: 12px;
      letter-spacing: .08em;
      text-transform: uppercase;
    }
    .lang-menu {
      position: absolute;
      top: calc(100% + 12px);
      right: 0;
      min-width: 214px;
      display: grid;
      gap: 6px;
      padding: 12px;
      border: 1px solid rgba(255,255,255,.14);
      border-radius: 18px;
      background: rgba(8,16,13,.94);
      box-shadow: 0 24px 58px rgba(0,0,0,.32);
      backdrop-filter: blur(20px) saturate(140%);
      opacity: 0;
      visibility: hidden;
      transform: translateY(10px);
      pointer-events: none;
      transition: opacity .18s ease, transform .18s ease, visibility .18s ease;
    }
    .lang-menu::before {
      content: "";
      position: absolute;
      top: -18px;
      right: 0;
      width: 100%;
      height: 18px;
    }
    .lang-switcher.open .lang-menu {
      opacity: 1;
      visibility: visible;
      transform: translateY(0);
      pointer-events: auto;
    }
    .lang-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 14px;
      padding: 11px 13px;
      border-radius: 14px;
      color: rgba(255,255,255,.86);
      transition: background .18s ease, color .18s ease, transform .18s ease;
    }
    .lang-item small {
      color: rgba(255,255,255,.44);
      font-size: 11px;
      font-weight: 700;
      letter-spacing: .08em;
      text-transform: uppercase;
    }
    .lang-item:hover {
      background: rgba(255,255,255,.08);
      color: #fff;
      transform: translateX(2px);
    }
    .lang-item.is-active {
      background: rgba(25,184,90,.18);
      color: #fff;
      box-shadow: inset 0 0 0 1px rgba(48,228,127,.28);
    }
    .lang-item.is-active small {
      color: var(--green-2, #30e47f);
    }
    html[dir="rtl"] .lang-menu {
      right: auto;
      left: 0;
    }
    html[dir="rtl"] .lang-item:hover {
      transform: translateX(-2px);
    }
    @media (max-width: 900px) {
      .lang-toggle {
        width: 42px;
        min-width: 42px;
        padding: 0;
      }
      .lang-current {
        display: none;
      }
      .lang-menu {
        min-width: min(220px, calc(100vw - 32px));
      }
    }
'@

$langHtml = @'
    <div class="lang-switcher" data-language-switcher>
      <button class="lang-toggle" type="button" aria-haspopup="true" aria-expanded="false" aria-label="Change language">
        <span class="lang-globe" aria-hidden="true">&#127760;</span>
        <span class="lang-current">EN</span>
      </button>
      <div class="lang-menu" role="menu" aria-label="Language selector">
        <a class="lang-item" data-lang="en" href="/en/" role="menuitem"><span>English</span><small>EN</small></a>
        <a class="lang-item" data-lang="es" href="/es/" role="menuitem"><span>Espa&ntilde;ol</span><small>ES</small></a>
        <a class="lang-item" data-lang="ru" href="/ru/" role="menuitem"><span>&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;</span><small>RU</small></a>
        <a class="lang-item" data-lang="ar" href="/ar/" role="menuitem"><span>&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;</span><small>AR</small></a>
        <a class="lang-item" data-lang="fr" href="/fr/" role="menuitem"><span>Fran&ccedil;ais</span><small>FR</small></a>
        <a class="lang-item" data-lang="pt" href="/pt/" role="menuitem"><span>Portugu&ecirc;s</span><small>PT</small></a>
      </div>
    </div>
'@

$langScript = @'
<script>
(() => {
  const LANGS = ["en", "es", "ru", "ar", "fr", "pt"];
  const LABELS = {
    en: "EN",
    es: "ES",
    ru: "RU",
    ar: "AR",
    fr: "FR",
    pt: "PT"
  };

  function detectCurrentLang() {
    const current = new URL(window.location.href);
    const queryLang = current.searchParams.get("lang");
    if (queryLang && LANGS.includes(queryLang)) return queryLang;

    const segments = current.pathname.split("/").filter(Boolean);
    if (!segments.length) return "en";

    const first = segments[0].toLowerCase();
    const last = segments[segments.length - 1].toLowerCase();

    if (LANGS.includes(first)) return first;
    if (LANGS.includes(last)) return last;

    return "en";
  }

  function buildLocalizedUrl(targetLang) {
    const current = new URL(window.location.href);
    const protocol = current.protocol;
    const path = current.pathname;

    if (protocol === "file:" || /\.html$/i.test(path)) {
      current.searchParams.set("lang", targetLang);
      return current.toString();
    }

    const segments = path.split("/").filter(Boolean);
    if (!segments.length) {
      return `${current.origin}/${targetLang}/${current.search}${current.hash}`;
    }

    const first = segments[0] ? segments[0].toLowerCase() : "";
    const lastIndex = segments.length - 1;
    const last = segments[lastIndex] ? segments[lastIndex].toLowerCase() : "";

    if (LANGS.includes(first)) {
      segments[0] = targetLang;
    } else if (LANGS.includes(last)) {
      segments[lastIndex] = targetLang;
    } else {
      segments.push(targetLang);
    }

    return `${current.origin}/${segments.join("/")}${current.search}${current.hash}`;
  }

  const currentLang = detectCurrentLang();
  document.documentElement.lang = currentLang;
  document.documentElement.dir = currentLang === "ar" ? "rtl" : "ltr";

  document.querySelectorAll("[data-language-switcher]").forEach((switcher) => {
    const button = switcher.querySelector(".lang-toggle");
    const currentLabel = switcher.querySelector(".lang-current");
    const links = switcher.querySelectorAll(".lang-item");

    if (currentLabel) currentLabel.textContent = LABELS[currentLang] || "EN";

    links.forEach((link) => {
      const lang = link.getAttribute("data-lang");
      if (!lang) return;
      link.href = buildLocalizedUrl(lang);
      if (lang === currentLang) {
        link.classList.add("is-active");
        link.setAttribute("aria-current", "true");
      }
      link.addEventListener("click", () => {
        switcher.classList.remove("open");
        button.setAttribute("aria-expanded", "false");
      });
    });

    button.addEventListener("click", () => {
      const open = switcher.classList.toggle("open");
      button.setAttribute("aria-expanded", open ? "true" : "false");
    });

    document.addEventListener("click", (event) => {
      if (!switcher.contains(event.target)) {
        switcher.classList.remove("open");
        button.setAttribute("aria-expanded", "false");
      }
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        switcher.classList.remove("open");
        button.setAttribute("aria-expanded", "false");
      }
    });
  });
})();
</script>
'@

foreach ($file in $files) {
  $content = Get-Content -Path $file.FullName -Raw

  if ($content -match 'data-language-switcher') {
    continue
  }

  $content = [regex]::Replace(
    $content,
    '(?m)^(\s*)\.quote\s*\{',
    $langCss + "`r`n" + '${1}.quote {',
    1
  )

  $content = [regex]::Replace(
    $content,
    '<a class="quote"',
    $langHtml + "`r`n    <a class=""quote""",
    1
  )

  $content = [regex]::Replace(
    $content,
    '</body>',
    $langScript + "`r`n</body>",
    1
  )

  Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
