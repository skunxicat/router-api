FROM golang:tip-bullseye AS build
WORKDIR /src
# Copy dependencies list
COPY src/go.mod src/go.sum ./
# Build with optional lambda.norpc tag
COPY src/main.go .
RUN go build -tags lambda.norpc -o main main.go

# Copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2023
COPY --from=build /src/main ./main
ENTRYPOINT [ "./main" ]