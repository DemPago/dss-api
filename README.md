# dss-api

Wrapper Docker per [DSS Demo Bundle](https://ec.europa.eu/digital-building-blocks/sites/display/DIGITAL/Digital+Signature+Service+-++DSS) (Digital Signature Services), la suite open source della Commissione Europea per la verifica e creazione di firme digitali conformi agli standard eIDAS/ETSI.

## Requisiti

- Docker 20.10+
- Docker Compose v2 (opzionale)

## Avvio rapido

```bash
# Con Docker Compose
docker compose up -d

# Oppure build + run manuale
docker build -t dss-api .
docker run -d -p 8080:8080 --name dss-api dss-api
```

Il servizio sarà disponibile su `http://localhost:8080`.

## Endpoint principali

| Metodo | Endpoint | Descrizione |
|--------|----------|-------------|
| `POST` | `/services/rest/validation/validateDocument` | Valida una firma digitale |
| `POST` | `/services/rest/signature/one-document` | Crea una firma digitale |
| `GET`  | `/validation` | UI web per validazione manuale |

## Configurazione

| Variabile | Default | Descrizione |
|-----------|---------|-------------|
| `JAVA_OPTS` | `-Xmx512m -Xms256m ...` | Opzioni JVM, override via `-e` |

Esempio override memoria:

```bash
docker run -d -p 8080:8080 -e JAVA_OPTS="-Xmx1g -Xms512m" dss-api
```

## Build arguments

| ARG | Default | Descrizione |
|-----|---------|-------------|
| `DSS_VERSION` | `6.4+20260415` | Versione del bundle DSS |
| `TOMCAT_VERSION` | `11.0.21` | Versione di Tomcat inclusa nel bundle |

```bash
docker build --build-arg DSS_VERSION=6.4+20260415 -t dss-api .
```

## Deploy manuale su Azure

```bash
# 1. Build e push su ACR
az acr login -n dssapiregistry
docker build -t dssapiregistry.azurecr.io/dss-api:latest .
docker push dssapiregistry.azurecr.io/dss-api:latest

# 2. Rideploy su Azure Container Instances
az container create \
  --subscription <AZURE_SUBSCRIPTION> \
  --resource-group <AZURE_RESOURCE_GROUP> \
  --name dss-api \
  --image dssapiregistry.azurecr.io/dss-api:latest \
  --registry-login-server dssapiregistry.azurecr.io \
  --registry-username dssapiregistry \
  --registry-password <password da: az acr credential show -n dssapiregistry> \
  --cpu 1 --memory 2 \
  --ports 8080 --ip-address Public \
  --location northeurope --os-type Linux
```

## CI/CD con GitHub Actions

Ad ogni push su `main` il workflow `.github/workflows/deploy.yml` esegue build → push ACR → redeploy ACI.

### Secrets (GitHub → Settings → Secrets and variables → Actions)

| Secret | Come ottenerlo |
|--------|----------------|
| `REGISTRY_USERNAME` | `dssapiregistry` (fisso) |
| `REGISTRY_PASSWORD` | `az acr credential show -n dssapiregistry --query passwords[0].value -o tsv` |
| `AZURE_CREDENTIALS` | JSON service principal: `az ad sp create-for-rbac --name dss-api-deploy --role contributor --scopes /subscriptions/<id>/resourceGroups/<rg> --sdk-auth` |

### Variables (GitHub → Settings → Secrets and variables → Actions → Variables)

| Variable | Esempio |
|----------|---------|
| `AZURE_SUBSCRIPTION` | ID della subscription Azure |
| `AZURE_RESOURCE_GROUP` | Nome del resource group |

## Note di sicurezza

- Il container gira con utente non-root (`tomcat`)
- Il servizio è esposto su tutte le interfacce (`0.0.0.0:8080`) — **nessuna autenticazione integrata**. Usare un reverse proxy (nginx, Caddy) se esposto fuori dalla rete locale
- Non committare mai nel repo file contenenti documenti, certificati o dati personali
