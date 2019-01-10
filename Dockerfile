FROM node:8-alpine AS baseNodeImage

ARG TAG=v1.4.4
ARG REGISTRY=https://registry.npm.taobao.org

RUN apk add --no-cache git python make \
    && git clone --branch $TAG --depth 1 https://github.com/YMFE/yapi.git /vendors \
    && cd /vendors \
    && sed -i -e 's|init\.lock|runtime/init.lock|g' server/install.js \
    && npm install --no-optional --production --registry ${REGISTRY}

FROM node:8-alpine
RUN apk add --no-cache tini

WORKDIR /app/vendors
EXPOSE 3000

COPY --from=baseNodeImage /vendors /app/vendors
COPY ./entrypoint.sh /app/vendors/

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "/app/vendors/entrypoint.sh" ]
