from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models import Product, StockMovement
from app.schemas import ProductCreate, StockMovementCreate


class DuplicateSKUError(Exception):
    pass


class ProductNotFoundError(Exception):
    pass


class InsufficientStockError(Exception):
    pass


def create_product(db: Session, data: ProductCreate) -> Product:
    product = Product(
        sku=data.sku,
        name=data.name,
        low_stock_threshold=data.low_stock_threshold,
    )

    try:
        with db.begin():
            db.add(product)
            db.flush()
    except IntegrityError as exc:
        if getattr(exc.orig, "sqlstate", None) == "23505":
            raise DuplicateSKUError(
                "A product with this SKU already exists.") from exc
        raise

    return product


def list_products(db: Session) -> list[Product]:
    statement = select(Product).order_by(Product.id)
    return list(db.scalars(statement).all())


def create_stock_movement(
    db: Session,
    product_id: int,
    data: StockMovementCreate,
) -> StockMovement:
    with db.begin():
        statement = (
            select(Product)
            .where(Product.id == product_id)
            .with_for_update()
        )
        product = db.scalar(statement)

        if product is None:
            raise ProductNotFoundError("Product not found")
        if data.movement_type == "OUT":
            if data.quantity > product.quantity:
                raise InsufficientStockError("Insufficient stock.")
            product.quantity -= data.quantity
        else:
            product.quantity += data.quantity

        movement = StockMovement(
            product_id=product.id,
            movement_type=data.movement_type,
            quantity=data.quantity,
        )

        db.add(movement)
        db.flush()

    return movement


def list_stock_movements(
    db: Session,
    product_id: int,
) -> list[StockMovement]:
    product = db.get(Product, product_id)

    if product is None:
        raise ProductNotFoundError("Product not found.")

    statement = (
        select(StockMovement)
        .where(StockMovement.product_id == product_id)
        .order_by(StockMovement.timestamp.desc(), StockMovement.id.desc())
    )

    return list(db.scalars(statement).all())
