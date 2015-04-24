class ArticleVersion < ActiveRecord::Base
end

class MigrateLanguages < ActiveRecord::Migration
  MAP = {
    'en' => 'en_US',
    'pt' => 'pt_BR',
    'fr' => 'fr_FR',
    'hy' => 'hy_AM',
    'de' => 'de_DE',
    'ru' => 'ru_RU',
    'es' => 'es_ES',
    'it' => 'it_IT',
  }
  MODELS = [Article, ArticleVersion]
  def up
    MODELS.each do |model|
      MAP.each do |from, to|
        model.where(language: from).update_all language: to
      end
    end
    # language is serialized on block
    Block.find_each batch_size: 50 do |block|
      new_language = MAP[block.language]
      next if new_language.blank?
      block.update_attribute :language, new_language
    end
  end

  def down
  end
end
