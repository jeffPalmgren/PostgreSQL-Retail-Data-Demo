-- Insert sample Classes
INSERT INTO Class (className) VALUES
    ('grocery'),
    ('book'),
    ('board game');



-- Insert sample products and capture their IDs
WITH inserted_products AS (
    INSERT INTO Product (className, description, cost, currentPrice, inventory) VALUES
        ('grocery', 'noodles', 0.98, 1.98, 17),
        ('grocery', 'flour', 2.15, 4.42, 2),
        ('grocery', 'milk', 3.12, 4.89, 14),
        ('grocery', 'bread', .54, 2.18, 10),
        ('grocery', 'soda', 8.07, 12.32, 25),
        ('grocery', 'cognac', 83.00, 212.14, 0),
        ('book', 'The Secret Garden', 12.50, 20.32, 2),
        ('book', 'The Phantom of the Opera', 10.65, 35.91, 12),
        ('book', 'The Island of Dr. Moreau', 9.02, 15.05, 7),
        ('book', 'Peter and Wendy', 13.41, 21.55, 9),
        ('board game', 'Apples to Apples', 15.87, 28.23, 1),
        ('board game', 'The Farming Game', 26.65, 53.76, 5),
        ('board game', 'Monopoly', 19.57, 25.52, 9),
        ('board game', 'Chess', 8.14, 15.23, 3),
        ('board game', 'Stratego', 12.42, 23.56, 3)
    RETURNING productId, className, description
),

-- insert customFields and capture their IDs
inserted_fields AS (
    INSERT INTO CustomFields (className, fieldName, fieldType) VALUES
        ('grocery', 'Expiration Date', 'dateOnly'),
        ('book', 'Author', 'text'),
        ('book', 'Publication', 'int')
    RETURNING customFieldId, className, fieldName
),

-- map product and custom field data
field_data_map AS (
    SELECT * FROM (VALUES
        ('noodles', 'Expiration Date', '2026-03-12'),
        ('flour', 'Expiration Date', '2028-12-13'),
        ('milk', 'Expiration Date', '2025-05-20'),
        ('bread', 'Expiration Date', '2025-06-04'),
        ('The Secret Garden', 'Author', 'Frances Hodgson Burnett'),
        ('The Secret Garden', 'Publication', '1911'),
        ('The Phantom of the Opera', 'Author', 'Gaston Leroux'),
        ('The Phantom of the Opera', 'Publication', '1910'),
        ('The Island of Dr. Moreau', 'Author', 'H.G. Wells'),
        ('The Island of Dr. Moreau', 'Publication', '1896'),
        ('Peter and Wendy', 'Author', 'J.M. Berrie'),
        ('Peter and Wendy', 'Publication', '1911')
    ) AS t(description, fieldName, fieldValue)
)

--insert CustomFieldData
INSERT INTO customFieldData (productId, customFieldId, fieldValue)
SELECT
    products.productId,
    fields.customFieldId,
    map.fieldValue
FROM field_data_map map JOIN inserted_products products ON map.description = products.description
                        JOIN inserted_fields fields ON map.fieldName = fields.fieldName AND products.className = fields.className;
