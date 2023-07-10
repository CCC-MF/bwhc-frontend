#
# MIT License
#
# Copyright (c) 2023 Comprehensive Cancer Center Mainfranken
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#!/bin/sh

sed -i -r "s/^(\s*)\"host\"[^,]*(,?)/\1\"host\": \"$NUXT_HOST\"\2/" ./package.json
sed -i -r "s/^(\s*)\"port\"[^,]*(,?)/\1\"port\": \"$NUXT_PORT\"\2/" ./package.json

# Prepare nuxt.config.js
sed -i -r "s/^(\s*)baseUrl[^,]*(,?)/\1baseUrl: process.env.BASE_URL || '$BACKEND_PROTOCOL:\/\/$BACKEND_HOSTNAME'\2/" ./nuxt.config.js
sed -i -r "s/^(\s*)port[^,]*(,?)/\1port: process.env.port || ':$BACKEND_PORT'\2/" ./nuxt.config.js

echo "❓ Checking existing build ..."

if [ -f package.md5 ] && [ -f nuxt.md5 ]; then
  CURRENT_PACKAGE=$(md5sum ./package.json)
  CURRENT_NUXT_CONFIG=$(md5sum ./nuxt.config.js)
  LAST_PACKAGE=$(cat ./package.md5)
  LAST_NUXT_CONFIG=$(cat ./nuxt.md5)
  if [ "$CURRENT_PACKAGE" != "$LAST_PACKAGE" ] || [ "$CURRENT_NUXT" != "$LAST_NUXT" ]; then
    echo "⌛ Changes found, start new Nuxt build"
    md5sum ./package.json > package.md5
    md5sum ./nuxt.config.js > nuxt.md5
    npm run generate
  else
    echo "✅ No changes, skipping Nuxt build"
  fi
else
  echo "⌛ No previous build found, start new Nuxt build"
  md5sum ./package.json > package.md5
  md5sum ./nuxt.config.js > nuxt.md5
  npm run generate
fi

echo "✅ Start application"
npm start


