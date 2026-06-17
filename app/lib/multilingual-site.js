import path from "path";

export const SITE_ORIGIN = "https://www.mocable.com";

export const SUPPORTED_LANGUAGES = ["en", "es", "ru", "ar", "fr", "pt"];
export const RTL_LANGUAGES = new Set(["ar"]);

export const SLUG_TO_FILE = {
  "": "appacs-homepage-long-preview.html",
  "blog": "appacs-blog.html",
  "blog/how-to-choose-usb-cable-manufacturer-bulk-orders":
    "appacs-blog-how-to-choose-usb-cable-manufacturer-bulk-orders.html",
  "blog/60w-vs-100w-3-in-1-usb-cable":
    "appacs-blog-60w-vs-100w-3-in-1-usb-cable.html",
  "blog/oem-odm-usb-cable-customization-guide":
    "appacs-blog-oem-odm-usb-cable-customization-guide.html",
  "contact": "appacs-contact.html",
  "faq": "appacs-faq.html",
  "faqs": "appacs-faq.html",
  "inquiry": "appacs-inquiry-form.html",
  "products/usb-c-cables": "appacs-usb-c-cables.html",
  "products/lightning-cables": "appacs-lightning-cables.html",
  "products/adapter-cables": "appacs-adapter-cables.html",
  "products/multi-function-cables": "appacs-multi-function-cables.html",
  "products/u87-3in1": "appacs-product-detail-template.html",
  "products/u11-lightning-black": "appacs-product-u11-lightning-black.html",
  "products/u11-lightning-white": "appacs-product-u11-lightning-white.html",
  "products/u11-usb-c-white": "appacs-product-u11-usb-c-white.html",
  "products/u123-usb-c-cable": "appacs-product-u123-usb-c-cable.html",
  "products/u168-watch-charging-cable":
    "appacs-product-u168-watch-charging-cable.html",
  "products/u87-c-braided-usb-c-cable":
    "appacs-product-u87-c-braided-usb-c-cable.html",
  "products/u87-cw100w-watch-charging-cable":
    "appacs-product-u87-cw100w-watch-charging-cable.html",
  "products/u87c-cc-dual-usb-c-cable":
    "appacs-product-u87c-cc-dual-usb-c-cable.html",
  "products/u87d-led-display-cable":
    "appacs-product-u87d-led-display-cable.html",
  "products/u87m-magnetic-charging-cable":
    "appacs-product-u87m-magnetic-charging-cable.html",
  "products/u87t-cc-coiled-usb-c-cable":
    "appacs-product-u87t-cc-coiled-usb-c-cable.html",
  "products/u92-right-angle-usb-c-cable":
    "appacs-product-u92-right-angle-usb-c-cable.html",
  "products/u93-usb-c-audio-adapter-cable":
    "appacs-product-u93-usb-c-audio-adapter-cable.html"
};

export const FILE_TO_SLUG = Object.fromEntries(
  Object.entries(SLUG_TO_FILE).map(([slug, file]) => [file, slug])
);

export function normalizeLanguage(lang) {
  return SUPPORTED_LANGUAGES.includes(lang) ? lang : "en";
}

export function normalizeSlug(slugParts = []) {
  return slugParts.filter(Boolean).join("/");
}

export function localizedPath(lang, slug = "") {
  return slug ? `/${lang}/${slug}` : `/${lang}/`;
}

export function localizedAbsoluteUrl(lang, slug = "") {
  return `${SITE_ORIGIN}${localizedPath(lang, slug)}`;
}

export function resolveFileForSlug(slug) {
  return SLUG_TO_FILE[slug] ?? null;
}

export function resolveSlugForFile(fileName) {
  return FILE_TO_SLUG[fileName] ?? "";
}

export function isRtlLanguage(lang) {
  return RTL_LANGUAGES.has(lang);
}

export function buildAlternateLinks(lang, slug) {
  const links = SUPPORTED_LANGUAGES.map((item) => {
    return `<link rel="alternate" hreflang="${item}" href="${localizedAbsoluteUrl(item, slug)}" />`;
  });

  links.push(
    `<link rel="alternate" hreflang="x-default" href="${localizedAbsoluteUrl("en", slug)}" />`
  );

  return links.join("\n  ");
}

export function outputsFilePath(rootDir, fileName) {
  return path.join(rootDir, "public", "outputs", fileName);
}
