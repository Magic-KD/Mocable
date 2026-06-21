import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const port = Number(process.env.PORT || 3101);
const baseUrl = `http://127.0.0.1:${port}`;
const nextBin = fileURLToPath(
  new URL("../node_modules/next/dist/bin/next", import.meta.url)
);

const checks = [
  ["/", "OEM/ODM Usb Cables manufacturer"],
  ["/blog", "USB Cable Buying Guides"],
  ["/faq", "USB Cable Factory FAQ for Global Buyers"],
  ["/contact", "Contact APPACS for USB Cable Projects"],
  ["/usb-c-cables", "USB-C Cables for Wholesale"],
  ["/lightning-cables", "Lightning Cables for Wholesale"],
  ["/multi-function-cables", "Multi-function Cables for Wholesale"],
  ["/adapter-cables", "Adapter Cables for Wholesale"]
];

const server = spawn(
  process.execPath,
  [nextBin, "start", "-p", String(port)],
  {
    cwd: process.cwd(),
    env: { ...process.env, NODE_ENV: "production" },
    stdio: ["ignore", "pipe", "pipe"]
  }
);

let serverOutput = "";
server.stdout.on("data", (chunk) => {
  serverOutput += chunk.toString();
});
server.stderr.on("data", (chunk) => {
  serverOutput += chunk.toString();
});

async function waitForServer() {
  for (let attempt = 0; attempt < 50; attempt += 1) {
    try {
      const response = await fetch(`${baseUrl}/`, { redirect: "manual" });
      if (response.status >= 200 && response.status < 400) {
        return;
      }
    } catch {
      // The production server may still be starting.
    }
    await new Promise((resolve) => setTimeout(resolve, 200));
  }

  throw new Error(`Production server did not start.\n${serverOutput}`);
}

function extractAssetPaths(html) {
  const paths = new Set();
  const pattern =
    /(?:src|poster|data-src|data-large)=["'](\/outputs\/assets\/[^"'?#]+)["']/g;

  for (const match of html.matchAll(pattern)) {
    paths.add(match[1]);
  }

  return [...paths];
}

async function verifyPage(path, marker) {
  const response = await fetch(`${baseUrl}${path}`);
  const html = await response.text();

  if (!response.ok) {
    throw new Error(`${path} returned HTTP ${response.status}`);
  }

  if (!html.includes(marker)) {
    throw new Error(`${path} did not render the expected page marker: ${marker}`);
  }

  for (const assetPath of extractAssetPaths(html)) {
    const assetResponse = await fetch(`${baseUrl}${assetPath}`, {
      method: "HEAD"
    });

    if (!assetResponse.ok) {
      throw new Error(
        `${path} references missing asset ${assetPath} (HTTP ${assetResponse.status})`
      );
    }
  }

  return html;
}

try {
  await waitForServer();

  let homepage = "";
  for (const [path, marker] of checks) {
    const html = await verifyPage(path, marker);
    if (path === "/") {
      homepage = html;
    }
    console.log(`PASS ${path}`);
  }

  if (!homepage.includes("/en/contact#quote")) {
    throw new Error("Homepage Get a Quote link does not target /en/contact#quote");
  }

  const contactResponse = await fetch(`${baseUrl}/contact`);
  const contactHtml = await contactResponse.text();
  if (!contactHtml.includes('id="quote"')) {
    throw new Error("Contact page is missing the #quote anchor");
  }

  console.log("PASS Get a Quote -> /en/contact#quote");
  console.log("Production verification passed.");
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
} finally {
  server.kill();
}
