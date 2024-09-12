all: ./build/carts
clean: clean-build

./build/carts: ./scripts/build-carts.mjs ./build/qtree.bin
	mkdir -p ./build/carts-tmp
	./scripts/build-carts.mjs --input ./build/qtree.bin --outdir ./build/carts-tmp
	rm -rf ./build/carts
	mv -T ./build/carts-tmp ./build/carts

./build/qtree.bin: ./scripts/encode-qtree.mjs ./data/frames
	./scripts/encode-qtree.mjs --output ./build/qtree.bin --endFrame 500

./data/frames: ./data/image_sequence
	mkdir -p ./data/frames-tmp
	$(MAKE) ./data/frames-tmp/ALL
	rm -rf ./data/frames
	mv -T ./data/frames-tmp ./data/frames

./data/frames-tmp/ALL: $(patsubst ./data/image_sequence/%, ./data/frames-tmp/%.bin, $(wildcard ./data/image_sequence/*))

./data/frames-tmp/%.bin: ./data/image_sequence/%
	magick $< -resize 128x128 -gravity south -background black -extent 128x128 -depth 1 GRAY:$@
#	magick $< -resize 128x128 -gravity center -background black -extent 128x128 -depth 1 GRAY:$@
#	magick $< -resize 128x128^ -gravity center -background black -extent 128x128 -depth 1 GRAY:$@

./data/image_sequence ./data/bad_apple.wav: ./data/bad_apple_is.7z
	mkdir -p ./data/bad_apple_is.7z.d
	7z x -y -o./data/bad_apple_is.7z.d ./data/bad_apple_is.7z
	touch ./data/bad_apple_is.7z.d/*
	mv ./data/bad_apple_is.7z.d/* ./data && rm -r ./data/bad_apple_is.7z.d

./data/bad_apple_is.7z: ./data/bad_apple_is.7z_archive.torrent
	mkdir -p ./data/aria2
	cd ./data/aria2 && aria2c ../bad_apple_is.7z_archive.torrent --seed-time=0
	mv ./data/aria2/bad_apple_is.7z/bad_apple_is.7z ./data/bad_apple_is.7z
	rm -rf ./data/aria2/bad_apple_is.7z

./data/bad_apple_is.7z_archive.torrent:
	cd ./data && wget https://archive.org/download/bad_apple_is.7z/bad_apple_is.7z_archive.torrent

clean-build:
	rm -rf ./build/*

clean-data:
	rm -rf ./data/*
