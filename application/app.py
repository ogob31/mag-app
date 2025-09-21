from flask import Flask
app = Flask(__name__)

@app.get("/health")
def health():
    return {"status": "ok", "service": "mag-app"}

@app.get("/")
def root():
    return "Hello from MAG!"

if __name__ == "__main__":
    # default 0.0.0.0:5000
    app.run(host="0.0.0.0", port=5000)
