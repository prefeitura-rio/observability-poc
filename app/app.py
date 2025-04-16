import asyncio
import logging
import random
from http import HTTPStatus as status

import httpx
from fastapi import FastAPI, HTTPException, Response
from opentelemetry import metrics, trace
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.instrumentation.logging import LoggingInstrumentor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.trace import get_tracer
from prometheus_client import start_http_server

app = FastAPI()

_ = start_http_server(port=9464)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
logging_format = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(logging_format)
logger.addHandler(handler)

resource = Resource.create({"service.name": "fastapi-app"})
trace_provider = TracerProvider(resource=resource)
trace_provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
trace.set_tracer_provider(trace_provider)
tracer = get_tracer(__name__)

reader = PrometheusMetricReader()
meter_provider = MeterProvider(resource=resource, metric_readers=[reader])
metrics.set_meter_provider(meter_provider)
meter = meter_provider.get_meter("fastapi-app")

req_total = meter.create_counter("http_requests_total", description="Total HTTP requests")
req_duration = meter.create_histogram("http_request_duration_seconds", description="HTTP request duration in seconds")

LoggingInstrumentor().instrument(set_logging_format=True)
FastAPIInstrumentor.instrument_app(app)
HTTPXClientInstrumentor().instrument()


@app.get("/")
async def read_root() -> str:
    req_total.add(1, {"path": "/"})
    logger.info("hello world")
    return "Hello world"


@app.get("/items/{id}")
async def read_item(id: int) -> dict[str, int]:
    req_total.add(1, {"path": "/items"})
    logger.error("items")
    return {"id": id}


@app.get("/io_task")
async def io_task() -> str:
    req_total.add(1, {"path": "/io_task"})
    await asyncio.sleep(1)
    logger.error("io task")
    return "IO bound task finish!"


@app.get("/cpu_task")
async def cpu_task() -> str:
    req_total.add(1, {"path": "/cpu_task"})
    for i in range(1000000):
        _ = i * i * i
    logger.error("cpu task")
    return "CPU bound task finish!"


@app.get("/random_status")
async def random_status(response: Response) -> dict[str, str]:
    req_total.add(1, {"path": "/random_status"})
    response.status_code = random.choice([200, 200, 300, 400, 500])
    logger.error("random status")
    return {"path": "/random_status"}


@app.get("/random_sleep")
async def random_sleep() -> dict[str, str]:
    with tracer.start_as_current_span("random_sleep"):
        req_total.add(1, {"path": "/random_sleep"})
        await asyncio.sleep(random.randint(0, 5))
        logger.info("random sleep completed")
        return {"path": "/random_sleep"}


@app.get("/error_test")
async def error_test() -> None:
    req_total.add(1, {"path": "/error_test"})

    try:
        raise ValueError("value error")
    except ValueError as e:
        logger.error(e, exc_info=True)
        raise HTTPException(status_code=status.INTERNAL_SERVER_ERROR, detail="value error")


@app.get("/external_api")
async def external_api() -> str:
    req_total.add(1, {"path": "/external_api"})
    seconds = random.uniform(0, 3)
    async with httpx.AsyncClient(timeout=10) as client:
        _ = await client.get(f"https://httpbin.org/delay/{seconds}")
    return "Ok"
