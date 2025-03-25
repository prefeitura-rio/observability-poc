import asyncio
import logging
import random
from http import HTTPStatus as status

import httpx
from fastapi import FastAPI, HTTPException, Response
from opentelemetry.trace import get_tracer

app = FastAPI()


logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())

tracer = get_tracer("app")


@app.get("/")
async def read_root() -> str:
    logging.info("hello world")
    return "Hello world"


@app.get("/items/{id}")
async def read_item(id: int) -> dict[str, int]:
    logging.error("items")
    return {"id": id}


@app.get("/io_task")
async def io_task():
    await asyncio.sleep(1)
    logging.error("io task")
    return "IO bound task finish!"


@app.get("/cpu_task")
async def cpu_task():
    for i in range(1000000):
        _ = i * i * i

    logging.error("cpu task")
    return "CPU bound task finish!"


@app.get("/random_status")
async def random_status(response: Response) -> dict[str, str]:
    response.status_code = random.choice([200, 200, 300, 400, 500])
    logging.error("random status")
    return {"path": "/random_status"}


@app.get("/random_sleep")
async def random_sleep() -> dict[str, str]:
    with tracer.start_as_current_span("random_sleep"):
        await asyncio.sleep(random.randint(0, 5))
        logging.error("random sleep")
        return {"path": "/random_sleep"}


@app.get("/error_test")
async def error_test():
    try:
        raise ValueError("value error")
    except ValueError as e:
        logger.error(e, exc_info=True)
        raise HTTPException(
            status_code=status.INTERNAL_SERVER_ERROR, detail="value error"
        )


@app.get("/external_api")
async def external_api() -> str:
    seconds = random.uniform(0, 3)

    async with httpx.AsyncClient(timeout=10) as client:
        _ = await client.get(f"https://httpbin.org/delay/{seconds}")

    return "Ok"
