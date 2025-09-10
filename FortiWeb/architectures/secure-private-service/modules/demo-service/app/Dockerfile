FROM node
WORKDIR /root/itworks-info

COPY index.js .
COPY package.json .

RUN npm install

EXPOSE 80

CMD node .