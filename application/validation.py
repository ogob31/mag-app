from urllib.parse import urlparse

SAFE_SCHEMES = {"http", "https"}

def is_valid_url(value: str) -> bool:
    if not value or not isinstance(value, str):
        return False
    value = value.strip()
    parsed = urlparse(value)

    if parsed.scheme.lower() not in SAFE_SCHEMES:
        return False
    if not parsed.netloc:
        return False
    if any(ord(ch) < 32 for ch in value) or " " in value:
        return False
    if "@" in parsed.netloc or ".." in parsed.netloc:
        return False

    return True
