deploy:
	cd *.github.io && git add --all && git commit -m "`date`" && git push
	git add --all && git commit -m "`date`" && git push
