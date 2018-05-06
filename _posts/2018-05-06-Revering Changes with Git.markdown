---
layout: post
title:  Reverting Changes with Git
date:   2018-05-06 00:00:00 -0500
categories: C
author: Fadi Hanna Al-Kass
handle: https://github.com/alkass
---

# Reverting Local Changes

```bash
  git checkout -- <file name>
```

# Revering Added Changes

```bash
  git reset --hard
```

# Reverting Changes from a Local Commit

```bash
  git reset --hard HEAD~1
```

# Reverting Pushed Changes

```bash
  git reset --hard HEAD~1
  git push origin +master
```
