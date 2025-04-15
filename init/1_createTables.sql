-- Create 'Class' table
CREATE TABLE Class (
    className VARCHAR(15) PRIMARY KEY
);

-- Create 'Product' table
CREATE TABLE Product (
    productId SERIAL PRIMARY KEY,
    className VARCHAR(15) NOT NULL REFERENCES Class(className),
    description VARCHAR(100) NOT NULL,
    cost MONEY NOT NULL,
    currentPrice MONEY NOT NULL,
    inventory INT NOT NULL
);

-- Create 'CustomFields' table
CREATE TABLE CustomFields (
    customFieldId SERIAL PRIMARY KEY,
    className VARCHAR(15) NOT NULL REFERENCES Class(className),
    fieldName VARCHAR(15) NOT NULL,
    fieldType VARCHAR(10) NOT NULL,
    UNIQUE (className, fieldName)
);

-- Create 'CustomFieldData' table
CREATE TABLE CustomFieldData (
    productId INT NOT NULL REFERENCES Product(productId),
    customFieldId INT NOT NULL REFERENCES CustomFields(customFieldId),
    fieldValue VARCHAR(1000),

    PRIMARY KEY (productId, customFieldId)
);

