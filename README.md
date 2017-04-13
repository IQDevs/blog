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
    * The header (upper part) of your `.markdown` file needs to contain the following piece of information
   
       ```
       ---
       layout: post
       title:  TITLE
       date:   YYYY-MM-DD 00:00:00 -0500
       categories: CATEGORY
       author: alkass
       ---
      ```
     
      Where:
     
        * `YYYY`, `MM`, `DD` and `TITLE` are identical to the entries you entered above.
     
    * The rest of your file is where your blog post goes. Your blog post needs to be written in [`markdown`](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) format.
4. Submit a pull request

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
