build:
	mkdir -p build
	pnpm exec browserify audio.js > build/audio.js
	uglifyjs build/audio.js -c -m --in-situ

.PHONY: build
