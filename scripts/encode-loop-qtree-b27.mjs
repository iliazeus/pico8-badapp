#!/usr/bin/env node

import * as fs from "node:fs/promises";
import { parseArgs } from "node:util";

const args = parseArgs({
  strict: true,
  options: {
    template: { type: "string" },
    output: { type: "string" },
    maxDepth: { type: "string", default: "7" },
    startFrame: { type: "string", default: "1" },
    endFrame: { type: "string" },
    frameStep: { type: "string" },
    loopStartFrame: { type: "string" },
  },
});

const maxDepth = Number(args.values.maxDepth);
const startFrame = Number(args.values.startFrame);
const endFrame = Number(args.values.endFrame);
const frameStep = Number(args.values.frameStep);
const loopStartFrame = Math.floor(
  (Number(args.values.loopStartFrame) - startFrame) / frameStep
) || 1;

let template = await fs.open(args.values.template, "r");
let output = await fs.open(args.values.output, "w");

try {
  for await (const line of template.readLines()) {
    if (line.trim() !== "--[[frames]]--") {
      await output.write(line + "\n");
      continue;
    }

    await output.write(`framestep = ${frameStep}\n`);
    await output.write(`loopstartframe = ${loopStartFrame}\n`);

    await output.write("frames = {\n");

    try {
      for (let i = startFrame; i <= endFrame; i += frameStep) {
        let frameIndex = Math.round(i).toString().padStart(3, "0");
        let frame = await encodeFrame(
          `./data/frames/bad_apple_${frameIndex}.png.bin`,
          maxDepth
        );
        await output.write('\t"');
        await output.write(frame);
        await output.write('",\n');
      }
    } finally {
      await output.write("}\n");
    }
  }
} finally {
  await template.close();
  await output.close();
}

async function encodeFrame(inPath, maxDepth) {
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

  let output = [];
  let outc = 0;
  let outp = 0;

  function pushChar(c) {
    if (0 <= c && c <= 25) {
      output.push(97 + c);
    } else if (26 <= c && c <= 26) {
      output.push(24 + c);
    }
  }

  function pushTrit(c) {
    outc = outc * 3 + (c % 3);
    outp += 1;
    if (outp === 2) {
      pushChar(outc);
      outc = 0;
      outp = 0;
    }
  }

  function serialize(tree, depth = 0) {
    if (!tree.c || depth >= maxDepth) {
      pushTrit(Math.round(tree.v));
    } else {
      pushTrit(2);
      for (let c of tree.c) serialize(c, depth + 1);
    }
  }

  serialize(trees[0]);
  if (outp !== 0) pushChar(outc * 3);

  return String.fromCharCode(...output);
}
