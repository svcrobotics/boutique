class ShopifyController < ApplicationController
  def ping
    session = ShopifyAPI::Auth::Session.new(
      shop: ENV.fetch("SHOPIFY_HOST_NAME"),
      access_token: ENV.fetch("SHOPIFY_ACCESS_TOKEN")
    )

    # Version REST (plus simple)
    begin
      client = ShopifyAPI::Clients::Rest::Admin.new(session: session)
      result = client.get(path: "shop")
      render plain: "Connexion OK (REST) : #{result.body['shop']['name']}"
    rescue => e
      render plain: "Erreur connexion Shopify (REST) : #{e.message}"
    end

    # --- Ou, version GraphQL (commenter la version REST ci-dessus si tu veux utiliser GraphQL) ---
    # begin
    #   query = <<~GRAPHQL
    #     {
    #       shop {
    #         name
    #         email
    #         primaryDomain { url }
    #       }
    #     }
    #   GRAPHQL
    #   client = ShopifyAPI::Clients::Graphql::Admin.new(session: session)
    #   result = client.query(query: query)
    #   shop_name = result.body.dig("data", "shop", "name")
    #   render plain: "Connexion OK (GraphQL) : #{shop_name}"
    # rescue => e
    #   render plain: "Erreur connexion Shopify (GraphQL) : #{e.message}"
    # end
  end
end
