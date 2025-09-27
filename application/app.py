from flask import Flask, request, jsonify, render_template_string
from validation import is_valid_url

app = Flask(__name__)

@app.get("/health")
def health():
    return {"status": "ok", "service": "mag-app"}

@app.get("/")
def root():
    return '<h2>Hello from MAG!</h2><p><a href="/url-check">URL checker</a> · <a href="/mag-guide">MAG Guide</a></p>'

# URL checker page (simple client-side + API call)
HTML_URL = """
<!doctype html><html><head><meta charset="utf-8"><title>MAG URL Check</title>
<meta name="viewport" content="width=device-width,initial-scale=1"><style>
body{font-family:system-ui,Segoe UI,Roboto,Inter,Arial;margin:2rem}
.card{max-width:560px;border:1px solid #ddd;padding:1rem;border-radius:.75rem}
.ok{color:#0a7d00}.bad{color:#b00020}input,button{font-size:1rem;padding:.6rem .8rem}
input{width:100%;box-sizing:border-box;margin-bottom:.75rem}
</style></head><body>
<h1>Validate a URL</h1>
<div class="card">
<form id="f">
  <label for="u">Website URL (http/https)</label>
  <input id="u" name="url" type="url" required placeholder="https://example.com" pattern="https?://.+">
  <button type="submit">Check</button>
</form>
<p id="msg"></p>
</div>
<script>
const f=document.getElementById('f'), msg=document.getElementById('msg');
f.addEventListener('submit', async (e)=>{e.preventDefault(); msg.textContent="Checking…"; msg.className="";
  const url=document.getElementById('u').value.trim();
  try{
    const res=await fetch('/api/validate-url',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({url})});
    const data=await res.json();
    if(data.valid){msg.textContent='Valid URL ✔'; msg.className='ok';}
    else{msg.textContent='Invalid URL ✖'; msg.className='bad';}
  }catch(_){msg.textContent='Error checking URL.'; msg.className='bad';}
});
</script></body></html>
"""

@app.get("/url-check")
def url_check():
    return render_template_string(HTML_URL)

@app.post("/api/validate-url")
def api_validate_url():
    data = request.get_json(silent=True) or {}
    value = data.get("url", "")
    return jsonify({"valid": is_valid_url(value)})

# “Definition of a Gee” / MAG Guide page
HTML_MAG = """
<!doctype html><html><head><meta charset="utf-8"><title>MAG — Guide for International Students</title>
<meta name="viewport" content="width=device-width,initial-scale=1"><style>
body{font-family:system-ui,Segoe UI,Roboto,Inter,Arial;margin:2rem;line-height:1.5}
h1{margin:.2em 0} .pill{display:inline-block;background:#eef;border-radius:999px;padding:.2em .8em;margin:.2em 0}
.card{max-width:760px;border:1px solid #ddd;padding:1rem;border-radius:.75rem}
small{color:#666}
</style></head><body>
<h1>MAG — “Definition of a Gee”</h1>
<p class="pill">MAG is the best with international students.</p>
<div class="card">
  <p><strong>What’s a “Gee”?</strong> In MAG’s vibe, a “Gee” is a smart, reliable person who gets things done — calm under pressure, helpful, and on point.
  It’s the energy we bring when supporting students through admissions, visas, travel, and settling in.</p>
  <h3>How MAG helps international students</h3>
  <ul>
    <li>Application &amp; admissions guidance (deadlines, documents, interviews)</li>
    <li>Visa support (document checks, appointment prep, timelines)</li>
    <li>Financial prep (blocked account guidance, insurance basics)</li>
    <li>Arrival and setup (accommodation tips, city registration, bank, SIM)</li>
  </ul>
  <p><small>Need quick checks? Use our <a href="/url-check">URL validator</a> to verify official site links.</small></p>
</div>
<p><a href="/">← Back home</a></p>
</body></html>
"""

@app.get("/mag-guide")
def mag_guide():
    return render_template_string(HTML_MAG)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

