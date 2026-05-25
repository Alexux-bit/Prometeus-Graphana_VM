set -e

echo "=== [1/8] Updating packages ==="
sudo apt-get update -qq && sudo apt-get install -y -qq nginx python3-pip curl wget unzip

echo "=== [2/8] Installing Vault ==="
wget -q https://releases.hashicorp.com/vault/1.16.1/vault_1.16.1_linux_amd64.zip
unzip -q vault_1.16.1_linux_amd64.zip
sudo mv vault /usr/local/bin/
rm vault_1.16.1_linux_amd64.zip

echo "=== [3/8] Starting Vault in dev mode ==="
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
vault server -dev -dev-root-token-id=root &>/tmp/vault.log &
sleep 3

echo "=== [4/8] Writing secret to Vault ==="
vault kv put secret/myapp/apikey value="SuperSecretKey123"

echo "=== [5/8] Installing Node Exporter ==="
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
tar -xzf node_exporter-1.8.0.linux-amd64.tar.gz
sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
node_exporter &>/tmp/node_exporter.log &

echo "=== [6/8] Installing Prometheus ==="
wget -q https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar -xzf prometheus-2.52.0.linux-amd64.tar.gz
sudo cp prometheus.yml prometheus-2.52.0.linux-amd64/
sudo mv prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
prometheus --config.file=prometheus.yml &>/tmp/prometheus.log &

echo "=== [7/8] Installing Grafana ==="
sudo apt-get install -y -qq apt-transport-https software-properties-common
wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update -qq && sudo apt-get install -y -qq grafana
sudo sed -i 's|;root_url = %(protocol)s://%(domain)s:%(http_port)s/|root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana/|' /etc/grafana/grafana.ini
sudo sed -i 's|;serve_from_sub_path = false|serve_from_sub_path = true|' /etc/grafana/grafana.ini
sudo systemctl start grafana-server

echo "=== [8/8] Configuring Nginx and starting Flask ==="
sudo cp nginx/default.conf /etc/nginx/sites-available/default
sudo systemctl restart nginx
pip3 install flask -q --break-system-packages
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
python3 app/app.py &>/tmp/flask.log &

echo ""
echo "=== ALL DONE ==="
echo "App:     http://$(hostname -I | awk '{print $1}')/"
echo "Grafana: http://$(hostname -I | awk '{print $1}')/grafana/"