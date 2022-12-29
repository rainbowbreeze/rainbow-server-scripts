# Start a service that returns some core machine signal, in a plan JSON format.
# Requires python3
#
# To test the service:
#  curl --get localhost:23123
#
#
# Part of the RainbowScripts suite

from http.server import BaseHTTPRequestHandler, HTTPServer
import time
import datetime
import json
import os
import shutil

hostName = "0.0.0.0"
serverPort = 23123

class MyServer(BaseHTTPRequestHandler):
    def do_GET(self):

        # Read the cpu temperature
        _cpu_temp = 0
        with open(r"/sys/class/thermal/thermal_zone0/temp") as File:
            _cpu_temperature = File.readline()

        # Read the memory stats
        # free command output
        # --------------------
        #               total        used        free      shared  buff/cache   available
        # Mem:         990024      176120       36020      173492      777884      579468
        # Swap:             0           0           0
        # --------------------
        _memory_tot, _memory_used, _memory_free = map(int, os.popen('free -m').readlines()[1].split()[1:4])
        
        # Read disk stats
        # Example result:
        #  usage(total=12882804736, used=8147230720, free=4735574016)
        _disk_root_total, _disk_root_used, _disk_root_free = shutil.disk_usage('/')
        _disk_media_total, _disk_media_used, _disk_media_free = shutil.disk_usage('/media/volumes')

        # Creates the final signal object
        _signals = {
            "cpu_temp": int(_cpu_temperature) / 1000,
            "ram_total": int(_memory_tot),
            "ram_free": int(_memory_free),
            "ram_used": int(_memory_used),
            "disk_root_total": int(_disk_root_total) / 1048576,  # Megabyte
            "disk_root_used": int(_disk_root_used) / 1048576,
            "disk_root_free": int(_disk_root_free) / 1048576,
            "disk_media_total": int(_disk_media_total) / 1048576,
            "disk_media_used": int(_disk_media_used) / 1048576,
            "disk_media_free": int(_disk_media_free) / 1048576
        }
        # and return the string
        _signals_str = json.dumps(_signals)


        self.send_response(200)
        self.send_header("Content-type", "text/json")
        self.end_headers()
        self.wfile.write(bytes(_signals_str, "utf-8"))

if __name__ == "__main__":        
    webServer = HTTPServer((hostName, serverPort), MyServer)
    print("Server started http://%s:%s" % (hostName, serverPort))

    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")
