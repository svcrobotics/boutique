module ClientsHelper
  def total_a_verser(client)
    client.produits.where(en_depot: true, vendu: true).sum(:prix_deposant).round(2)
  end
end
