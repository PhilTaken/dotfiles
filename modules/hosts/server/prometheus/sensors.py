from pyramid.config import Configurator
from pyramid.response import Response
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from prometheus_client import CollectorRegistry, Gauge
import serial
import json

SERIAL_ID = "usb-Adafruit_QT2040_Trinkey_DF609C8067563726-if00"


class PromMetrics(object):
    def __init__(self, request):
        self.request = request
        self.serial = serial.Serial(f"/dev/serial/by-id/{SERIAL_ID}")
        self.registry = CollectorRegistry()

    def __call__(self):
        data = json.loads(self.serial.readline())

        temp = Gauge("sensor_temp", "Temperature", registry=self.registry)
        temp.set(data['temperature'])

        prs = Gauge("sensor_prs", "Pressure", registry=self.registry)
        prs.set(data['pressure'])

        gas = Gauge("sensor_gas", "Gas Content", registry=self.registry)
        gas.set(data['gas'])

        alt = Gauge("sensor_alt", "Altitude", registry=self.registry)
        alt.set(data['altitude'])

        hum = Gauge("sensor_hum", "Humidity", registry=self.registry)
        hum.set(data['humidity'])

        light = Gauge("sensor_light", "Light", registry=self.registry)
        light.set(data['light'])

        return Response(generate_latest(self.registry),
                        content_type=CONTENT_TYPE_LATEST)


config = Configurator()
config.add_route('metrics', '/metrics')
config.add_view(PromMetrics, route_name='metrics')
app = config.make_wsgi_app()
