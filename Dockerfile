FROM alpine:3.12.0 as builder

RUN wget -O - https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
  | gunzip -c > /usr/local/bin/elm \
  && chmod +x /usr/local/bin/elm

COPY elm.json /elm.json
COPY src /src
RUN elm make src/Main.elm --output=/app/index.html

FROM nginx:1.19.0

COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app /app

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
