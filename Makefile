deploy:
	$(eval VERSION := $(shell cat version.sh | grep 'CODECOV_WRAPPER_VERSION=' | cut -d\" -f2))
	git tag -d v0
	git push origin :v0
	git tag v0
	git tag v$(VERSION) -s -m ""
	git push origin --tags
