#!/usr/bin/env node

import * as fs from "node:fs/promises";
import { createReadStream } from "node:fs";
import { stdin } from "node:process";
import { parseArgs } from "node:util";
import assert from "node:assert";
import { join } from "node:path";

const args = parseArgs({
  strict: true,
  options: {
    input: { type: "string" },
    outdir: { type: "string" },
    pageSize: { type: "string", default: "13310" },
  },
});

const input = args.values.input ? createReadStream(args.values.input) : stdin;
const outdir = args.values.outdir;
const pageSize = Number(args.values.pageSize);

const ESC = 1;
const SEP = 2;
const ESC_ESC = [ESC, ESC];
const ESC_NUL = [ESC, 3];
const ESC_CR = [ESC, 4];
const ESC_SEP = [ESC, 5];

assert(outdir);

let data = [];
for await (let chunk of input) data.push(chunk);
data = Buffer.concat(data);

let pageCount = Math.ceil(data.length / pageSize);
for (let off = 0, pageIndex = 0; off < data.length; off += pageSize, pageIndex += 1) {
  let page = data.subarray(off, off + pageSize);
  let escaped = [];
  for (let byte of page) {
    if (byte === ESC) escaped.push(...ESC_ESC);
    else if (byte === 0) escaped.push(...ESC_NUL);
    else if (byte == 13) escaped.push(...ESC_CR);
    else if (byte === SEP) escaped.push(...ESC_SEP);
    else escaped.push(byte);
  }
  await fs.writeFile(
    join(outdir, `data_${pageIndex}.p8`),
    dataCartTemplate(escaped, pageIndex, pageCount)
  );
}

await fs.writeFile(join(outdir, "play.p8"), playCartTemplate());

function dataCartTemplate(data, index, count) {
  return `pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple data cart
base32 = "${toBase32(data)}"
page = {}
b, p = 0, 0
for i = 1, #base32 do
  local c = ord(base32, i)
  if c >= 97 then
    c -= 97
  else
    c -= 24
  end
  b = (b << 5) | c
  p += 5
  if p >= 8 then
    p -= 8
    local d = (b >> p) & 0xff
    add(page, d)
    b = b ^^ (d << p)
  end
end
page = chr(unpack(page))
data = ${index == 0 ? "page" : `stat(4) .. chr(${SEP}) .. page`}
poke(0x8000, ${index + 1})
${index + 1 < count ? `load("data_${index + 1}.p8")` : `load("play.p8")`}
`;
}

function playCartTemplate() {
  return `pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple play cart

function load_data()
  local i = peek(0x8000)
  if i == 0 then
    load("data_0.p8")
  end
  data = stat(4)
  poke(0x8000, 0)
  data=split(data,chr(${SEP}),false)
end

page,pagei = {},0
datac,datap,datai = 0,0,0
function next_bit()
  if datap == 0 then
    if datai == #page then
      if pagei == #data then
        return 0
      end
      pagei += 1
      page = data[pagei]
      datai = 0
    end
    datai += 1
    datac = ord(page,datai)
    if datac==${ESC} then
      datai += 1
      datac = ord(page,datai)
      if datac==${ESC_ESC[1]} then
        datac = ${ESC}
      elseif datac==${ESC_NUL[1]} then
        datac = 0
      elseif datac==${ESC_CR[1]} then
        datac = 13
      elseif datac==${ESC_SEP[1]} then
        datac = ${SEP}
      end
    end
    datap = 8
  end
  datap -= 1
  local bit = (datac & (1 << datap)) >> datap
  return bit
end

function draw_frame()
  local c = 7

  function rec(x0,y0,n,d)
    local l = false
    if d >= maxdepth then
      l = true
      c = next_bit()==0 and 0 or 7
    elseif next_bit() == 0 then
      l = true
    elseif next_bit() == 0 then
      l = true
      if c==7 then c=0 else c=7 end
    else
      l = false
    end

    if l then
      rectfill(x0,y0,x0+n-1,y0+n-1,c)
      if debug and n>=4 then
        rect(x0,y0,x0+n-1,y0+n-1,11)
      end
    else
      rec(x0,y0,n/2,d+1)
      rec(x0+n/2,y0,n/2,d+1)
      rec(x0,y0+n/2,n/2,d+1)
      rec(x0+n/2,y0+n/2,n/2,d+1)
    end
  end

  cls()
  rec(0,-16,128,0)
end
-->8
debug = false
timer = 0
framestep = 2
maxdepth = 7

function _init()
  load_data()
  cls()
end

function _update()
  if btnp(5) then
    debug = not debug
  end
  if (not btn(0)) timer += 1
  if (btn(1)) timer = framestep
  while timer >= framestep do
    timer -= framestep
    draw_frame()
  end
end

__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777700000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777700000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777770000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777770000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000077777000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000007700000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000007000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777770000000000000000000000000000000000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777000000000000000000000000000000000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000007000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000077777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777770000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777000000700000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777000000770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777000007770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777000007770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777770000007700000000007000000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000007700000000007000000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777700000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777700000077000000000007700000000000000000000000000000000000777777777777777777777777777777777777
77777777777777777777777777777777777700000077000000000007700000000000000000000000000000000000777777777777777777777777777777777777
77777777777777777777777777777777777700000070000000000007700000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777700000070000000000007700000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777700000000000000000770000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777770000000000000000770000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777777000000000000000770000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000000700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000007000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777000000000000770000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777700000000000770000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777000000000007770000000000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777777000000000007700000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777000000000077700000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777000000000077000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777770000000000777000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777770000000000770000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000007770000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000077700000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000077700000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000000777000000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000007777000000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000007770000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000077770000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777000777700000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777700777700000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777770777000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000777777777777777777777777777777777
`;
}

function toBase32(data) {
  let encoded = [];
  let p = 0;
  let buf = 0;
  for (let byte of data) {
    buf = (buf << 8) | byte;
    p += 8;
    while (p >= 5) {
      p -= 5;
      let c = buf >> p;
      buf ^= c << p;
      if (c <= 25) encoded.push(97 + c);
      else encoded.push(24 + c);
    }
  }
  if (p > 0) {
    buf <<= 5 - p;
    if (buf <= 25) encoded.push(97 + buf);
    else encoded.push(24 + buf);
  }
  return String.fromCharCode(...encoded);
}