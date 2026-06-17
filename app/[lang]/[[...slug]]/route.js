import { readFile } from "fs/promises";
import { NextResponse } from "next/server";
import {
  buildAlternateLinks,
  isRtlLanguage,
  localizedAbsoluteUrl,
  localizedPath,
  normalizeLanguage,
  normalizeSlug,
  outputsFilePath,
  resolveFileForSlug
} from "../../lib/multilingual-site";

const workspaceRoot = process.cwd();

function rewriteHrefValue(href, lang) {
  if (
    !href ||
    href.startsWith("http://") ||
    href.startsWith("https://") ||
    href.startsWith("mailto:") ||
    href.startsWith("tel:") ||
    href.startsWith("javascript:") ||
    href.startsWith("data:")
  ) {
    return href;
  }

  if (href === "#") {
    return href;
  }

  if (href.startsWith("/outputs/")) {
    return href;
  }

  if (href.startsWith("#")) {
    return href;
  }

  const [base, hash = ""] = href.split("#");
  const targetSlug = fileSlugMap[base];

  if (targetSlug !== undefined) {
    return `${localizedPath(lang, targetSlug)}${hash ? `#${hash}` : ""}`;
  }

  return href;
}

const fileSlugMap = {
  "appacs-homepage-long-preview.html": "",
  "appacs-blog.html": "blog",
  "appacs-blog-how-to-choose-usb-cable-manufacturer-bulk-orders.html":
    "blog/how-to-choose-usb-cable-manufacturer-bulk-orders",
  "appacs-blog-60w-vs-100w-3-in-1-usb-cable.html":
    "blog/60w-vs-100w-3-in-1-usb-cable",
  "appacs-blog-oem-odm-usb-cable-customization-guide.html":
    "blog/oem-odm-usb-cable-customization-guide",
  "appacs-contact.html": "contact",
  "appacs-faq.html": "faq",
  "appacs-inquiry-form.html": "inquiry",
  "appacs-usb-c-cables.html": "products/usb-c-cables",
  "appacs-lightning-cables.html": "products/lightning-cables",
  "appacs-adapter-cables.html": "products/adapter-cables",
  "appacs-multi-function-cables.html": "products/multi-function-cables",
  "appacs-product-detail-template.html": "products/u87-3in1",
  "appacs-product-u11-lightning-black.html": "products/u11-lightning-black",
  "appacs-product-u11-lightning-white.html": "products/u11-lightning-white",
  "appacs-product-u11-usb-c-white.html": "products/u11-usb-c-white",
  "appacs-product-u123-usb-c-cable.html": "products/u123-usb-c-cable",
  "appacs-product-u168-watch-charging-cable.html":
    "products/u168-watch-charging-cable",
  "appacs-product-u87-c-braided-usb-c-cable.html":
    "products/u87-c-braided-usb-c-cable",
  "appacs-product-u87-cw100w-watch-charging-cable.html":
    "products/u87-cw100w-watch-charging-cable",
  "appacs-product-u87c-cc-dual-usb-c-cable.html":
    "products/u87c-cc-dual-usb-c-cable",
  "appacs-product-u87d-led-display-cable.html":
    "products/u87d-led-display-cable",
  "appacs-product-u87m-magnetic-charging-cable.html":
    "products/u87m-magnetic-charging-cable",
  "appacs-product-u87t-cc-coiled-usb-c-cable.html":
    "products/u87t-cc-coiled-usb-c-cable",
  "appacs-product-u92-right-angle-usb-c-cable.html":
    "products/u92-right-angle-usb-c-cable",
  "appacs-product-u93-usb-c-audio-adapter-cable.html":
    "products/u93-usb-c-audio-adapter-cable"
};

function rewriteHtml(html, lang, slug) {
  const absoluteUrl = localizedAbsoluteUrl(lang, slug);
  const alternateLinks = buildAlternateLinks(lang, slug);
  const dir = isRtlLanguage(lang) ? "rtl" : "ltr";

  let output = html;

  output = output.replace(
    /<html\b[^>]*lang="[^"]*"[^>]*>/i,
    `<html lang="${lang}" dir="${dir}">`
  );

  if (!/<html\b[^>]*lang=/i.test(output)) {
    output = output.replace(/<html[^>]*>/i, `<html lang="${lang}" dir="${dir}">`);
  }

  output = output.replace(
    /<link\s+rel="canonical"\s+href="[^"]*"\s*\/?>/i,
    `<link rel="canonical" href="${absoluteUrl}" />`
  );

  if (!/<link\s+rel="canonical"/i.test(output)) {
    output = output.replace(
      /<\/head>/i,
      `  <link rel="canonical" href="${absoluteUrl}" />\n</head>`
    );
  }

  output = output.replace(
    /<meta\s+property="og:url"\s+content="[^"]*"\s*\/?>/i,
    `<meta property="og:url" content="${absoluteUrl}" />`
  );

  output = output.replace(
    /<\/head>/i,
    `  ${alternateLinks}\n</head>`
  );

  output = output.replace(
    /https:\/\/www\.mocable\.com\/appacs-next-home\/public\/assets\/company-logo\.jpg/g,
    "https://www.mocable.com/outputs/assets/company-logo.jpg"
  );

  output = output.replace(
    /\.\.\/appacs-next-home\/public\/assets\/company-logo\.jpg/g,
    "/outputs/assets/company-logo.jpg"
  );

  output = output.replace(
    /((?:src|href|poster|data-src|data-large)=["'])assets\//g,
    `$1/outputs/assets/`
  );

  output = output.replace(
    /url\((["']?)assets\//g,
    "url($1/outputs/assets/"
  );

  output = output.replace(
    /<a class="brand" href="#">/i,
    `<a class="brand" href="${localizedPath(lang)}">`
  );

  output = output.replace(/href=(["'])([^"']+)\1/g, (match, quote, href) => {
    const rewritten = rewriteHrefValue(href, lang);
    return `href=${quote}${rewritten}${quote}`;
  });

  return output;
}

export async function GET(_request, { params }) {
  const lang = normalizeLanguage(params.lang);
  const slug = normalizeSlug(params.slug);
  const fileName = resolveFileForSlug(slug === "faqs" ? "faq" : slug);

  if (!fileName) {
    return new NextResponse("Page not found", { status: 404 });
  }

  const filePath = outputsFilePath(workspaceRoot, fileName);

  try {
    const html = await readFile(filePath, "utf8");
    const localizedHtml = rewriteHtml(html, lang, slug);

    return new NextResponse(localizedHtml, {
      headers: {
        "Content-Type": "text/html; charset=utf-8"
      }
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unable to load localized page.";

    return new NextResponse(message, { status: 500 });
  }
}
