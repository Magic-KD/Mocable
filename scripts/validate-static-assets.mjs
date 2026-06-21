import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();
const outputsDir = path.join(root, "outputs");
const assetsDir = path.join(outputsDir, "assets");

async function walk(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await walk(entryPath)));
    } else {
      files.push(entryPath);
    }
  }

  return files;
}

function toPosix(value) {
  return value.split(path.sep).join("/");
}

const assetFiles = await walk(assetsDir);
const exactAssetPaths = new Set(
  assetFiles.map((file) => toPosix(path.relative(assetsDir, file)))
);
const caseInsensitiveAssetPaths = new Map(
  [...exactAssetPaths].map((file) => [file.toLowerCase(), file])
);

const htmlFiles = (await walk(outputsDir)).filter((file) =>
  file.toLowerCase().endsWith(".html")
);
const failures = [];
const assetPattern =
  /(?:src|poster|data-src|data-large)=["']([^"'?#]+)["']|url\(["']?([^)"'?#]+)/g;

for (const htmlFile of htmlFiles) {
  const html = await readFile(htmlFile, "utf8");

  for (const match of html.matchAll(assetPattern)) {
    const reference = match[1] || match[2];
    let assetPath = null;

    if (reference.startsWith("assets/")) {
      assetPath = reference.slice("assets/".length);
    } else if (reference.startsWith("/outputs/assets/")) {
      assetPath = reference.slice("/outputs/assets/".length);
    } else if (reference.startsWith("../appacs-next-home/public/assets/")) {
      assetPath = reference.slice("../appacs-next-home/public/assets/".length);
    }

    if (!assetPath) {
      continue;
    }

    if (exactAssetPaths.has(assetPath)) {
      continue;
    }

    const actualCase = caseInsensitiveAssetPaths.get(assetPath.toLowerCase());
    const sourceName = toPosix(path.relative(root, htmlFile));

    if (actualCase) {
      failures.push(
        `${sourceName}: "${assetPath}" has incorrect case; actual file is "${actualCase}"`
      );
    } else {
      failures.push(`${sourceName}: missing asset "${assetPath}"`);
    }
  }
}

if (failures.length > 0) {
  throw new Error(`Static asset validation failed:\n${failures.join("\n")}`);
}

console.log(
  `Validated ${htmlFiles.length} HTML files against ${assetFiles.length} deployable assets.`
);
