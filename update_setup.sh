git checkout master
git pull
git checkout $(hostname)
git rebase master
git push -f
