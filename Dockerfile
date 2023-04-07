FROM node:16-alpine

ADD . /app
COPY .env.example /app/.env

WORKDIR /app

RUN npm install

RUN npm run build

CMD npm start