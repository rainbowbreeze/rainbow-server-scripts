# Start a service that returns some core machine signal, in a plan JSON format.
# Requires python3
#
# To test the service:
#  curl --get localhost:23123
#
#
# Part of the RainbowScripts suite

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
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
        _cpu_temperature = 0
        if os.path.isfile("/sys/class/thermal/thermal_zone0/temp"):
            try:
                with open(r"/sys/class/thermal/thermal_zone0/temp") as File:
                    _cpu_temperature = File.readline().strip()
            except Exception as e:
                print(f"Error reading CPU temp: {e}")

        # Read the memory stats
        # free command output
        # --------------------
        #               total        used        free      shared  buff/cache   available
        # Mem:         990024      176120       36020      173492      777884      579468
        # Swap:             0           0           0
        # --------------------
        _memory_tot, _memory_used, _memory_free = 0, 0, 0
        try:
            with open("/proc/meminfo") as f:
                meminfo = {}
                for line in f:
                    parts = line.split()
                    meminfo[parts[0]] = int(parts[1]) * 1024 # Convert kB to bytes
                
                _memory_tot = meminfo.get("MemTotal:", 0)
                _memory_free = meminfo.get("MemAvailable:", meminfo.get("MemFree:", 0))
                _memory_used = _memory_tot - _memory_free
        except Exception as e:
            print(f"Error reading memory info: {e}")
        
        # Read disk stats
        # Example result:
        #  usage(total=12882804736, used=8147230720, free=4735574016)
        _disk_root_total, _disk_root_used, _disk_root_free = 0, 0, 0
        try:
            _disk_root_total, _disk_root_used, _disk_root_free = shutil.disk_usage('/')
        except Exception as e:
            print(f"Error reading root disk usage: {e}")

        _disk_data_total, _disk_data_used, _disk_data_free = 0, 0, 0
        if os.path.isdir('/mnt/app-data'):
            try:
                _disk_data_total, _disk_data_used, _disk_data_free = shutil.disk_usage('/mnt/app-data')
            except Exception as e:
                print(f"Error reading data disk usage: {e}")

        # Creates the final signal object
        _signals = {
            "cpu_temperature": int(_cpu_temperature) / 1000 if _cpu_temperature else 0,
            "ram_total": int(_memory_tot),
            "ram_free": int(_memory_free),
            "ram_used": int(_memory_used),
            "disk_root_total": int(_disk_root_total),
            "disk_root_used": int(_disk_root_used),
            "disk_root_free": int(_disk_root_free),
            "disk_data_total": int(_disk_data_total),
            "disk_data_used": int(_disk_data_used),
            "disk_data_free": int(_disk_data_free)
        }
        # and return the string
        _signals_str = json.dumps(_signals)


        self.send_response(200)
        self.send_header("Content-type", "text/json")
        self.end_headers()
        self.wfile.write(bytes(_signals_str, "utf-8"))

if __name__ == "__main__":        
    webServer = ThreadingHTTPServer((hostName, serverPort), MyServer)
    print("Server started http://%s:%s" % (hostName, serverPort))

    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")
