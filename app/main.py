from fastapi import FastAPI

from app.routers import health, products, pages


app = FastAPI(title="Inventory Application")

app.include_router(products.router)
app.include_router(health.router)
app.include_router(pages.router)
