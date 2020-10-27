FROM golang:1.14

WORKDIR /go/src/user_list
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

CMD ["user_list"]
