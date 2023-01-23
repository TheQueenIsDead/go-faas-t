# syntax=docker/dockerfile:1

FROM golang:1.19-alpine3.17

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN #GOOS=linux GOARCH=amd64 go build -o ./producer
RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o producer -ldflags="-w -s"
RUN chmod +x ./producer

EXPOSE 8080

CMD [ "/app/producer" ]