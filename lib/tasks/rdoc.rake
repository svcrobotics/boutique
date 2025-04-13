# lib/tasks/rdoc.rake

namespace :doc do
  desc "Génère la documentation RDoc dans public/doc"
  task generate: :environment do
    puts "📘 Génération de la documentation RDoc…"

    tmp_dir = "tmp/rdoc"
    public_dir = "public/doc"

    # Supprimer les anciennes docs
    FileUtils.rm_rf(tmp_dir)
    FileUtils.rm_rf(public_dir)

    # Créer la doc temporairement
    sh "rdoc -o #{tmp_dir} app/controllers"

    # Déplacer dans public
    FileUtils.mkdir_p(public_dir)
    FileUtils.cp_r("#{tmp_dir}/.", public_dir)

    puts "✅ Documentation générée dans #{public_dir}"
    puts "👉 Ouvre http://localhost:3000/doc/index.html pour la consulter."
  end
end
