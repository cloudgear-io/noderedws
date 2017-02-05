FROM alpine:3.5

ENV VERSION=v7.5.0 NPM_VERSION=4

# For base builds
ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
  curl -sSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep . && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm@${NPM_VERSION} && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts
RUN cd /opt && git clone https://github.com/node-red/node-red.git
RUN cd /opt/node-red && npm install
RUN cd /opt/node-red && grunt build
EXPOSE 1880
EXPOSE 1881
RUN cd /opt/node-red && npm install node-red-contrib-freeboard
RUN cd /opt/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/ && git clone https://github.com/Freeboard/plugins.git
RUN cd /opt/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/plugins && mv * ../
RUN cd /opt/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/ && rm -rf plugins
RUN cd /opt/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/ && sed -i.bak -e '13d' index.html
RUN cd /opt/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/ && sed -i '13ihead.js("js/freeboard.js","js/freeboard.plugins.min.js", "../freeboard_api/datasources","plugins/datasources/plugin_json_ws.js","plugins/datasources/plugin_node.js",' index.html
RUN cd /opt/node-red && npm install node-red-node-mongodb
RUN cd /opt/node-red && npm install node-red-contrib-mongodb2
RUN cd /opt/node-red && npm install node-red-contrib-salesforce
RUN cd /opt/node-red && npm install node-red-contrib-googlechart
RUN cd /opt/node-red && npm install node-red-contrib-azure-documentdb 
RUN cd /opt/node-red && npm install node-red-contrib-azure-https
RUN cd /opt/node-red && npm install node-red-contrib-azure-table-storage
RUN cd /opt/node-red && npm install node-red-contrib-azure-blob-storage
RUN cd /opt/node-red && npm install node-red-contrib-azure-iot-hub
RUN cd /opt/node-red && npm install node-red-contrib-cognitive-services
RUN cd /opt/node-red && npm install node-red-contrib-azure-sql
RUN cd /opt/node-red && npm install node-red-contrib-azureiothubnode
CMD ["node", "/opt/node-red/red.js"]
