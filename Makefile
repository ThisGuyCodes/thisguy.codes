build:
	$(MAKE) -C hugo

push: build
	goapp deploy

serve: build
	goapp serve
