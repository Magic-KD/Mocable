from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
OUTPUTS = ROOT / "outputs"
PUBLIC = ROOT / "public"

ASSET_REPLACEMENTS = {
    "assets/advantages/advantage-oem-odm.png": "assets/advantages/advantage-oem-odm.jpg",
    "assets/advantages/advantage-sample-support.png": "assets/advantages/advantage-sample-support.jpg",
    "assets/advantages/advantage-quality-control.png": "assets/advantages/advantage-quality-control.jpg",
    "assets/advantages/advantage-global-response.png": "assets/advantages/advantage-global-response.jpg",
    "assets/factory-photo-appacs.png": "assets/factory-photo-appacs.jpg",
    "assets/adapter-category/u87-cc-adapter.png": "assets/adapter-category/u87-cc-adapter.jpg",
    "assets/usb-c-category/u87-cc-adapter.png": "assets/usb-c-category/u87-cc-adapter.jpg",
}

HOME_META = """  <meta name="description" content="Mocable by APPACS is an OEM/ODM USB cable manufacturer supplying USB-C cables, Lightning cables, adapter cables and multi-function charging cables for global B2B buyers." />
  <meta name="robots" content="index, follow" />
  <link rel="canonical" href="https://www.mocable.com/" />
  <meta property="og:type" content="website" />
  <meta property="og:title" content="Mocable | OEM/ODM USB Cable Manufacturer" />
  <meta property="og:description" content="Factory-direct USB cable manufacturing, OEM/ODM packaging, sample support and QC inspection for global importers and private label buyers." />
  <meta property="og:url" content="https://www.mocable.com/" />
  <meta property="og:image" content="https://www.mocable.com/outputs/assets/factory-photo-appacs.jpg" />
  <meta name="twitter:card" content="summary_large_image" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Mocable",
    "alternateName": "APPACS",
    "url": "https://www.mocable.com/",
    "logo": "https://www.mocable.com/appacs-next-home/public/assets/company-logo.jpg",
    "contactPoint": {
      "@type": "ContactPoint",
      "telephone": "+86-159-2002-6822",
      "contactType": "sales",
      "availableLanguage": ["English", "Chinese"]
    },
    "sameAs": []
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Mocable",
    "url": "https://www.mocable.com/",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://www.mocable.com/outputs/appacs-blog.html?q={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  }
  </script>"""


def add_image_attrs(match: re.Match[str]) -> str:
    tag = match.group(0)
    if "decoding=" not in tag:
        tag = tag[:-2] + ' decoding="async" />'
    if "loading=" not in tag and "company-logo" not in tag:
        tag = tag[:-2] + ' loading="lazy" />'
    if "company-logo" in tag and "fetchpriority=" not in tag:
        tag = tag[:-2] + ' fetchpriority="high" />'
    return tag


def optimize_html(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    original = text

    for old, new in ASSET_REPLACEMENTS.items():
        text = text.replace(old, new)

    text = re.sub(r"<img\b[^>]*?/>", add_image_attrs, text)
    text = re.sub(r"<video class=\"hero-video\" autoplay muted loop playsinline(?: preload=\"[^\"]+\")?", '<video class="hero-video" autoplay muted loop playsinline preload="none"', text)

    if path.name == "appacs-homepage-long-preview.html":
        text = re.sub(r"<title>.*?</title>", "<title>Mocable | OEM/ODM USB Cable Manufacturer for Global Buyers</title>", text, count=1)
        if '<meta name="description"' not in text:
            text = text.replace('  <title>Mocable | OEM/ODM USB Cable Manufacturer for Global Buyers</title>\n', '  <title>Mocable | OEM/ODM USB Cable Manufacturer for Global Buyers</title>\n' + HOME_META + "\n")
        if "content-visibility:auto" not in text:
            text = text.replace("    section { padding: 78px 0; }\n", "    section { padding: 78px 0; }\n    main > section:not(.hero) { content-visibility: auto; contain-intrinsic-size: 900px; }\n")

    if text != original:
        path.write_text(text, encoding="utf-8", newline="\n")


for html in OUTPUTS.glob("*.html"):
    optimize_html(html)

robots = """User-agent: *
Allow: /
Sitemap: https://www.mocable.com/sitemap.xml
"""

pages = [
    "",
    "outputs/appacs-usb-c-cables.html",
    "outputs/appacs-lightning-cables.html",
    "outputs/appacs-multi-function-cables.html",
    "outputs/appacs-adapter-cables.html",
    "outputs/appacs-blog.html",
    "outputs/appacs-contact.html",
    "outputs/appacs-inquiry-form.html",
    "outputs/appacs-product-detail-template.html",
    "outputs/appacs-product-u87d-led-display-cable.html",
    "outputs/appacs-product-u87-cw100w-watch-charging-cable.html",
    "outputs/appacs-product-u87t-cc-coiled-usb-c-cable.html",
]

sitemap_items = "\n".join(
    f"  <url><loc>https://www.mocable.com/{page}</loc><changefreq>weekly</changefreq><priority>{'1.0' if page == '' else '0.8'}</priority></url>"
    for page in pages
)
sitemap = f"""<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
{sitemap_items}
</urlset>
"""

(PUBLIC / "robots.txt").write_text(robots, encoding="utf-8", newline="\n")
(PUBLIC / "sitemap.xml").write_text(sitemap, encoding="utf-8", newline="\n")
(OUTPUTS / "robots.txt").write_text(robots, encoding="utf-8", newline="\n")
(OUTPUTS / "sitemap.xml").write_text(sitemap, encoding="utf-8", newline="\n")

print("Static SEO optimization complete.")
