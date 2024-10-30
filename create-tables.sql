-- Create your database tables here. Alternatively you may use an ORM
-- or whatever approach you prefer to initialize your database.
CREATE TABLE example_table (id SERIAL PRIMARY KEY, some_int INT, some_text TEXT);
INSERT INTO example_table (some_int, some_text) VALUES (123, 'hello');

CREATE TABLE component_styles (
  component_id INT PRIMARY KEY, -- to link with the component (assuming we have only a single component for this example)
  margin_top VARCHAR(255),
  margin_bottom VARCHAR(255),
  margin_left VARCHAR(255),
  margin_right VARCHAR(255),
  padding_top VARCHAR(255),
  padding_bottom VARCHAR(255),
  padding_left VARCHAR(255),
  padding_right VARCHAR(255),
  UNIQUE (component_id)  -- Ensure uniqueness
);