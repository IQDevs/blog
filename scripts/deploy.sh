branch=`git branch | tail -n 1 | awk '{printf $1}'`

echo Branch is $branch

if [ $branch == "master" ]; then
  gem install jekyll
  bundle install
  git clone https://$1:$2@github.com/iqdevs/iqdevs.github.io.git
  jekyll build --destination iqdevs.github.io --incremental
  cd iqdevs.github.io
  git config --global user.email "$4"
  git config --global user.name "$3"
  git status
  git add --all
  git status
  git commit -m "Updated on `date`"
  git push origin HEAD:master
else
  echo "branch is $branch. Nothing to be done here."
fi
