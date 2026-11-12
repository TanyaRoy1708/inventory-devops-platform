import pytest


def test_stock_in_and_out_update_quantity_and_history(client):
    response = client.post(
        "/products",
        json={
            "sku": "TEST-STOCK",
            "name": "Stock Test Product",
            "low_stock_threshold": 2,
        },
    )
    assert response.status_code == 201
    product_id = response.json()["id"]

    stock_in = client.post(
        f"/products/{product_id}/stock-movements",
        json={"movement_type": "IN", "quantity": 10},
    )
    assert stock_in.status_code == 201

    stock_out = client.post(
        f"/products/{product_id}/stock-movements",
        json={"movement_type": "OUT", "quantity": 3},
    )
    assert stock_out.status_code == 201

    products_response = client.get("/products")
    assert products_response.status_code == 200

    product = next(
        item
        for item in products_response.json()
        if item["id"] == product_id
    )
    assert product["quantity"] == 7

    history_response = client.get(
        f"/products/{product_id}/stock-movements"
    )
    assert history_response.status_code == 200

    history = history_response.json()
    assert len(history) == 2
    assert [
        (movement["movement_type"], movement["quantity"])
        for movement in history
    ] == [("OUT", 3), ("IN", 10)]


def test_insufficient_stock_leaves_quantity_and_history_unchanged(client):
    response = client.post(
        "/products",
        json={
            "sku": "TEST-INSUFFICIENT",
            "name": "Insufficient Stock Test",
            "low_stock_threshold": 0,
        },
    )
    assert response.status_code == 201
    product_id = response.json()["id"]

    stock_in = client.post(
        f"/products/{product_id}/stock-movements",
        json={"movement_type": "IN", "quantity": 5},
    )
    assert stock_in.status_code == 201

    history_before = client.get(
        f"/products/{product_id}/stock-movements"
    )
    assert history_before.status_code == 200

    rejected = client.post(
        f"/products/{product_id}/stock-movements",
        json={"movement_type": "OUT", "quantity": 6},
    )
    assert rejected.status_code == 409
    assert rejected.json() == {"detail": "Insufficient stock."}

    products_response = client.get("/products")
    assert products_response.status_code == 200

    product = next(
        item
        for item in products_response.json()
        if item["id"] == product_id
    )
    assert product["quantity"] == 5

    history_after = client.get(
        f"/products/{product_id}/stock-movements"
    )
    assert history_after.status_code == 200
    assert history_after.json() == history_before.json()


@pytest.mark.parametrize("quantity", [0, -1])
def test_nonpositive_movement_quantity_is_rejected(client, quantity):
    response = client.post(
        "/products",
        json={
            "sku": "TEST-INVALID-QUANTITY",
            "name": "Quantity Validation Test",
            "low_stock_threshold": 0,
        },
    )
    assert response.status_code == 201
    product_id = response.json()["id"]

    rejected = client.post(
        f"/products/{product_id}/stock-movements",
        json={"movement_type": "IN", "quantity": quantity},
    )
    assert rejected.status_code == 422

    history = client.get(
        f"/products/{product_id}/stock-movements"
    )
    assert history.status_code == 200
    assert history.json() == []
