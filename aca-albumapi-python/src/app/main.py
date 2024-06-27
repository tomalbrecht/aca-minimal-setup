# https://fastapi.tiangolo.com/advanced/custom-response/#fileresponse
# Alternative: https://stackoverflow.com/questions/55873174/how-do-i-return-an-image-in-fastapi

from typing import Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods="GET",
    allow_headers=["*"]
)

app.mount("/static", StaticFiles(directory="aca-albumapi-python/src/app/public"), name="static")
# http://localhost:8080/static/images/robbie.png

class Album():
    def __init__(self, id, title, artist, price, image_url):
         self.id = id
         self.title = title
         self.artist = artist
         self.price = price
         self.image_url = image_url

albums = [ 
    Album(1, "You, Me and an App Id", "Daprize", 10.99, "https://aka.ms/albums-daprlogo"),
    Album(2, "Seven Revision Army", "The Blue-Green Stripes", 13.99, "https://aka.ms/albums-containerappslogo"),
    Album(3, "Scale It Up", "KEDA Club", 13.99, "https://aka.ms/albums-kedalogo"),
    Album(4, "Lost in Translation", "MegaDNS", 12.99,"https://aka.ms/albums-envoylogo"),
    Album(5, "Lock Down Your Love", "V is for VNET", 12.99, "https://aka.ms/albums-vnetlogo"),
    Album(6, "Sweet Container O' Mine", "Guns N Probeses", 14.99, "https://aka.ms/albums-containerappslogo"),
    Album(7, "Digital Revolution", "The Bival", 19.99, "/static/images/robbie.png")
]

@app.get("/")
def read_root():
    return {"Access /albums to see the list of albums"}


# @app.get(
#     path="/api/media-file"
# )
# async def post_media_file():
#     return FileResponse("app/robbie.png", media_type="image/png")


@app.get("/albums")
def get_albums():
    return albums

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)