# router-api

This project scrapes the web interface your router already exposes and gives it purpose: an API you can plug into anything — IoT, automation, observability — with no need to change the hardware.

---

## What it does

- Authenticates to your router's web interface
- Parses and exposes router data (e.g. WAN status, device info)
- Wraps each action in a REST endpoint (via AWS Lambda)
- Uses [`lambda-shell-runtime`](https://github.com/ql4b/lambda-shell-runtime) to run native shell functions as serverless APIs
- Deploys via [`serverless-api-boilerplate`](https://github.com/ql4b/serverless-api-boilerplate)

---

## Architecture

```txt
[client] --> [API Gateway] --> [Lambda] --> [Shell Function] --> [Router Web UI]
```

## Using the API 

Set variables: 

```bash
npm run --silent rest_api:staging \
    | jq -r '.key + " "  + .url'  \
    | read API_KEY API_ENDPOINT
```

Send requests: 


#### `/info` 

```bash 
# info
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/info \
    | jq
```

#### `/wan` 
```bash
# wan
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/wan \
    | jq
```

#### `/stations` 
```bash
# stations
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/stations \
    | jq
```

#### `/reboot` 
```bash
# reboot 
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/reboot \
    | jq
```




