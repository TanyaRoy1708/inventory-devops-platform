from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class ProductCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    sku: str = Field(min_length=1, max_length=50)
    name: str = Field(min_length=1, max_length=200)
    low_stock_threshold: int = Field(default=0, ge=0)


class ProductRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    sku: str
    name: str
    quantity: int
    low_stock_threshold: int


class StockMovementCreate(BaseModel):
    movement_type: Literal["IN", "OUT"]
    quantity: int = Field(gt=0)


class StockMovementRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    product_id: int
    movement_type: Literal["IN", "OUT"]
    quantity: int
    timestamp: datetime
