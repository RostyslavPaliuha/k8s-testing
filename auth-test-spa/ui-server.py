import http.server
import os


HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8080"))


server_address = (HOST, PORT)
httpd = http.server.ThreadingHTTPServer(
    server_address,
    http.server.SimpleHTTPRequestHandler,
)

print(f"Serving HTTP on http://{HOST}:{PORT}", flush=True)
httpd.serve_forever()
