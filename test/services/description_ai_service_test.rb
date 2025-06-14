# test/services/description_ai_service_test.rb
require "test_helper"

class DescriptionAiServiceTest < ActiveSupport::TestCase
  test "returns a non-empty response from OpenAI" do
    service = DescriptionAiService.new("Pantalon fluide taille haute")
    result = service.generate

    puts "OpenAI result: #{result}" # utile si tu veux voir le résultat

    assert result.present?, "La réponse de l'API OpenAI est vide ou nulle"
    assert result.length > 10, "La description générée semble trop courte"
  end
end
