-- ---
-- Create flattened views {className}_products to show product and custom fields in a single relation and add triggers to tables to update the views as needed
-- ---

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;



--- ---
--- Dynamic materialized view creation
--- ---

--- Refresh all {className}_products materialized views
CREATE FUNCTION public.refresh_materialized_views(class_names TEXT[] DEFAULT NULL) RETURNS void
    LANGUAGE plpgsql AS $$
DECLARE
    class_name TEXT;
    columnTypes TEXT;
    query TEXT;
    view_name TEXT;
BEGIN
    FOR class_name IN
        SELECT DISTINCT className
        FROM Class
    LOOP
        SELECT string_agg(quote_ident(fieldName) || ' VARCHAR(1000)', ', ')
        INTO columnTypes
        FROM (
            SELECT DISTINCT fieldName
            FROM CustomFields
            WHERE className = class_name
        ) AS sub;

        view_name := quote_ident(class_name || '_products');

        IF columnTypes IS NULL THEN
            query := format($f$
                CREATE MATERIALIZED VIEW %s AS
                SELECT Product.productId, Product.className, Product.description, Product.cost, Product.currentPrice, Product.inventory
                FROM Product
                WHERE Product.className = '%s'
            $f$, view_name, class_name);
        ELSE
            query := format($f$
                CREATE MATERIALIZED VIEW %s AS
                SELECT *
                FROM crosstab(
                    'SELECT Product.productId, Product.className, Product.description, Product.cost, Product.currentPrice, Product.inventory, CustomFields.fieldName, CustomFieldData.fieldValue
                    FROM product Product
                    LEFT JOIN CustomFieldData USING (productId)
                    LEFT JOIN customFields USING (customFieldId)
                    WHERE Product.className = ''%s''',
                    'SELECT DISTINCT fieldName FROM CustomFields WHERE className = ''%s'''
                ) AS ct (
                    product_id INT,
                    class VARCHAR(15),
                    description VARCHAR(100),
                    cost MONEY,
                    currentPrice MONEY,
                    inventory INT, %s)
                $f$, view_name, class_name, class_name, columnTypes);
        END IF;

        EXECUTE format('DROP MATERIALIZED VIEW IF EXISTS %s', view_name);
        EXECUTE query;
    END LOOP;
END;
$$;

-- Trigger function to run refresh on insert/update/delete
--- --- NOTE:  {className}_products are materialized views meaning they cannot be updated directly from a trigger.  This function allows the views to be refreshed
CREATE FUNCTION public.refresh_materialized_view() RETURNS trigger
    LANGUAGE plpgsql AS $$

BEGIN
    PERFORM refresh_materialized_views();
    RETURN NULL;
END;
$$;


--- ---
--- Triggers
--- ---

CREATE TRIGGER refresh_products_trigger
    AFTER INSERT OR DELETE OR UPDATE ON public.product
    FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_materialized_view();

CREATE TRIGGER refresh_custom_fields_trigger
    AFTER INSERT OR DELETE OR UPDATE ON public.customFields
    FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_materialized_view();

CREATE TRIGGER refresh_custom_field_data_trigger
    AFTER INSERT OR DELETE OR UPDATE ON public.customFieldData
    FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_materialized_view();
