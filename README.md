# router-api

![Runtime: Shell](https://img.shields.io/badge/runtime-shell-blue)
![Infra: Terraform](https://img.shields.io/badge/infra-terraform-green)
![Deploy: Serverless](https://img.shields.io/badge/deploy-serverless-yellow)
![Status: Experimental](https://img.shields.io/badge/status-experimental-orange)

> **Most routers don’t offer APIs. So I built one — without touching the firmware.**  
> This project turns a missing feature into an interface, using nothing but shell scripts, scraping, and quiet control logic.

By scraping the web interface my router already exposes, I shaped a simple API — one that connects clients directly to the router’s inner state and controls, securely and remotely. This programmable layer has already powered integrations like IoT automations, observability hooks, and smart triggers — and I'm planning to share a few of those small IoT projects here as well. All with just Bash, `jq`, and standard HTTP.

---

## Capabilities

- Authenticates to your router's web interface
- Parses and exposes router data (e.g. WAN status, device info)
- Wraps each action in a REST endpoint (via AWS Lambda)
- Uses [`lambda-shell-runtime`](https://github.com/ql4b/lambda-shell-runtime) to run native shell functions as serverless APIs
- Deploys via [`serverless-api-boilerplate`](https://github.com/ql4b/serverless-api-boilerplate)

---

## Architecture

```mermaid
graph LR
  A[Client] --> B[API Gateway]
  B --> C[Lambda]
  C --> D[Shell Function]
  D --> E[Router Web UI]
```

## Why it matters

Your router speaks web. This repo teaches it to speak API.

I don’t reverse the firmware — I reverse the interface.  
Using scraping, session control, and shell logic, we expose the device’s hidden state and controls — securely, remotely, and without invasive changes.

This is not hacking the router. This is *re-wiring its surface*.


## Tested Hardware

This project was developed and tested against a router with **Board ID `GPT-2541GNAC`** and firmware version `ES_g8.4_100VNJ0b78`.

The router exposes a web interface at `192.168.1.1`, and this API wrapper interacts with it over standard HTTP using login sessions and scraping techniques — no firmware mods or browser emulation required.

## Using the API 

Set variables: 

```bash
npm run --silent rest_api:staging \
    | jq -r '.key + " "  + .url'  \
    | read ROUTER_API_KEY ROUTER_API_ENDPOINT
```

or 

```bash

# .zshrc

router_api () {
    ROUTER_API_STAGE=${1:-"staging"}
    ROUTER_API_PATH=$(realpath ~/code/skunxicat/router-api)
    ROUTER_API_APP_PATH="$ROUTER_API_PATH/app"
    ROUTER_API_ENV="$ROUTER_API_PATH/.env"

    export ROUTER_API_STAGE=$ROUTER_API_STAGE

    cd $ROUTER_API_APP_PATH && \
        API_TMP=$(mktemp) && \
        npm run --silent "rest_api:$ROUTER_API_STAGE" \
        | jq -r '.key + " " + .url ' \
        > $API_TMP && \
            export  ROUTER_API_KEY=$(cut -d ' ' -f 1 "$API_TMP") &&  \
            export  ROUTER_API_ENDPOINT=$(cut -d ' ' -f 2 "$API_TMP") &&
            rm $API_TMP

    set -a && \
        . "$ROUTER_API_ENV" && \
        set +a

    env | grep "ROUTER_API" | grep -v "KEY"
} 

```

Send requests: 


#### `/info`

**Info**

```bash
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/info \
    | jq
```

#### `/wan`

**WAN**

```bash
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/wan \
    | jq
```

#### `/stations`

**Stations**

```bash
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/stations \
    | jq
```

#### `/reboot`

**Reboot**

```bash
http-cli --header "X-Api-Key: $API_KEY" \
    $API_ENDPOINT/reboot \
    | jq
```


## Example Use Case

Want to trigger a scene when a new device joins your Wi-Fi?  
Monitor bandwidth or reboot remotely when upstream goes down?

With this API, you can:

- Track connected clients from your mobile dashboard
- Reboot the router from a single `curl` request
- Hook router events into your smart home


All with a single `http-cli` call.

> **Note:** This is just a subset of what the API can expose. For now, I’ve left out certain sensitive or write-level features — like Wi-Fi password management — which I may share later in a dedicated project (e.g. an Alexa skill that replies with your Wi-Fi password).
