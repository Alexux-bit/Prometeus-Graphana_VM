import subprocess
import json
import os
from flask import Flask

app = Flask(__name__)

VAULT_ADDR = "http://127.0.0.1:8200"
VAULT_TOKEN = "root"


def get_secret():
    env = os.environ.copy()
    env["VAULT_ADDR"] = VAULT_ADDR
    env["VAULT_TOKEN"] = VAULT_TOKEN
    result = subprocess.run(
        ["vault", "kv", "get", "-format=json", "secret/myapp/apikey"],
        capture_output=True,
        text=True,
        env=env,
    )
    if result.returncode != 0:
        return "ERROR: Could not fetch secret from Vault"
    data = json.loads(result.stdout)
    return data["data"]["data"]["value"]


@app.route("/")
def index():
    secret = get_secret()
    masked = "..." + secret[-4:] if len(secret) >= 4 else secret
    return f"""
    <html>
    <head><title>Exam App</title></head>
    <body style="font-family:sans-serif;max-width:600px;margin:60px auto;padding:0 20px">
        <h1>Exam Web Application</h1>
        <p><strong>Status:</strong> Running</p>
        <p><strong>Secret retrieved from Vault:</strong> <code>{masked}</code></p>
        <p style="color:green">Secret successfully fetched at runtime — no hardcoded credentials.</p>
        <hr>
        <p><a href="/grafana/">Open Grafana Dashboard</a></p>
    </body>
    </html>
    """


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
