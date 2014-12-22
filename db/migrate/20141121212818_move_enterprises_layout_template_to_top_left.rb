class MoveEnterprisesLayoutTemplateToTopLeft < ActiveRecord::Migration

  ThemesGlob = '{cirandas-green,tantascores-*,modernista*,template,ees,coral*,borboleta*}'

  def up
    themes = Dir.glob "#{Rails.root}/public/designs/themes/#{ThemesGlob}"
    themes = themes.map{ |t| File.basename t }

    ActiveRecord::Base.transaction do
      Enterprise.where(theme: themes, enabled: true).find_each do |enterprise|
        boxes = enterprise.boxes
        main_box = boxes.find{ |b| b.position == 1 }
        left_box = boxes.find{ |b| b.position == 2 }
        top_box = boxes.find{ |b| b.position == 3 }
        top_box.blocks.destroy_all

        links_block = main_box.blocks.find{ |b| b.is_a? LinkListBlock }
        unless links_block
          links_block = left_box.blocks.find{ |b| b.is_a? LinkListBlock }
        end

        if enterprise.theme == 'cirandas-green'
          enterprise.theme = 'ees'
          enterprise.custom_header ||= ''
          enterprise.custom_header += '<img src="/designs/themes/ees/images/paisagem.jpg"/>'
        end

        enterprise.layout_template = 'topleft'
        enterprise.save!
        unless links_block
          puts "FAILED to find LinkListBlock on #{enterprise.identifier}"
          next
        end

        links_block.remove_from_list
        links_block.box = top_box
        links_block.insert_at 0
        links_block.save!
      end
    end

  end

  def down
    say "this migration can't be reverted"
  end

end
