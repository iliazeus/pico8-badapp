#!/usr/bin/env node

import * as fs from "node:fs/promises";
import { stdout } from "node:process";
import { parseArgs } from "node:util";

const args = parseArgs({
  strict: true,
  options: {
    maxDepth: { type: "string", default: "7" },
    frameStep: { type: "string" },
    startFrame: { type: "string" },
    endFrame: { type: "string" },
  },
});

const maxDepth = Number(args.values.maxDepth);
const startFrame = Number(args.values.startFrame);
const endFrame = Number(args.values.endFrame);
const frameStep = Number(args.values.frameStep);

for (
  let frameIndex = startFrame;
  frameIndex <= endFrame;
  frameIndex += frameStep
) {
  let i = Math.round(frameIndex).toString().padStart(3, "0");
  let framePath = `./data/frames/bad_apple_${i}.png.bin`;
  await encodeFrame(framePath, maxDepth, stdout);
}

async function encodeFrame(inPath, maxDepth, stream) {
  let input = await fs.readFile(inPath);

  let trees = [];
  for (let v of input) {
    for (let p = 7; p >= 0; p--) trees.push({ v: (v & (1 << p)) >> p });
  }

  for (let n = 128; n > 1; n /= 2) {
    let newTrees = [];
    for (let y = 0; y < n / 2; y++) {
      for (let x = 0; x < n / 2; x++) {
        let c = [
          trees[y * 2 * n + x * 2],
          trees[y * 2 * n + (x * 2 + 1)],
          trees[(y * 2 + 1) * n + x * 2],
          trees[(y * 2 + 1) * n + (x * 2 + 1)],
        ];
        let v = c.map((x) => x.v).reduce((a, b) => a + b) / 4;
        if (c.every((x) => x.v === 0)) c = null;
        else if (c.every((x) => x.v === 1)) c = null;
        newTrees.push({ v, c });
      }
    }
    trees = newTrees;
  }

  function serialize(tree, depth = 0) {
    if (depth >= maxDepth || !tree.c) {
      let c = Math.round(tree.v);
      stream.write(c ? "W" : "B");
    } else {
      stream.write("T");
      for (let c of tree.c) serialize(c, depth + 1);
    }
  }

  serialize(trees[0]);
}
