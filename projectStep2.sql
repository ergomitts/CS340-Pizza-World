SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Positions;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Pizzas;
DROP TABLE IF EXISTS OrderPizzas;
SET FOREIGN_KEY_CHECKS = 1;


CREATE TABLE Locations
(
    locationID int auto_increment primary key,
    phone      varchar(12)  not null unique,
    email      varchar(50)  not null,
    address    varchar(100) not null,
    open       boolean default FALSE,
    Constraint check_phone CHECK (phone REGEXP '^[2-9]\\d{2}-[2-9]\\d{2}-\\d{4}$')
);

CREATE TABLE Positions
(
    positionID int auto_increment primary key,
    title      varchar(50) unique not null,
    salary     decimal(18, 2)     not null
);

CREATE TABLE Employees
(
    employeeID int auto_increment primary key,
    locationID int         not null,
    firstName  varchar(50) not null,
    lastName   varchar(50) not null,
    positionID int         not null,
    constraint employeeLocationFK
        foreign key (locationID) references Locations (locationID),
    constraint employeePositionFK
        foreign key (positionID) references Positions (positionID)
);


CREATE TABLE Customers
(
    customerID int auto_increment primary key,
    firstName  varchar(50)  not null,
    lastName   varchar(50)  not null,
    address    varchar(100) not null,
    phone      varchar(12)  not null unique,
    Constraint check_phone CHECK (phone REGEXP '^[2-9]\\d{2}-[2-9]\\d{2}-\\d{4}$')
);

CREATE TABLE Orders
(
    orderID    int auto_increment primary key,
    customerID int      not null,
    locationID int      not null,
    date       datetime not null,
    delivered  boolean  not null default FALSE,
    constraint orderCustomerFK
        foreign key (customerID) references Customers (customerID),
    constraint orderLocationFK
        foreign key (locationID) references Locations (locationID)
);

CREATE TABLE Pizzas
(
    pizzaID int auto_increment primary key,
    name    varchar(50) not null,
    size    varchar(50) not null,
    UNIQUE (name, size)
);

CREATE TABLE OrderPizzas
(
    orderPizzasID int auto_increment primary key,
    pizzaID       int            not null,
    orderID       int            not null,
    price         decimal(18, 2) not null,
    constraint orderPizzaFK
        foreign key (pizzaID) references Pizzas (pizzaID),
    constraint orderFK
        foreign key (orderID) references Orders (orderID)

);

-- Inserts --
insert into Locations (phone, email, address, open)
values ('415-555-1234', 'mission@pizza.example', '123 Mission St, SF CA', TRUE),
       ('510-234-5678', 'oakland@pizza.example', '456 Broadway, Oakland CA', FALSE),
       ('408-867-5309', 'sanjose@pizza.example', '789 Santa Clara, SJ CA', TRUE);

insert into Positions (title, salary)
values ('Manager', 72000.00),
       ('Driver', 42000.00),
       ('Cook', 50000.00);

insert into Customers (firstName, lastName, address, phone)
values ('Miguel', 'Cabrera', '17 Market St, San Francisco CA', '650-555-0199'),
       ('Priya', 'Nair', '88 Lakeshore Ave, Oakland CA', '628-345-7788'),
       ('Abdul', 'Rehman', '54 S 1st St, San Jose CA', '925-222-1100'),
       ('Emily', 'Zhao', '901 Pine St, San Francisco CA', '209-333-4444');

insert into Pizzas (name, size)
values ('Meats', 'Small'),
       ('Meats', 'Large'),
       ('Pepperoni', 'Large'),
       ('Veggie', 'Medium');

-- Employees (resolve location by Locations.phone, position by Positions.title)
insert into Employees (locationID, firstName, lastName, positionID)
select L.locationID, 'Ananya', 'Jaiswal', P.positionID
from Locations L
         join Positions P ON P.title = 'Manager'
where L.address = '123 Mission St, SF CA';

insert into Employees (locationID, firstName, lastName, positionID)
select L.locationID, 'Michael', 'Fern', P.positionID
from Locations L
         join Positions P ON P.title = 'Cook'
where L.address = '123 Mission St, SF CA';

