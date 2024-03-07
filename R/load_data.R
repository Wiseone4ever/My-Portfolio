library(readr)
library(RSQLite)
library(tibble) # For data frame manipulation
library(dplyr) # For data manipulation
library(lubridate) # For date and time manipulation

customers_df <- readr::read_csv("datasets/CUSTOMERS.csv")
products_df <- readr::read_csv("datasets/PRODUCTS.csv")
shipment_df <- readr::read_csv("datasets/SHIPMENT.csv")
gift_card_df <- readr::read_csv("datasets/GIFT_CARDS.csv")

my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/ecommerce_databse.db")
# RSQLite::dbWriteTable(my_connection,"customers",customer_mock_data,overwrite=TRUE)

# Connect to the SQLite database (this will create the database if it doesn't exist)



generate_orders_data <- function(n = 500) {
  set.seed(123) # For reproducibility
  
  orders_df <- tibble(
    order_id = sprintf("%s-%04d", "ORD", 1:n),
    customer_id = sample(customers_df$customer_id, n, replace = TRUE),
    product_id = sample(products_df$product_id, n, replace = TRUE),
    shipment_id = sample(shipment_df$shipment_id, n, replace = TRUE),
    discount_id = sample(c(NA, gift_card_df$gift_card_id), n, replace = TRUE), # Assuming gift cards are used as discounts
    payment_method = sample(c("Credit Card", "Debit Card", "PayPal", "Gift Card"), n, replace = TRUE),
    quantity = sample(1:5, n, replace = TRUE),
    order_timestamp = sample(seq(as.POSIXct('2020/01/01'), as.POSIXct('2022/12/31'), by="day"), n, replace = TRUE),
    payment_timestamp = order_timestamp + hours(sample(1:72, n, replace = TRUE)), # Payment within 1 to 72 hours after order
    order_status = sample(c("Processing", "Shipped", "Delivered", "Cancelled"), n, replace = TRUE),
    amount = round(runif(n, 50, 500), 2) # Random amount between $50 and $500
  )
  
  # Optional: Adjusting for logical consistency (e.g., cancelled orders should not have a shipment_id)
  orders_df <- orders_df %>%
    mutate(shipment_id = if_else(order_status == "Cancelled", NA_character_, as.character(shipment_id)))
  
  return(orders_df)
}

# Generate orders data
orders_df <- generate_orders_data(n = 500) # Adjust n for desired number of orders
