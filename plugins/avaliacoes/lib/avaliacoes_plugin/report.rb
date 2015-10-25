module AvaliacoesPlugin::Report

  EssayWeight = 0.6
  MCWeight = 0.4

  def self.grades profiles
    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    data = AvaliacoesPlugin::Discipline.map_many profiles
    data.each do |name, discipline|
      discipline.learning_units.each do |learning_unit|
        student = discipline.students.max_by{ |s| learning_unit.student = s; learning_unit.essay_grades.size }
        learning_unit.student = student
        learning_unit.essay_max = learning_unit.essay_grades.size
      end

      discipline_style = wb.styles.add_style sz: 12
      wb.add_worksheet name: discipline.name do |sheet|
        crow = ccol = 1
        d_size = discipline.learning_units.sum{ |u| u.essay_max*2 } + discipline.learning_units.size*(1+1+2) - 1 # why - 1 ?
        sheet.add_row ['Alunas/os', discipline.name] + [nil]*d_size + ['Nota', 'Frequência'], style: discipline_style
        sheet.merge_cells range(ccol..ccol, crow..crow+3)
        sheet.merge_cells range(ccol+1..ccol+1+d_size, crow..crow)
        sheet.merge_cells range(ccol+d_size+2..ccol+d_size+2, crow..crow+3)
        sheet.merge_cells range(ccol+d_size+3..ccol+d_size+3, crow..crow+3)

        crow += 1; ccol = 2; row = [nil]*(ccol-1)
        units = []
        essays_mcs = []
        essays_numbers = []
        merges = []
        discipline.learning_units.each do |learning_unit|
          essay_size = learning_unit.essay_max*2+1
          size = essay_size + 1 + 2

          units.concat [learning_unit.name] + [nil]*(size-1)
          merges << range(ccol..ccol+size-1, crow..crow)

          essays_mcs.concat ['Dissertativas'] + [nil]*(essay_size-1) +
                            ['Objetivas', 'Nota', 'Frequência']
          merges << range(ccol..ccol+essay_size-1, crow+1..crow+1)
          merges << range(ccol+essay_size..ccol+essay_size, crow+1..crow+2)

          v = (1..learning_unit.essay_max).to_a
          vc = v.map{ |n| "#{n}A" }; v = v.zip(vc).flatten
          essays_numbers.concat v + ['Média'] + [nil]*(1+2)

          ccol += size
        end
        sheet.add_row row+units; crow += 1
        sheet.add_row row+essays_mcs; crow += 1
        sheet.add_row row+essays_numbers; crow += 1
        merges.each{ |m| sheet.merge_cells m }

        discipline.students.each do |student|
          ccol = 1; row = [nil]*(ccol-1)
          grades = [student.name]; ccol += 1
          units_grade_cells = []

          discipline.learning_units.each do |learning_unit|
            learning_unit.student = student

            v = learning_unit.essay_grades.map &:grade
            v.concat [0]*(learning_unit.essay_max - v.size)
            vf = v.map.with_index do |x,i|
              c = cell ccol+i*2,crow
              "=IF(#{c}>=9,\"Ótimo\",IF(AND(#{c}<=8,9,#{c}>=7,5),\"Bom\",IF(AND(#{c}<=7,4,#{c}>=6),\"Satisfatório\",\"Insatisfatório\")))"
            end; v = v.zip(vf).flatten
            grades.concat v; ccol += v.size
            grades << "=AVERAGE(#{(0..v.size-1).step(2).to_a.map{ |c| cell ccol-v.size+c,crow }.join ','})"
            essay_avg = ccol; ccol += 1

            v = learning_unit.multiple_choice_grades.map &:grade
            grades << if v.blank? then 0 else "=AVERAGE(#{v.join ','})" end
            mc_avg = ccol; ccol += 1

            units_grade_cells << [ccol,crow]
            grades << "=#{cell essay_avg,crow}*#{EssayWeight} + #{cell mc_avg,crow}*#{MCWeight}"; ccol += 1
            grades << "=IF(#{cell ccol-1,crow} > 0, 100, 0)"; ccol += 1
          end

          grades << "=AVERAGE(#{units_grade_cells.map{ |c,r| cell c,r }.join ','})"; ccol += 1
          grades << "=AVERAGE(#{units_grade_cells.map{ |c,r| cell c+1,r }.join ','})"; ccol += 1
          sheet.add_row row+grades; crow += 1
        end
      end
    end

    report_file = "#{Dir.mktmpdir 'noosfero-'}/report.xlsx"
    p.serialize report_file
    report_file
  end

  private

  def self.cell _c, r
    c = "#{'A'*(_c/27)} "; c.setbyte(-1, _c%27 - if _c < 27 then 1 else 0 end + 'A'.bytes.first)
    "#{c}#{r}"
  end
  def self.range c, r
    "#{cell c.begin, r.begin}:#{cell c.end, r.end}"
  end

end
