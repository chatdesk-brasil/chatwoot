json.id resource&.id
json.order_number resource&.order_number
json.contact_id resource&.contact_id
json.order_key resource&.order_key
json.created_via resource&.created_via
json.platform resource&.platform
json.status resource&.status
json.currency resource&.currency
json.date_created resource&.date_created
json.date_created_gmt resource&.date_created_gmt
json.date_modified resource&.date_modified
json.date_modified_gmt resource&.date_modified_gmt
json.discount_total resource&.discount_total
json.discount_tax resource&.discount_tax
json.discount_coupon resource&.discount_coupon
json.shipping_total resource&.shipping_total
json.shipping_tax resource&.shipping_tax
json.cart_tax resource&.cart_tax
json.total resource&.total
json.total_tax resource&.total_tax
json.prices_include_tax resource&.prices_include_tax
json.customer_ip_address resource&.customer_ip_address
json.customer_user_agent resource&.customer_user_agent
json.customer_note resource&.customer_note
json.payment_method resource&.payment_method
json.payment_method_title resource&.payment_method_title
json.payment_status resource&.payment_status
json.transaction_id resource&.transaction_id
json.date_paid resource&.date_paid
json.date_paid_gmt resource&.date_paid_gmt
json.date_completed resource&.date_completed
json.date_completed_gmt resource&.date_completed_gmt
json.cart_hash resource&.cart_hash
json.set_paid resource&.set_paid

json.contact resource&.contact

json.order_items resource.order_items.presence do |item|
  json.id item.id
  json.name item.name
  json.product_id item.product_id
  json.variation_id item.variation_id
  json.quantity item.quantity
  json.tax_class item.tax_class
  json.subtotal item.subtotal
  json.subtotal_tax item.subtotal_tax
  json.total item.total
  json.total_tax item.total_tax
  json.sku item.sku
  json.price item.price
end
