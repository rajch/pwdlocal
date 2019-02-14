FROM golang AS build
ENV GOPATH=/go
WORKDIR /go/src/github.com/play-with-docker
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh 
RUN git clone https://github.com/play-with-docker/play-with-docker.git
WORKDIR /go/src/github.com/play-with-docker/play-with-docker
RUN dep ensure -v
RUN CGO_ENABLED=0 go build api.go
WORKDIR /go/src/github.com/play-with-docker/play-with-docker/router/l2
RUN CGO_ENABLED=0 go build l2.go

FROM haproxy AS pwd-haproxy
COPY --from=build /go/src/github.com/play-with-docker/play-with-docker/haproxy/ /usr/local/etc/haproxy

FROM alpine as alpinewithssh
COPY pwdapp/docker-entrypoint.sh /pwdapp/docker-entrypoint.sh
RUN apk update && \
    apk add openssh-keygen && \
    mkdir /pwd && \
    mkdir /etc/ssh && \
    chmod +x /pwdapp/docker-entrypoint.sh
WORKDIR /pwdapp
ENTRYPOINT [ "/pwdapp/docker-entrypoint.sh" ]

FROM alpinewithssh AS pwd-l2
COPY --from=build /go/src/github.com/play-with-docker/play-with-docker/router/l2/l2 /pwdapp/l2
CMD [ "l2" ]

FROM alpinewithssh AS pwd-pwd
COPY --from=build /go/src/github.com/play-with-docker/play-with-docker/api /pwdapp/api
COPY --from=build /go/src/github.com/play-with-docker/play-with-docker/www /pwdapp/www
CMD [ "pwd" ]