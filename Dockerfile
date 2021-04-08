FROM golang:latest

WORKDIR /go/src/app

COPY go.mod go.sum ./
RUN go get -d -v ./...

COPY main.go ./
RUN go build -o net-test main.go
RUN mv ./net-test /bin/

CMD ["net-test"]
