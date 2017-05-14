branch=`git branch | tail -n 1 | awk '{printf $1}'`
echo "branch is $branch"

if [ $branch == "master" ]
then
  gem install jekyll
  bundle install
  git clone https://$1:$2@github.com/iqdevs/iqdevs.github.io.git
  jekyll build --destination iqdevs.github.io
else
  echo not master
fi
