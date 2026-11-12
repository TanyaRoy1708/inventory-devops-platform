from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from app.schemas import ProductCreate, StockMovementCreate
from app.database import get_db
from app.services import (
    create_product,
    DuplicateSKUError,
    list_products,
    InsufficientStockError,
    ProductNotFoundError,
    create_stock_movement,
)


router = APIRouter(tags=["Dashboard"])

DatabaseSession = Annotated[Session, Depends(get_db)]

templates = Jinja2Templates(
    directory=str(Path(__file__).resolve().parents[1] / "templates")
)


@router.get("/", include_in_schema=False)
def dashboard(request: Request, db: DatabaseSession):
    products = list_products(db)

    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "products": products,
            "total_products": len(products),
            "low_stock_count": sum(
                product.quantity <= product.low_stock_threshold
                for product in products
            ),
        },
    )


@router.post("/forms/products", include_in_schema=False)
def add_product_from_form(
    data: Annotated[ProductCreate, Form()],
    db: DatabaseSession,
):
    try:
        create_product(db, data)
    except DuplicateSKUError as exc:
        raise HTTPException(
            status_code=409,
            detail=str(exc),
        ) from exc

    return RedirectResponse(url="/", status_code=303)


@router.post(
    "/forms/products/{product_id}/stock-movements",
    include_in_schema=False,
)
def add_stock_movement_from_form(
    product_id: int,
    data: Annotated[StockMovementCreate, Form()],
    db: DatabaseSession,
):
    try:
        create_stock_movement(db, product_id, data)
    except ProductNotFoundError as exc:
        raise HTTPException(
            status_code=404,
            detail=str(exc),
        ) from exc
    except InsufficientStockError as exc:
        raise HTTPException(
            status_code=409,
            detail=str(exc),
        ) from exc

    return RedirectResponse(url="/", status_code=303)
