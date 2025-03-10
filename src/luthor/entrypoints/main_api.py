from fastapi import FastAPI
from luthor.application.api.router import router

app = FastAPI()
app.include_router(router)
