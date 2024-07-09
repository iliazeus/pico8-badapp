#!/usr/bin/env node

import * as fs from "node:fs/promises";
import { parseArgs } from "node:util";

const args = parseArgs({
  strict: true,
  options: {
    dataTemplate: { type: "string" },
    playTemplate: { type: "string" },
    outputDir: { type: "string" },
    maxDepth: { type: "string", default: "7" },
    frameStep: { type: "string" },
    split: { type: "string", multiple: true },
    startFrame: { type: "string" },
    endFrame: { type: "string" },
  },
});

const maxDepth = Number(args.values.maxDepth);
const startFrame = Number(args.values.startFrame);
const endFrame = Number(args.values.endFrame);
const frameStep = Number(args.values.frameStep);
const splits = args.values.split.map((s) => Number(s));
const outputDir = args.values.outputDir;

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

  get charCount() {
    return this.output.length;
  }

  toLuaString() {
    let s = `outc, outp = ${this.outc}, ${this.outp}\n`;
    s += 'data = "';
    s += String.fromCharCode(...this.output);
    s += '"\n';
    return s;
  }
}

let frameIndex = startFrame;

for (
  let dataCartIndex = 1;
  dataCartIndex <= splits.length;
  dataCartIndex += 1
) {
  let output = await fs.open(`${outputDir}/${dataCartIndex}.p8`, "w");
  await output.truncate();

  let dataTemplate = await fs.open(args.values.dataTemplate, "r");
  for await (let line of dataTemplate.readLines()) {
    if (line.trim() !== "--[[data]]--") {
      await output.write(line + "\n");
      continue;
    }

    let stream = new BitStreamBase32();

    for (; frameIndex < splits[dataCartIndex - 1]; frameIndex += frameStep) {
      let i = Math.round(frameIndex).toString().padStart(3, "0");
      let framePath = `./data/frames/bad_apple_${i}.png.bin`;
      await encodeFrame(framePath, maxDepth, stream);
    }

    if (stream.charCount >= 1 << 15) {
      console.warn(
        `data cart ${dataCartIndex} data too large: ${stream.charCount}`
      );
    }

    await output.write(stream.toLuaString());
  }

  await output.close();
  await dataTemplate.close();
}

{
  let output = await fs.open(`${outputDir}/play.p8`, "w");
  await output.truncate();

  let playTemplate = await fs.open(args.values.playTemplate, "r");
  for await (let line of playTemplate.readLines()) {
    if (line.trim() !== "--[[data]]--") {
      await output.write(line + "\n");
      continue;
    }

    let stream = new BitStreamBase32();

    for (; frameIndex <= endFrame; frameIndex += frameStep) {
      let i = Math.round(frameIndex).toString().padStart(3, "0");
      let framePath = `./data/frames/bad_apple_${i}.png.bin`;
      await encodeFrame(framePath, maxDepth, stream);
    }

    if (stream.charCount >= 1 << 15) {
      console.warn(`play cart data too large: ${stream.charCount}`);
    }

    await output.write(`maxdepth = ${maxDepth}\n`);
    await output.write(`framestep = ${frameStep}\n`);

    await output.write(`datacarts = {\n`);
    for (let i = 1; i <= splits.length; i++)
      await output.write(`\t"${outputDir}/${i}.p8",\n`);
    await output.write(`}\n`);

    await output.write(stream.toLuaString());
  }

  await output.close();
  await playTemplate.close();
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
