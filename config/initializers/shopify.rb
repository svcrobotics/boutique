ShopifyAPI::Context.setup(
  api_key: ENV.fetch("SHOPIFY_API_KEY"),
  api_secret_key: ENV.fetch("SHOPIFY_API_SECRET"),
  scope: ENV.fetch("SHOPIFY_SCOPE", "read_products,write_products"),
  host_name: ENV.fetch("SHOPIFY_HOST_NAME"),
  api_version: "2022-10", # tu peux aussi le passer en ENV si besoin
  is_embedded: false,
  is_private: true,
  session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
)
