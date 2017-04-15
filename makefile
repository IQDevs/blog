deploy:
	jekyll build --destination iqdevs.github.io
	cd iqdevs.github.io && git add --all && git commit -m "`date`" && git push
	git add --all && git commit -m "`date`" && git push
