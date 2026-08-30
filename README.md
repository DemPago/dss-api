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

```bash
docker build --build-arg DSS_VERSION=6.4+20260415 -t dss-api .
```

## Note di sicurezza

- Il container gira con utente non-root (`tomcat`)
- Non committare mai nel repo file contenenti documenti, certificati o dati personali
