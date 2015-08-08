build: clean
	cd hugo
	hugo
	cd ..

clean:
	rm -rf hugo/public/

push: build
	goapp deploy
serve: clean
	goapp serve
