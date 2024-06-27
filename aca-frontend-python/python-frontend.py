from fastapi import FastAPI, HTTPException, Request
from starlette.responses import JSONResponse
import httpx
import os
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles

load_dotenv()  # Load environment variables from .env file

app = FastAPI()

app.mount("/static", StaticFiles(directory="public"), name="static")

API_BASE_URL = os.getenv("API_BASE_URL")
API_BASE_URL = "http://127.0.0.1:8000"
TIMEOUT = int(os.getenv("TIMEOUT", 15000))
BACKGROUND_COLOR = os.getenv("BACKGROUND_COLOR")

templates = Jinja2Templates(directory="views")

client = httpx.AsyncClient(base_url=API_BASE_URL, timeout=TIMEOUT / 1000.0)

@app.get("/", response_class=HTMLResponse)

async def read_home(request: Request):
    try:
        response = await client.get("/albums")
        response.raise_for_status()
        data = response.json()
        return templates.TemplateResponse("index.html", {
            "request": request,
            "albums": data,
            "background_color": BACKGROUND_COLOR,
        })
    except httpx.HTTPError as err:
        raise HTTPException(status_code=500, detail="An error occurred while fetching data from backend API")

@app.exception_handler(HTTPException)
async def custom_http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"message": exc.detail},
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
