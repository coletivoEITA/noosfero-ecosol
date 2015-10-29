module AvaliacoesPlugin::Report

  EssayWeight = 0.6
  MCWeight = 0.4

  module Styles
    Default = {sz: 10, border: 1, alignment: {horizontal: :left, vertical: :center, wrap_text: true}}
    Header = Default.merge fg_color: 'FFFFFF', b: true, border: 1, alignment: {horizontal: :center}
    Header1 = Header.merge bg_color: '604A7B'
    Header2 = Header.merge bg_color: '7030A0'
    Header3 = Header.merge bg_color: '403152'
    Header4 = Header.merge bg_color: 'B3A2C7', fg_color: '000000'
    StudentHeader = Header1
    QuestionType = Header1
    Discipline = Header2
    Units = Header3
    Question = Header4
    Student = Default.merge b: true
    Grade = Default.merge alignment: {horizontal: :center}, format_code: "0.##"
    FinalGrade = Grade.merge b: true
  end
  module Widths
    Student = 30
    Grade = 7
    FinalGrade = 10
  end

  def self.grades profiles
    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    discipline_style = wb.styles.add_style Styles::Discipline
    student_header_style = wb.styles.add_style Styles::StudentHeader
    units_style = wb.styles.add_style Styles::Units
    question_type_style = wb.styles.add_style Styles::QuestionType
    question_style = wb.styles.add_style Styles::Question
    student_style = wb.styles.add_style Styles::Student
    grade_style = wb.styles.add_style Styles::Grade
    final_grade_style = wb.styles.add_style Styles::FinalGrade

    data = AvaliacoesPlugin::Discipline.map_many profiles
    data.each do |name, discipline|
      discipline.learning_units.each do |learning_unit|
        student = discipline.students.max_by{ |s| learning_unit.student = s; learning_unit.essay_grades.size }
        learning_unit.student = student
        learning_unit.essay_max = learning_unit.essay_grades.size
      end

      wb.add_worksheet name: discipline.name do |sheet|
        widths = []
        crow = ccol = 1

        d_size = discipline.learning_units.sum{ |u| u.essay_max*2 } + discipline.learning_units.size*(1+1+2) - 1 # why - 1 ?
        sheet.add_row ['ALUNAS/OS', discipline.name] + [nil]*d_size + ['Nota', 'Frequência'],
          style: [student_header_style] + [discipline_style]*(d_size+3)
        sheet.merge_cells range(ccol..ccol, crow..crow+3)
        sheet.merge_cells range(ccol+1..ccol+1+d_size, crow..crow)
        sheet.merge_cells range(ccol+d_size+2..ccol+d_size+2, crow..crow+3)
        sheet.merge_cells range(ccol+d_size+3..ccol+d_size+3, crow..crow+3)
        widths << Widths::Student

        crow += 1; ccol = 2; row = [nil]*(ccol-1)
        units = []
        essays_mcs = []; essays_mcs_style = []
        essays_numbers = []; essays_numbers_style = []
        merges = []
        discipline.learning_units.each do |learning_unit|
          essay_size = learning_unit.essay_max*2+1
          size = essay_size + 1 + 2

          units.concat [learning_unit.name] + [nil]*(size-1)
          merges << range(ccol..ccol+size-1, crow..crow)

          essays_mcs.concat ['Dissertativas'] + [nil]*(essay_size-1) +
                            ['Objetivas', 'Nota', 'Frequência']
          essays_mcs_style.concat [question_type_style]*(essay_size+1) + [units_style]*2
          merges << range(ccol..ccol+essay_size-1, crow+1..crow+1)
          merges << range(ccol+essay_size..ccol+essay_size, crow+1..crow+2)
          merges << range(ccol+essay_size+1..ccol+essay_size+1, crow+1..crow+2)
          merges << range(ccol+essay_size+2..ccol+essay_size+2, crow+1..crow+2)

          v = (1..learning_unit.essay_max).to_a
          vc = v.map{ |n| "#{n}A" }; v = v.zip(vc).flatten
          essays_numbers.concat v + ['Média'] + [nil]*(1+2)
          essays_numbers_style.concat [question_style]*(v.size+1) + [nil]*(1+2)

          ccol += size
        end
        sheet.add_row row+units, style: units_style; crow += 1
        sheet.add_row row+essays_mcs, style: row+essays_mcs_style; crow += 1
        sheet.add_row row+essays_numbers, style: row+essays_numbers_style; crow += 1
        merges.each{ |m| sheet.merge_cells m }

        discipline.students.each do |student|
          ccol = 1; row = [nil]*(ccol-1)
          grades = [student.name]; ccol += 1
          grades_style = [student_style]
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
            grades_style.concat [grade_style]*(learning_unit.essay_max*2+1)
            widths.concat [Widths::Grade]*(learning_unit.essay_max*2+1)

            v = learning_unit.multiple_choice_grades.map &:grade
            grades << if v.blank? then 0 else "=AVERAGE(#{v.join ','})" end
            mc_avg = ccol; ccol += 1
            grades_style.concat [grade_style]
            widths.concat [Widths::Grade]

            units_grade_cells << [ccol,crow]
            grades << "=#{cell essay_avg,crow}*#{EssayWeight} + #{cell mc_avg,crow}*#{MCWeight}"; ccol += 1
            grades << "=IF(#{cell ccol-1,crow} > 0, 100, 0)"; ccol += 1
            grades_style.concat [final_grade_style]*2
            widths.concat [Widths::FinalGrade]*2
          end

          grades << "=AVERAGE(#{units_grade_cells.map{ |c,r| cell c,r }.join ','})"; ccol += 1
          grades << "=AVERAGE(#{units_grade_cells.map{ |c,r| cell c+1,r }.join ','})"; ccol += 1
          grades_style.concat [final_grade_style]*2
          widths.concat [Widths::FinalGrade]*2
          sheet.add_row row+grades, style: grades_style; crow += 1
        end

        sheet.column_widths *widths
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
