# Start a service that returns some core machine signal, in a plan JSON format
#
# curl localhost:23123
#
# Part of the RainbowScripts suite

from http.server import BaseHTTPRequestHandler, HTTPServer
import time
import datetime

hostName = "0.0.0.0"
serverPort = 23123

class MyServer(BaseHTTPRequestHandler):
    def do_GET(self):
        _cpu_temp = 0
        with open(r"/sys/class/thermal/thermal_zone0/temp") as File:
            _cpu_temp = File.readline()
        
        self.send_response(200)
        self.send_header("Content-type", "text/json")
        self.end_headers()
        self.wfile.write(bytes("{\"cpu_temp\":" + _cpu_temp / 1000 + "}", "utf-8"))

if __name__ == "__main__":        
    webServer = HTTPServer((hostName, serverPort), MyServer)
    print("Server started http://%s:%s" % (hostName, serverPort))

    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")
