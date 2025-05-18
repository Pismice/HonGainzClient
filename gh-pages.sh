flutter build web
cp -r build/web/* ../tmp
git checkout gh-pages
cp -r ../tmp/* .
# pas oublier de changer le /HonGainzClient/
# veriifier que pas localhost sur baseURL