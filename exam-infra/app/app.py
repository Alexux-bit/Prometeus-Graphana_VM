import os
import requests
from flask import Flask

app = Flask(__name__)

VAULT_ADDR  = os.environ.get("VAULT_ADDR",  "http://127.0.0.1:8200")
VAULT_TOKEN = os.environ.get("VAULT_TOKEN", "root")

def get_secret():
    try:
        r = requests.get(
            f"{VAULT_ADDR}/v1/secret/data/myapp/apikey",
            headers={"X-Vault-Token": VAULT_TOKEN},
            timeout=3,
        )
        return r.json()["data"]["data"]["value"]
    except Exception as e:
        return f"(vault error: {e})"

@app.route("/")
def index():
    secret = get_secret()
    return f"""
    <html><body style="font-family:monospace;padding:2em">
    <h2>Flask App</h2>
    <p>Secret from Vault: <b>{secret}</b></p>
    </body></html>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
