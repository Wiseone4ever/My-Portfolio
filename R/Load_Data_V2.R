library(readr)
library(RSQLite)
library(tibble) # For data frame manipulation
library(dplyr) # For data manipulation
library(lubridate) # For date and time manipulation

customers_df <- readr::read_csv("datasets/CUSTOMERS.csv")
products_df <- readr::read_csv("datasets/PRODUCTS.csv")
gift_card_df <- readr::read_csv("datasets/GIFT_CARDS.csv")

# Connect to the SQLite database (this will create the database if it doesn't exist)

my_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"database/ecommerce_databse.db")
# RSQLite::dbWriteTable(my_connection,"customers",customer_mock_data,overwrite=TRUE)



#Sample Customers

sample_size <- floor(0.2 * nrow(products_df))

# Sample 20% of the customer_ids
sampled_product_ids <- sample(products_df$product_id, size = sample_size, replace = FALSE)

# Create a new data frame with only the sampled customer_ids
sampled_products_df <- products_df[products_df$product_id %in% sampled_product_ids, ]


#Sample Products

sample_size <- floor(0.2 * nrow(customers_df))

# Sample 20% of the customer_ids
sampled_customer_ids <- sample(customers_df$customer_id, size = sample_size, replace = FALSE)

# Create a new data frame with only the sampled customer_ids
sampled_customers_df <- customers_df[customers_df$customer_id %in% sampled_customer_ids, ]


generate_orders_data <- function(n = 1000) {
  set.seed(123) # For reproducibility
  
  orders_df <- tibble(
    order_id = sprintf("%s-%04d", "ORD", 1:n),
    customer_id = sample(sampled_customers_df$customer_id, n, replace = TRUE),
    product_id = sample(sampled_products_df$product_id, n, replace = TRUE),
#    shipment_id = sample(shipment_df$shipment_id, n, replace = TRUE),
    discount_id = sample(c(NA, gift_card_df$gift_card_id), n, replace = TRUE), # Assuming gift cards are used as discounts
    payment_method = sample(c("Credit Card", "Debit Card", "PayPal", "Gift Card"), n, replace = TRUE),
    quantity = sample(1:5, n, replace = TRUE),
    order_timestamp = sample(seq(as.POSIXct('2024/02/01'), as.POSIXct('2024/02/29'), by="day"), n, replace = TRUE),
    payment_timestamp = as.Date(order_timestamp + hours(sample(1:72, n, replace = TRUE))), # Payment within 1 to 72 hours after order
    order_status = sample(c("Processing", "Shipped", "Delivered", "Cancelled"), n, replace = TRUE),
    amount = round(runif(n, 50, 500), 2) # Random amount between $50 and $500
  )
  
  # Augment the orders data frame with supplier_id using left_join
  orders_df <- orders_df %>%
    left_join(sampled_products_df, by = "product_id") %>%
    select(order_id,customer_id,product_id,discount_id,payment_method,quantity,order_timestamp,payment_timestamp,order_status,amount,supplier_id) 
  
  return(orders_df)
}

# Generate orders data
orders_df <- generate_orders_data(n = 1000) # Adjust n for desired number of orders

generate_shipment_ids <- function(df) {
  # Create a unique identifier for each group
  df <- df %>% 
    mutate(date_only = as.Date(order_timestamp)) %>% 
    group_by(customer_id, supplier_id, date_only) %>%
    mutate(shipment_group_id = cur_group_id()) %>%
    ungroup() %>%
    mutate(shipment_id = sprintf("SHIP%05d", shipment_group_id)) %>%
    select(-shipment_group_id, -date_only) # Clean up the extra columns
  
  df
}

# Apply the function to your data frame
orders_df <- generate_shipment_ids(orders_df)

# Optional: Adjusting for logical consistency (e.g., cancelled orders should not have a shipment_id)
  orders_df <- orders_df %>%
    mutate(shipment_id = if_else(order_status %in% c("Cancelled","Processing"), NA_character_, as.character(shipment_id))) %>%
    mutate(supplier_id = NULL)

#Shipment Table
  
  shipment_df <- orders_df %>%
    mutate(
      # Dispatch date could be the same as the order date or a day after
      dispatch_timestamp = order_timestamp + days(sample(0:1, n(), replace = TRUE)),
      
      # Delivered date should be after the dispatch date; here I assume delivery takes between 2 to 5 days
      delivered_timestamp = dispatch_timestamp + days(sample(2:5, n(), replace = TRUE)),
      
      # Randomly assign a delivery status
      status = sample(c("Ready for Dispatch", "Dispatched", "In Transit", "Delivered"), n(), replace = TRUE)
    ) %>%
    # Select only the relevant columns for the shipment table
    select(shipment_id, dispatch_timestamp, delivered_timestamp, status) %>%
    # Remove duplicate rows to ensure unique shipments
    distinct() 

  shipment_df <- na.omit(shipment_df)
  
  
  shipment_df <- shipment_df %>%
    mutate(
      # Assign NA to dispatch_timestamp if status is 'Ready for Dispatch'
      dispatch_timestamp = if_else(status == "Ready for Dispatch", NA_Date_, dispatch_timestamp),
      delivered_timestamp = if_else(status == "Ready for Dispatch", NA_Date_, delivered_timestamp),
      
      # If status is 'Dispatched', dispatched date should be in the past
      dispatch_timestamp = if_else(status == "Dispatched", Sys.Date() - days(sample(1:5, 1)), dispatch_timestamp),
      delivered_timestamp = if_else(status == "Dispatched", NA_Date_, delivered_timestamp),
      
      # 'In Transit' status should have a dispatch date but no delivery date
      dispatch_timestamp = if_else(status == "In Transit", Sys.Date() - days(sample(1:5, 1)), dispatch_timestamp),
      delivered_timestamp = if_else(status == "In Transit", NA_Date_, delivered_timestamp),
      
      # If status is 'Delivered', both dates should be in the past, with delivered after dispatched
      dispatch_timestamp = if_else(status == "Delivered" & is.na(dispatch_timestamp), Sys.Date() - days(sample(6:10, 1)), dispatch_timestamp),
      delivered_timestamp = if_else(status == "Delivered", dispatch_timestamp + days(sample(1:5, 1)), delivered_timestamp)
    )
  
write_csv(orders_df,"order_df.csv")
