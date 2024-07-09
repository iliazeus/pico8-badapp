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
  },
});

const maxDepth = Number(args.values.maxDepth);
const startFrame = Number(args.values.startFrame);
const endFrame = Number(args.values.endFrame);
const frameStep = Number(args.values.frameStep);

let template = await fs.open(args.values.template, "r");
let output = await fs.open(args.values.output, "w");

class BitStreamBase32 {
  constructor() {
    this.output = [];
    this.outc = 0;
    this.outp = 0;
  }

  pushBit(c) {
    this.outc = (this.outc << 1) | (c & 1);
    this.outp += 1;
    if (this.outp === 5) {
      if (0 <= this.outc && this.outc <= 25) {
        this.output.push(97 + this.outc);
      } else if (26 <= this.outc && this.outc <= 32) {
        this.output.push(24 + this.outc);
      }
      this.outc = 0;
      this.outp = 0;
    }
  }

  flush() {
    while (this.outp !== 0) this.pushBit(0);
  }

  toString() {
    return String.fromCharCode(...this.output);
  }
}

let stream = new BitStreamBase32();

try {
  for await (const line of template.readLines()) {
    if (line.trim() !== "--[[data]]--") {
      await output.write(line + "\n");
      continue;
    }

    await output.write('data = "');

    try {
      for (let i = startFrame; i <= endFrame; i += frameStep) {
        let frameIndex = Math.round(i).toString().padStart(3, "0");
        await encodeFrame(
          `./data/frames/bad_apple_${frameIndex}.png.bin`,
          maxDepth,
          stream
        );
      }
    } finally {
      stream.flush();
      await output.write(stream.toString());
      await output.write('"\n');
    }
  }
} finally {
  await template.close();
  await output.close();
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

  let cc = 1;
  function serialize(tree, depth = 0) {
    if (depth >= maxDepth) {
      let c = Math.round(tree.v);
      stream.pushBit(c);
      cc = c;
    } else if (!tree.c) {
      let c = Math.round(tree.v);
      if (c === cc) {
        stream.pushBit(0);
      } else {
        stream.pushBit(1);
        stream.pushBit(0);
        cc = c;
      }
    } else {
      stream.pushBit(1);
      stream.pushBit(1);
      for (let c of tree.c) serialize(c, depth + 1);
    }
  }

  serialize(trees[0]);
}
