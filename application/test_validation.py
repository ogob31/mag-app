from validation import is_valid_url

def test_accepts_basic_http_https():
    assert is_valid_url("http://example.com")
    assert is_valid_url("https://example.com/path?q=1")

def test_rejects_missing_scheme_or_host():
    assert not is_valid_url("example.com")
    assert not is_valid_url("ftp://example.com")
    assert not is_valid_url("https:///path-only")

def test_rejects_weird_hosts_and_spaces():
    assert not is_valid_url("https://ex..ample.com")
    assert not is_valid_url("https://exa mple.com")
    assert not is_valid_url("https://user@host.com")
