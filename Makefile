build:
	hugo

push: build
	gsutil -m rsync -R public gs://www.thisguy.codes
