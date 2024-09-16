# Bad Apple!! - but it's on Pico-8

These are my attempts to squeeze Bad Apple into a Pico-8 cartridge.

Click the image to watch the results on YouTube:

[![link to the video](cover.jpg)](https://youtube.com/watch?v=24_BtxYn8Ms)

Discuss it [on the Pico-8 forum](https://www.lexaloffle.com/bbs/?tid=143010).

## How to run

Download [the carts] and unpack them into a subdirectory in your carts folder. You can find this folder by executing a `FOLDER` command in Pico-8. Assuming you named the subdirectory `badapple`, your carts directory should look something like this:

[the carts]: https://github.com/iliazeus/pico8-badapp/releases/latest/download/carts.zip

```
┬─ carts
└┬─ badapple
 ├─ data_0.p8
 ├─ data_1.p8
 ...
 └─ play.p8
```

To then run the carts, change into this subdirectory in Pico-8 (`CD BADAPPLE`), and then load and run the "play" cart (`LOAD PLAY.P8`, `RUN`).

## How to build

You'll need these dependencies:

- GNU Make (other flavors of `make` might work too)
- [aria2](https://aria2.github.io/) - for downloading the Bad Apple source video
- ImageMagick
- Node.js (tested on v22, might work on several older ones)
- `pico8` in `$PATH` (optional; for automatic `.p8.png` generation)

Then, to build the `carts.zip`, just run `make`.
