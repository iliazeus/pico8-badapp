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

class BitStream {
  constructor() {
    this.output = [];
    this.outc = 0;
    this.outp = 0;
  }

  pushBit(c) {
    this.outc = (this.outc << 1) | (c & 1);
    this.outp += 1;
    if (this.outp === 8) {
      this.output.push(this.outc);
      this.outp = 0;
      this.outc = 0;
    }
  }

  flushByte() {
    while (this.outp !== 0) this.pushBit(0);
  }

  toBuffer() {
    return Buffer.from(this.output);
  }
}

let stream = new BitStream();

for (
  let frameIndex = startFrame;
  frameIndex <= endFrame;
  frameIndex += frameStep
) {
  let i = Math.round(frameIndex).toString().padStart(3, "0");
  let framePath = `./data/frames/bad_apple_${i}.png.bin`;
  await encodeFrame(framePath, maxDepth, stream);
}

stream.flushByte();
stdout.write(stream.toBuffer());

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

  let ch = [2, 0, 1];
  function serialize(tree, depth = 0) {
    let c = Math.round(tree.v);
    if (depth >= maxDepth) {
      stream.pushBit(c);
      return;
    }

    if (tree.c) c = 2;

    let i = ch.indexOf(c);
    if (i === 0) {
      stream.pushBit(0);
    } else {
      stream.pushBit(1);
      if (i === 1) {
        stream.pushBit(0);
        ch[1] = ch[0];
        ch[0] = c;
      } else {
        stream.pushBit(1);
        ch[2] = ch[1];
        ch[1] = ch[0];
        ch[0] = c;
      }
    }

    if (c === 2) {
      for (let c of tree.c) serialize(c, depth + 1);
    }
  }

  serialize(trees[0]);
}