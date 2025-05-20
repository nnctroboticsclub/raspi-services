from fastapi import FastAPI, UploadFile, File, HTTPException
import os
import shutil
import subprocess

app = FastAPI()

UPLOAD_DIR = "/mnt/debs"


@app.post("/api/deb/upload")
async def upload_deb(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided.")
    if not file.filename.endswith(".deb"):
        raise HTTPException(status_code=400, detail="Only .deb files are allowed.")

    os.makedirs(UPLOAD_DIR, exist_ok=True)
    dest_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(dest_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {"filename": file.filename}


@app.post("/api/deb/refresh-apt-cache")
def refresh_apt_cache():
    cwd = UPLOAD_DIR
    try:
        subprocess.run(
            "apt-ftparchive packages . > Packages", shell=True, check=True, cwd=cwd
        )
        subprocess.run(
            "apt-ftparchive contents . | gzip -9 > Contents.gz",
            shell=True,
            check=True,
            cwd=cwd,
        )
        subprocess.run(
            "apt-ftparchive release . > Release", shell=True, check=True, cwd=cwd
        )
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to refresh apt cache: {e}")
    return {"status": "ok"}


@app.get("/api/deb/list")
def list_debs():
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    debs = [f for f in os.listdir(UPLOAD_DIR) if f.endswith(".deb")]
    return {"debs": debs}


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}
