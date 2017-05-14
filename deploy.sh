branch=`git branch | tail -n 1 | awk '{printf $1}'`

if [ $branch == "master" ]
then
  gem install jekyll
  bundle install
  git clone https://$1:$2@github.com/iqdevs/iqdevs.github.io.git
  jekyll build --destination iqdevs.github.io
  cd iqdevs.github.io
  git config --global user.email "$4"
  git config --global user.name "$3"
  git add --all
  git commit -m "Updated on `date`"
  git push origin HEAD:master
else
  echo "branch is $branch. Nothing to be done here."
fi
