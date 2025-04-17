import asyncio
import logging
import random
from http import HTTPStatus as status

import httpx
from fastapi import FastAPI, HTTPException, Response

app = FastAPI()

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)


@app.get("/")
async def read_root() -> str:
    logger.info("hello world")
    return "Hello world"


@app.get("/items/{id}")
async def read_item(id: int) -> dict[str, int]:
    logger.error("items")
    return {"id": id}


@app.get("/io_task")
async def io_task() -> str:
    await asyncio.sleep(1)
    logger.error("io task")
    return "IO bound task finish!"


@app.get("/cpu_task")
async def cpu_task() -> str:
    for i in range(1000000):
        _ = i * i * i

    logger.error("cpu task")
    return "CPU bound task finish!"


@app.get("/random_status")
async def random_status(response: Response) -> dict[str, str]:
    response.status_code = random.choice([200, 200, 300, 400, 500])
    return {"path": "/random_status"}


@app.get("/random_sleep")
async def random_sleep() -> dict[str, str]:
    await asyncio.sleep(random.randint(0, 5))
    return {"path": "/random_sleep"}


@app.get("/error_test")
async def error_test() -> None:
    try:
        raise ValueError("value error")
    except ValueError as e:
        logger.error(e, exc_info=True)
        raise HTTPException(status_code=status.INTERNAL_SERVER_ERROR, detail="value error")


@app.get("/external_api")
async def external_api() -> str:
    seconds = random.uniform(0, 3)

    async with httpx.AsyncClient(timeout=10) as client:
        _ = await client.get(f"https://httpbin.org/delay/{seconds}")

    return "Ok"
