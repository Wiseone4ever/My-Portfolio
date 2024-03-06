library(readr)
library(RSQlite)

customer_mock_data <- readr::read_csv("datasets/CUSTOMERS.csv")
my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/ecommerce_databse.db")
RSQLite::dbWriteTable(my_connection,"customers",customer_mock_data)

