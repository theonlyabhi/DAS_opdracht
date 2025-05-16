from flask import Flask
# Nieuwe flask webapplicatie
app = Flask(__name__)

# Toont simpele hello world bericht
@app.route('/')
def hello():
    return "Hello from Abhishek!"

# App luistert op port 80, vereist door app service
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)