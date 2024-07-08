#!/usr/bin/env node

import * as fs from "node:fs/promises";
import { parseArgs } from "node:util";

const args = parseArgs({
  strict: true,
  options: {
    template: { type: "string" },
    output: { type: "string" },
    maxDepth: { type: "string", default: "7" },
    startFrame: { type: "string" },
    endFrame: { type: "string" },
    frameStep: { type: "string" },
    nextcart: { type: "string" },
  },
});

const maxDepth = Number(args.values.maxDepth);
const startFrame = Number(args.values.startFrame);
const endFrame = Number(args.values.endFrame);
const frameStep = Number(args.values.frameStep);
const nextcart = args.values.nextcart;

let template = await fs.open(args.values.template, "r");
let output = await fs.open(args.values.output, "w");

try {
  for await (const line of template.readLines()) {
    if (line.trim() !== "--[[data]]--") {
      await output.write(line + "\n");
      continue;
    }

    await output.write(`nextcart = "${nextcart}"\n`);
    await output.write('data = "');

    try {
      for (let i = startFrame; i <= endFrame; i += frameStep) {
        let frameIndex = Math.round(i).toString().padStart(3, "0");
        let frame = await encodeFrame(
          `./data/frames/bad_apple_${frameIndex}.png.bin`,
          maxDepth
        );
        await output.write(frame);
      }
    } finally {
      await output.write('"\n');
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
    } else if (26 <= c && c <= 32) {
      output.push(24 + c);
    }
  }

  function pushBit(c) {
    outc = (outc << 1) | (c & 1);
    outp += 1;
    if (outp === 5) {
      pushChar(outc);
      outc = 0;
      outp = 0;
    }
  }

  let cc = 1;
  function serialize(tree, depth = 0) {
    if (depth >= maxDepth) {
      let c = Math.round(tree.v);
      pushBit(c);
      cc = c;
    } else if (!tree.c) {
      let c = Math.round(tree.v);
      if (c === cc) {
        pushBit(0);
      } else {
        pushBit(1);
        pushBit(0);
        cc = c;
      }
    } else {
      pushBit(1);
      pushBit(1);
      for (let c of tree.c) serialize(c, depth + 1);
    }
  }

  serialize(trees[0]);
  if (outp !== 0) pushChar(outc << (5 - outp));

  return String.fromCharCode(...output);
}
