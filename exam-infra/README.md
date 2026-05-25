# Exam Infrastructure — Automated Deployment

## Commands Used: 2

```bash
# Command 1 — Clone this repo
git clone https://github.com/Alexux-bit/Prometeus-Graphana_VM && cd exam-infra

# Command 2 — Run full setup
chmod +x setup.sh && ./setup.sh
```

---

## What Gets Deployed

| Component     | Tool             | Port  | Purpose                        |
|---------------|------------------|-------|--------------------------------|
| Reverse Proxy | Nginx            | :80   | Sole entry point               |
| Application   | Flask (Python)   | :5000 | Web app (secret via Vault)     |
| Secret Mgmt   | HashiCorp Vault  | :8200 | Runtime secret storage         |
| Metrics       | Node Exporter    | :9100 | CPU/RAM data                   |
| Scraper       | Prometheus       | :9090 | Metrics collection             |
| Dashboard     | Grafana          | :3000 | Visualization (via /grafana/)  |

---

## Access URLs (replace with your VM IP)

- **App:** http://VM_IP/
- **Grafana:** http://VM_IP/grafana/ — login: `admin` / `admin`
- **Prometheus:** http://VM_IP:9090
- **Vault UI:** http://VM_IP:8200 (token: `root`)

---

## Grafana Dashboard Setup (GUI — not counted as a command)

1. Open http://VM_IP/grafana/
2. Log in with `admin` / `admin`
3. Go to **Connections → Data sources → Add data source → Prometheus**
4. URL: `http://localhost:9090` → click **Save & test**
5. Go to **Dashboards → New → Import**
6. Enter ID `1860` → Load → Import

---

## Security Compliance

- No passwords are hardcoded in any config file
- The Flask app retrieves its secret from Vault at runtime via the Vault API
- The application is not exposed directly — all access routes through Nginx

---

## File Structure

```
exam-infra/
├── setup.sh              ← Full automated installer (run this)
├── README.md             ← This file
├── app/
│   └── app.py            ← Flask web application
├── nginx/
│   └── default.conf      ← Nginx reverse proxy config
├── prometheus/
│   └── prometheus.yml    ← Prometheus scrape config
└── vault/
    └── vault.hcl         ← Vault config reference
```
