build: clean
	hugo

clean:
	rm -rf public/

push: build
	gsutil -m rsync -R public gs://www.thisguy.codes

serve: clean
	hugo server -ws . --buildDrafts=true
