from fastapi import FastAPI, HTTPException
from starlette.responses import JSONResponse
import httpx
import os
from gradio import Interface

app = FastAPI()

API_BASE_URL = os.getenv("API_BASE_URL")
#API_BASE_URL = "https://example.com/api"
API_BASE_URL = "http://127.0.0.1:8000"
TIMEOUT = int(os.getenv("TIMEOUT", 15000))
BACKGROUND_COLOR = os.getenv("BACKGROUND_COLOR")

client = httpx.AsyncClient(base_url=API_BASE_URL, timeout=TIMEOUT / 1000.0)

@app.get("/")
async def read_home():
    try:
        print("Sending request to backend albums api")
        response = await client.get("/albums")
        response.raise_for_status()
        data = response.json()
        print("Response from backend albums api: ", data)
        return JSONResponse(content={"albums": data, "background_color": BACKGROUND_COLOR})
    except httpx.HTTPError as err:
        print("Error: ", err)
        raise HTTPException(status_code=500, detail="An error occurred while fetching data from backend API")

def gradio_interface(query: str):
    return read_home()

iface = Interface(fn=gradio_interface, inputs="text", outputs="json")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
    iface.launch()
