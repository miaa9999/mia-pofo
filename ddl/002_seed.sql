INSERT INTO todos (title, created_at)
VALUES
    ('Review FastAPI project structure', NOW() - INTERVAL '3 days'),
    ('Build Jinja2 template layout', NOW() - INTERVAL '2 days'),
    ('Connect HTMX create flow', NOW() - INTERVAL '1 day'),
    ('Verify Docker Compose deployment', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO bom_parts (id, parent_id, sku, name, part_type, quantity, unit, sort_order)
VALUES
    (1, NULL, 'BIKE-1000', 'Urban Commuter Bike', 'finished_good', 1, 'ea', 10),
    (2, 1, 'FRAME-AL-01', 'Aluminum Frame Set', 'assembly', 1, 'ea', 10),
    (3, 1, 'WHEEL-700C-SET', '700C Wheel Set', 'assembly', 1, 'set', 20),
    (4, 1, 'BRAKE-DISC-SET', 'Hydraulic Disc Brake Set', 'assembly', 1, 'set', 30),
    (5, 2, 'TUBE-TOP-AL', 'Top Tube', 'component', 1, 'ea', 10),
    (6, 2, 'TUBE-DOWN-AL', 'Down Tube', 'component', 1, 'ea', 20),
    (7, 2, 'FORK-CARBON-01', 'Carbon Fork', 'component', 1, 'ea', 30),
    (8, 3, 'RIM-700C', '700C Rim', 'component', 2, 'ea', 10),
    (9, 3, 'SPOKE-290MM', '290mm Spoke', 'component', 64, 'ea', 20),
    (10, 4, 'ROTOR-160MM', '160mm Rotor', 'component', 2, 'ea', 10)
ON CONFLICT (sku) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('bom_parts', 'id'),
    COALESCE((SELECT MAX(id) FROM bom_parts), 1)
);

INSERT INTO entities (id, entity_type, code, display_name)
VALUES
    (1, 'product', 'BIKE-1000', 'Urban Commuter Bike'),
    (2, 'product', 'FRAME-AL-01', 'Aluminum Frame Set'),
    (3, 'supplier', 'SUP-SEOUL-01', 'Seoul Precision Parts'),
    (4, 'supplier', 'SUP-BUSAN-02', 'Busan Wheel Works')
ON CONFLICT (entity_type, code) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('entities', 'id'),
    COALESCE((SELECT MAX(id) FROM entities), 1)
);

INSERT INTO entity_attributes (id, entity_type, code, label, value_type, is_required, sort_order)
VALUES
    (1, 'product', 'color', 'Color', 'text', TRUE, 10),
    (2, 'product', 'weight_kg', 'Weight (kg)', 'number', FALSE, 20),
    (3, 'product', 'is_active', 'Active', 'boolean', TRUE, 30),
    (4, 'supplier', 'contact_email', 'Contact Email', 'text', TRUE, 10),
    (5, 'supplier', 'lead_time_days', 'Lead Time Days', 'number', FALSE, 20),
    (6, 'supplier', 'contract_start_date', 'Contract Start Date', 'date', FALSE, 30)
ON CONFLICT (entity_type, code) DO NOTHING;

SELECT setval(
    pg_get_serial_sequence('entity_attributes', 'id'),
    COALESCE((SELECT MAX(id) FROM entity_attributes), 1)
);

INSERT INTO entity_attribute_values (
    entity_id,
    attribute_id,
    entity_type,
    value_text,
    value_number,
    value_boolean,
    value_date
)
VALUES
    (1, 1, 'product', 'Matte Black', NULL, NULL, NULL),
    (1, 2, 'product', NULL, 11.8000, NULL, NULL),
    (1, 3, 'product', NULL, NULL, TRUE, NULL),
    (2, 1, 'product', 'Raw Aluminum', NULL, NULL, NULL),
    (2, 2, 'product', NULL, 2.2500, NULL, NULL),
    (2, 3, 'product', NULL, NULL, TRUE, NULL),
    (3, 4, 'supplier', 'parts@seoul-precision.example', NULL, NULL, NULL),
    (3, 5, 'supplier', NULL, 7, NULL, NULL),
    (3, 6, 'supplier', NULL, NULL, NULL, DATE '2025-01-15'),
    (4, 4, 'supplier', 'sales@busan-wheel.example', NULL, NULL, NULL),
    (4, 5, 'supplier', NULL, 12, NULL, NULL),
    (4, 6, 'supplier', NULL, NULL, NULL, DATE '2025-03-01')
ON CONFLICT (entity_id, attribute_id) DO NOTHING;
