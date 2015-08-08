build: clean
	cd hugo
	hugo
	cd ..

clean:
	rm -rf hugo/public/

push: build
	cd hugo
	gsutil -m rsync -R public gs://www.thisguy.codes
	cd ..

serve: clean
	cd hugo
	hugo server -ws . --buildDrafts=true
	cd ..
