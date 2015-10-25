# table does not exist, but should
class AvaliacoesPlugin::Discipline

  include ActiveModel::AttributeMethods
  include ActiveModel::Serialization

  #self.table_name = :grup

  attr_accessor :name
  attr_accessor :learning_units
  attr_accessor :student
  attr_accessor :students

  def self.map student, group=nil
    scope = student.discipline_units.includes(:learning_unit).order('"ID" ASC')
    scope = scope.where 'cursos."Nome" ILIKE ?', "#{group.name}%" if group

    scope.group_by(&:name).map do |name, discipline_units|
      d = self.new
      d.name = name
      d.student = student
      d.learning_units = discipline_units.map &:learning_unit
      d.learning_units.each{ |u| u.student = student }
      d
    end
  end

  def self.map_many profiles, group=nil
    students = AvaliacoesPlugin::Student.where(ID: profiles.map(&:identifier)).
      order('"Nome" ASC').
      includes(discipline_units: :learning_unit).
      includes(grades: :question)
    students = students.where 'cursos."Nome" ILIKE ?', "#{group.name}%" if group

    h = {}
    students.each do |student|
      student.units = {}
      student.discipline_units.group_by(&:name).each do |name, discipline_units|
        d = h[name] ||= begin
          d = self.new
          d.name = name
          d.learning_units = discipline_units.map &:learning_unit
          d.students ||= Set.new
          d
        end
        d.students << student
      end
    end
    h
  end

  def == other
    self.name == self.other
  end

end
