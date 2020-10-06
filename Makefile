ROOT = $(shell git rev-parse --show-toplevel)

lint-python:
	$(ROOT)/docker_run.py -- \
		--volume $(ROOT):/data \
		--workdir /data \
		wellcome/flake8:latest \
		    --exclude .git,__pycache__,target,.terraform \
		    --ignore=E501,E122,E126,E203,W503

format-terraform:
	$(ROOT)/docker_run.py --aws -- \
		--volume $(ROOT):/repo \
		--workdir /repo \
		hashicorp/terraform:light fmt -recursive

format-python:
	$(ROOT)/docker_run.py -- \
		--volume $(ROOT):/repo \
		wellcome/format_python:112

format: format-terraform format-python

lint: lint-python
	git diff --exit-code
