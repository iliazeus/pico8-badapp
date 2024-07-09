all: ./build/intro-loop-qtree-b32.p8.png ./build/intro-loop-qtree-b32ent.p8.png ./build/intro-loop-qtree-b27.p8.png
clean: clean-build

run-%: ./build/%.p8
	{ pico8 -root_path . -run $< & }; disown

./build/%.p8.png: ./build/%.p8
	-pico8 $< -export $@

./build/playcart-qtree-b32ent.p8: ./templates/playcart-qtree-b32ent.p8 \
    ./build/datacart-qtree-b32ent-1.p8 ./build/datacart-qtree-b32ent-2.p8 ./build/datacart-qtree-b32ent-3.p8
	cp ./templates/playcart-qtree-b32ent.p8 ./build

./build/datacart-qtree-b32ent-1.p8: ./scripts/encode-datacart-qtree-b32ent.mjs ./templates/datacart.p8 ./data/frames
	./scripts/encode-datacart-qtree-b32ent.mjs --template ./templates/datacart.p8 \
		--startFrame 1 --endFrame 2561 --frameStep 20 --maxDepth 6 \
		--output ./build/datacart-qtree-b32ent-1.p8

./build/datacart-qtree-b32ent-2.p8: ./scripts/encode-datacart-qtree-b32ent.mjs ./templates/datacart.p8 ./data/frames
	./scripts/encode-datacart-qtree-b32ent.mjs --template ./templates/datacart.p8 \
		--startFrame 2581 --endFrame 4561 --frameStep 20 --maxDepth 6 \
		--output ./build/datacart-qtree-b32ent-2.p8

./build/datacart-qtree-b32ent-3.p8: ./scripts/encode-datacart-qtree-b32ent.mjs ./templates/datacart.p8 ./data/frames
	./scripts/encode-datacart-qtree-b32ent.mjs --template ./templates/datacart.p8 \
		--startFrame 4581 --endFrame 6562 --frameStep 20 --maxDepth 6 \
		--output ./build/datacart-qtree-b32ent-3.p8

./build/intro-loop-qtree-b27.p8: ./scripts/encode-loop-qtree-b27.mjs ./templates/intro-loop-qtree-b27.p8 ./data/frames
	./scripts/encode-loop-qtree-b27.mjs --template ./templates/intro-loop-qtree-b27.p8 \
		--endFrame 189 --loopStartFrame 143 --frameStep 2 \
		--output ./build/intro-loop-qtree-b27.p8

./build/intro-loop-qtree-b32ent.p8: ./scripts/encode-loop-qtree-b32ent.mjs ./templates/intro-loop-qtree-b32ent.p8 ./data/frames
	./scripts/encode-loop-qtree-b32ent.mjs --template ./templates/intro-loop-qtree-b32ent.p8 \
		--endFrame 189 --loopStartFrame 143 --frameStep 2 \
		--output ./build/intro-loop-qtree-b32ent.p8

./build/intro-loop-qtree-b32.p8: ./scripts/encode-loop-qtree-b32.mjs ./templates/intro-loop-qtree-b32.p8 ./data/frames
	./scripts/encode-loop-qtree-b32.mjs --template ./templates/intro-loop-qtree-b32.p8 \
		--endFrame 189 --loopStartFrame 143 --frameStep 2 \
		--output ./build/intro-loop-qtree-b32.p8

./data/frames: ./data/image_sequence
	mkdir -p ./data/frames-tmp
	$(MAKE) ./data/frames-tmp/ALL
	mv ./data/frames-tmp ./data/frames

./data/frames-tmp/ALL: $(patsubst ./data/image_sequence/%, ./data/frames-tmp/%.bin, $(wildcard ./data/image_sequence/*))

./data/frames-tmp/%.bin: ./data/image_sequence/%
	magick $< -resize 128x128 -gravity center -background black -extent 128x128 -depth 1 GRAY:$@

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
