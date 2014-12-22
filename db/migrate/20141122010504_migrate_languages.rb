class ArticleVersion < ActiveRecord::Base
end

class MigrateLanguages < ActiveRecord::Migration
  Models = [Article, ArticleVersion]
  def up
    Models.each do |model|
      model.where(language: 'en').update_all language: 'en_US'
      model.where(language: 'pt').update_all language: 'pt_BR'
      model.where(language: 'es').update_all language: 'es_ES'
      model.where(language: 'fr').update_all language: 'fr_FR'
      model.where(language: 'hy').update_all language: 'hy_AM'
      model.where(language: 'de').update_all language: 'de_DE'
      model.where(language: 'ru').update_all language: 'ru_RU'
      model.where(language: 'it').update_all language: 'it_IT'
    end
  end

  def down
  end
end
