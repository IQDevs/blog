none:
	echo "run `make build` or `make deploy` or both"

build:
	jekyll build --destination iqdevs.github.io

deploy:
	cd iqdevs.github.io
	git add --all
	git commit -m "deployed on `date`"
	
