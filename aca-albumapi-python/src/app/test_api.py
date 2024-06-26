from fastapi import FastAPI
from fastapi.responses import FileResponse

#some_file_path = "large-video-file.mp4"
some_file_path = "robbie.png"
app = FastAPI()


@app.get("/")
async def main():
    return FileResponse(some_file_path)