FROM golang

RUN git clone https://github.com/harness/drone.git && cd drone && go build -tags "nolimit" github.com/drone/drone/cmd/drone-server

FROM golang

COPY --from=0 /go/drone/drone-server ./

CMD ["./drone-server"]
