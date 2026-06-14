import { cp, mkdir, rm } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const source = path.join(root, "outputs");
const target = path.join(root, "public", "outputs");

if (!existsSync(source)) {
  throw new Error(`Missing static outputs directory: ${source}`);
}

await rm(target, { recursive: true, force: true });
await mkdir(path.dirname(target), { recursive: true });
await cp(source, target, { recursive: true });

console.log(`Synced ${source} -> ${target}`);
