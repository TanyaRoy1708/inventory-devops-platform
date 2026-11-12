import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


# Must happen before importing application modules.
os.environ["DB_NAME"] = "inventory_test"

from app.database import engine, get_db
from app.main import app


if engine.url.database != "inventory_test":
    raise RuntimeError("Tests must use the inventory_test database.")
@pytest.fixture
def db_session():
    with engine.connect() as connection:
        transaction = connection.begin()

        try:
            with Session(
                bind=connection,
                join_transaction_mode="create_savepoint",
                expire_on_commit=False,
            ) as session:
                yield session
        finally:
            transaction.rollback()


@pytest.fixture
def client(db_session):
    def override_get_db():
        with Session(
            bind=db_session.get_bind(),
            join_transaction_mode="create_savepoint",
            expire_on_commit=False,
        ) as request_session:
            yield request_session

    app.dependency_overrides[get_db] = override_get_db

    try:
        with TestClient(app) as test_client:
            yield test_client
    finally:
        app.dependency_overrides.pop(get_db, None)
