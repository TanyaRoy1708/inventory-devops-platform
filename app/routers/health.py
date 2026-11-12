from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.database import get_db


router = APIRouter(prefix="/health", tags=["Health"])

DatabaseSession = Annotated[Session, Depends(get_db)]


@router.get("/live")
def liveness():
    return {"status": "alive"}


@router.get("/ready")
def readiness(db: DatabaseSession):
    try:
        db.execute(text("SELECT 1"))
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable.",
        ) from exc

    return {"status": "ready"}
