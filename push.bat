git add .
git commit -m "update"
git push
ssh ali
cd /root/blog/
git pull -f
hexo clean
hexo g
exit