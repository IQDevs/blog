none:
	echo "run 'make build' or 'make deploy' or both"

build:
	jekyll build --destination iqdevs.github.io

deploy:
	git add --all
	git commit -m "updated on `date`"
	git push origin HEAD:master
