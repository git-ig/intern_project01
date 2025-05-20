FROM node:14-alpine


WORKDIR /frontend

RUN apk update
RUN npm install -g serve

COPY ./file/build /frontend/front

