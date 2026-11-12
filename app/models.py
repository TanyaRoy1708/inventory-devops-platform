from datetime import datetime

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base

class Product(Base):
    __tablename__= "products"

    __table_args__= (
        CheckConstraint("quantity >=0", name="ck_product_quantity"),
        CheckConstraint(
            "low_stock_threshold >= 0",
            name="ck_products_low_stock_threshold",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    sku: Mapped[str] = mapped_column(String(50), unique=True)
    name: Mapped[str] = mapped_column(String(200))
    quantity: Mapped[int] = mapped_column(default=0, server_default="0")
    low_stock_threshold: Mapped[int] = mapped_column(
        default=0,
        server_default="0",
    )

class StockMovement(Base):
    __tablename__="stock_movements"

    __table_args__=(
        CheckConstraint("quantity > 0", name="ck_stock_movements_quantity"),
        CheckConstraint(
            "movement_type IN ('IN', 'OUT')",
            name="ck_stock_movements_type",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id"),
        index=True,
    )
    movement_type: Mapped[str] = mapped_column(String(3))
    quantity: Mapped[int]
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )