# Blog

## How to Contribute (Release Blog Posts)
1. Fork the repository
2. Start a new branch
3. under `_posts/` create an `.markdown` file that meets the following criteria:
  * File name must have the following format:
    * `YYYY-MM-DD-TITLE.markdown`
    
    Where:
    
      * `YYYY` is the year
      * `MM` is the month
      * `DD` is the day
      * `TITLE` is the title of your post
      
     Example:
      
      `2017-04-12-Rust for High-Level Programming Language Developers.markdown`
  * File content

## Checking Out the Code
```bash
$ git clone --recursive https://github.com/IQDevs/blog.git
```

## Production Build & Deployment

```bash
$ jekyll build --destination iqdevs.github.io
$ cd iqdevs.github.io
$ git add --all
$ git commit -m <message>
$ git push origin HEAD:master 
$ cd ..
```
