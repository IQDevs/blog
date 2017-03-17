# Blog

# Checking Out the Code
```bash
$ git clone --recursive https://github.com/IQDevs/blog.git
```

# Production Build & Deployment

```bash
$ jekyll build --destination iqdevs.github.io
$ cd iqdevs.github.io
$ git add --all
$ git commit -m <message>
$ git push origin HEAD:master 
$ cd ..
```
