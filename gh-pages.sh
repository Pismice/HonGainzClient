# Verify that the line exists and is commented
if ! grep -q "//String baseUrl = 'http://localhost:8080/';" lib/globals.dart; then
  echo "Error: The line //String baseUrl = 'http://localhost:8080/'; is not commented in globals.dart. Aborting."
  exit 1
fi

flutter build web
cp -r build/web/* ../tmp
git checkout gh-pages
cp -r ../tmp/* .
sed -i 's|<base href="/">|<base href="/HonGainzClient/">|' index.html
git add .
git commit -m "Update gh-pages"
git push
git checkout main
# pas oublier de changer le /HonGainzClient/
# veriifier que pas localhost sur baseURL