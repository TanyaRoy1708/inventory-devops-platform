from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas import (
    ProductCreate,
    ProductRead,
    StockMovementCreate,
    StockMovementRead,
)
from app.services import (
    DuplicateSKUError,
    InsufficientStockError,
    ProductNotFoundError,
    create_product,
    create_stock_movement,
    list_products,
    list_stock_movements,
)


router = APIRouter(prefix="/products", tags=["Products"])

DatabaseSession = Annotated[Session, Depends(get_db)]


@router.post("", response_model=ProductRead, status_code=status.HTTP_201_CREATED)
def add_product(data: ProductCreate, db: DatabaseSession):
    try:
        return create_product(db, data)
    except DuplicateSKUError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc),
        ) from exc


@router.get("", response_model=list[ProductRead])
def get_products(db: DatabaseSession):
    return list_products(db)


@router.post(
    "/{product_id}/stock-movements",
    response_model=StockMovementRead,
    status_code=status.HTTP_201_CREATED,
)
def add_stock_movement(
    product_id: int,
    data: StockMovementCreate,
    db: DatabaseSession,
):
    try:
        return create_stock_movement(db, product_id, data)
    except ProductNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
    except InsufficientStockError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc),
        ) from exc


@router.get(
    "/{product_id}/stock-movements",
    response_model=list[StockMovementRead],
)
def get_stock_movements(
    product_id: int,
    db: DatabaseSession,
):
    try:
        return list_stock_movements(db, product_id)
    except ProductNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
