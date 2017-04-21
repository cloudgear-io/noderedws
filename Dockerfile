FROM mhart/alpine-node:7.9
MAINTAINER Dwai Banerjee "dwai@cloudgear.io"
RUN apk add --no-cache git make gcc g++ python
WORKDIR /src
ADD . .
RUN git clone https://github.com/node-red/node-red.git
WORKDIR /src/node-red
ADD . .
RUN npm install
RUN npm install -g grunt-cli
RUN npm install grunt --save-dev
RUN grunt build
EXPOSE 1880
EXPOSE 1881
RUN git clone https://github.com/Freeboard/freeboard.git
RUN npm install freeboard
RUN git clone https://github.com/urbiworx/node-red-contrib-freeboard.git
RUN npm install node-red-contrib-freeboard
RUN cd /src/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/ && git clone https://github.com/Freeboard/plugins.git
RUN cd /src/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/plugins && mv * ../
RUN cd /src/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/plugins/ && rm -rf plugins
RUN cd /src/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/ && sed -i.bak -e '13d' index.html
RUN cd /src/node-red/node_modules/node-red-contrib-freeboard/node_modules/freeboard/ && sed -i '13ihead.js("js/freeboard.js","js/freeboard.plugins.min.js", "../freeboard_api/datasources","plugins/datasources/plugin_json_ws.js","plugins/datasources/plugin_node.js",' index.html
WORKDIR /src/node-red
ADD . .
RUN npm install node-red-node-mongodb
RUN npm install node-red-contrib-mongodb2
RUN npm install node-red-contrib-salesforce
RUN npm install node-red-contrib-googlechart
RUN npm install node-red-contrib-azure-documentdb
RUN npm install node-red-contrib-azure-https
RUN npm install node-red-contrib-azure-table-storage
RUN npm install node-red-contrib-azure-blob-storage
RUN npm install node-red-contrib-azure-iot-hub
RUN npm install node-red-contrib-cognitive-services
RUN npm install node-red-contrib-azure-sql
RUN npm install node-red-contrib-azureiothubnode
RUN npm install node-red-contrib-swagger
#RUN rm -rf /src/node-red/freeboard && rm -rf /src/node-red/node-red-contrib-freeboard
#RUN apk del git
CMD ["node", "/src/node-red/red.js"]
