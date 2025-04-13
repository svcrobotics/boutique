# config/initializers/generate_rdoc.rb

if Rails.const_defined?(:Server)
  Thread.new do
    puts "🔁 Génération automatique de la documentation RDoc..."
    system("bin/rails doc:generate")
    puts "📘 Documentation à jour (http://localhost:3000/doc/index.html)"
  end
end
