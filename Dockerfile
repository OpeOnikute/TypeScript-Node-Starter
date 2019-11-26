# Using an alpine image because of its small size
FROM node:10-alpine

WORKDIR /usr/src/app

LABEL maintainer="opeyemionikute@yahoo.com"
LABEL description="Typescript node starter"
LABEL version="1.0"

# App runs on port 3000
EXPOSE 3000

COPY package*.json ./

RUN npm install

# Bundle app source
COPY . .

RUN npm run build

CMD [ "npm", "start" ]