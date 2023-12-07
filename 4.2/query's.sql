-- Создание таблицы-фактов
CREATE TABLE sales_fact (
    id SERIAL,
    product_id INT,
    sale_date DATE,
    quantity INT
) 
DISTRIBUTED BY (id)
PARTITION BY RANGE (sale_date)
( START ('2023-12-01'::date) END ('2023-12-06'::date) EVERY ('1 day'::interval) );

-- Создание таблицы-измерения
CREATE TABLE product_dim (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- Заполнение таблиц данными
INSERT INTO product_dim (product_id, product_name, price) 
VALUES 
(1, 'Товар 1', 100.00),
(2, 'Товар 2', 200.00),
(3, 'Товар 3', 300.00),
(4, 'Товар 4', 400.00);

INSERT INTO sales_fact (product_id, sale_date, quantity) 
VALUES 
(1, '2023-12-01', 10),
(2, '2023-12-02', 20),
(3, '2023-12-03', 30),
(4, '2023-12-04', 40);
-- Включение оптимизатора GP
SET optimizer=on;

-- Запрос для расчета суммы продаж определенного товара за определенную единицу времени
SELECT p.product_name, SUM(p.price * s.quantity) as total_sales
FROM sales_fact s
JOIN product_dim p ON s.product_id = p.product_id
WHERE s.sale_date BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY p.product_name;

-- Печать плана запроса
EXPLAIN SELECT p.product_name, SUM(p.price * s.quantity) as total_sales
FROM sales_fact s
JOIN product_dim p ON s.product_id = p.product_id
WHERE s.sale_date BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY p.product_name;