insert into Employees (locationID, firstName, lastName, positionID)
select L.locationID, 'Sara', 'Smith', P.positionID
from Locations L
         join Positions P ON P.title = 'Driver'
where L.address = '456 Broadway, Oakland CA';

insert into Employees (locationID, firstName, lastName, positionID)
select L.locationID, 'Bo', 'Chang', P.positionID
from Locations L
         join Positions P ON P.title = 'Driver'
where L.address = '789 Santa Clara, SJ CA';

-- Orders (resolve customer by Customers.firstName + lastName; location by Locations.address)
insert into Orders (customerID, locationID, date, delivered)
select C.customerID, L.locationID, TIMESTAMP('2025-10-24 18:30:00'), TRUE
from Customers C
         join Locations L ON L.address = '123 Mission St, SF CA'
where C.firstName = 'Miguel'
  AND C.lastName = 'Cabrera';

insert into Orders (customerID, locationID, date, delivered)
select C.customerID, L.locationID, TIMESTAMP('2025-10-24 19:10:00'), FALSE
from Customers C
         join Locations L ON L.address = '456 Broadway, Oakland CA'
where C.firstName = 'Priya'
  AND C.lastName = 'Nair';

insert into Orders (customerID, locationID, date, delivered)
select C.customerID, L.locationID, TIMESTAMP('2025-10-25 12:05:00'), TRUE
from Customers C
         join Locations L ON L.address = '789 Santa Clara, SJ CA'
where C.firstName = 'Abdul'
  AND C.lastName = 'Rehman';

insert into Orders (customerID, locationID, date, delivered)
select C.customerID, L.locationID, TIMESTAMP('2025-10-25 12:30:00'), FALSE
from Customers C
         join Locations L ON L.address = '123 Mission St, SF CA'
where C.firstName = 'Emily'
  AND C.lastName = 'Zhao';

-- OrderPizzas (resolve pizza by (name,size) and order by (customer first+last, date))
-- Order 1 (Miguel, 2025-10-24 18:30:00)
insert into OrderPizzas (pizzaID, orderID, price)
select P.pizzaID, O.orderID, 11.99
from Pizzas P
         join Orders O ON O.date = TIMESTAMP('2025-10-24 18:30:00')
         join Customers C ON C.customerID = O.customerID
where C.firstName = 'Miguel'
  AND C.lastName = 'Cabrera'
  AND P.name = 'Meats'
  AND P.size = 'Small';

insert into OrderPizzas (pizzaID, orderID, price)
select P.pizzaID, O.orderID, 16.49
from Pizzas P
         join Orders O ON O.date = TIMESTAMP('2025-10-24 18:30:00')
         join Customers C ON C.customerID = O.customerID
where C.firstName = 'Miguel'
  AND C.lastName = 'Cabrera'
  AND P.name = 'Pepperoni'
  AND P.size = 'Large';

-- Order 2 (Priya, 2025-10-24 19:10:00)
insert into OrderPizzas (pizzaID, orderID, price)
select P.pizzaID, O.orderID, 17.99
from Pizzas P
         join Orders O ON O.date = TIMESTAMP('2025-10-24 19:10:00')
         join Customers C ON C.customerID = O.customerID
where C.firstName = 'Priya'
  AND C.lastName = 'Nair'
  AND P.name = 'Meats'
  AND P.size = 'Large';

-- Order 3 (Abdul, 2025-10-25 12:05:00)
insert into OrderPizzas (pizzaID, orderID, price)
select P.pizzaID, O.orderID, 15.99
from Pizzas P
         join Orders O ON O.date = TIMESTAMP('2025-10-25 12:05:00')
         join Customers C ON C.customerID = O.customerID
where C.firstName = 'Abdul'
  AND C.lastName = 'Rehman'
  AND P.name = 'Pepperoni'
  AND P.size = 'Large';

-- Order 4 (Emily, 2025-10-25 12:30:00)
insert into OrderPizzas (pizzaID, orderID, price)
select P.pizzaID, O.orderID, 13.99
from Pizzas P
         join Orders O ON O.date = TIMESTAMP('2025-10-25 12:30:00')
         join Customers C ON C.customerID = O.customerID
where C.firstName = 'Emily'
  AND C.lastName = 'Zhao'
  AND P.name = 'Veggie'
  AND P.size = 'Medium';
