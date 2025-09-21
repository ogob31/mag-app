import os, time, requests

def test_health():
    # The pipeline will run the container on localhost:5000
    # In local dev you can run the container and keep this the same
    url = "http://localhost:5000/health"
    for _ in range(20):
        try:
            r = requests.get(url, timeout=1)
            assert r.status_code == 200
            j = r.json()
            assert j["status"] == "ok"
            assert j["service"] == "mag-app"
            return
        except Exception:
            time.sleep(0.25)
    raise AssertionError("health endpoint did not respond OK in time")
