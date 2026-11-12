def test_create_and_list_product(client):
    response = client.post(
        "/products",
        json={
            "sku": "TEST-KEYBOARD",
            "name": "Test Keyboard",
            "low_stock_threshold": 5,
        },
    )

    assert response.status_code == 201

    product = response.json()

    assert isinstance(product["id"], int)
    assert product["sku"] == "TEST-KEYBOARD"
    assert product["name"] == "Test Keyboard"
    assert product["quantity"] == 0
    assert product["low_stock_threshold"] == 5

    response = client.get("/products")

    assert response.status_code == 200
    assert product in response.json()


def test_duplicate_sku_is_rejected(client):
    data = {
        "sku": "TEST-DUPLICATE",
        "name": "Test Product",
        "low_stock_threshold": 2,
    }

    first_response = client.post("/products", json=data)
    assert first_response.status_code == 201

    duplicate_response = client.post("/products", json=data)
    assert duplicate_response.status_code == 409
    assert duplicate_response.json() == {
        "detail": "A product with this SKU already exists."
    }

    list_response = client.get("/products")
    assert list_response.status_code == 200

    matching_products = [
        product
        for product in list_response.json()
        if product["sku"] == data["sku"]
    ]
    assert len(matching_products) == 1
