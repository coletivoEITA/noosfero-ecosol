# table does not exist, but should
class AvaliacoesPlugin::Discipline

  include ActiveModel::AttributeMethods
  include ActiveModel::Serialization

  #self.table_name = :grup

  attr_accessor :name
  attr_accessor :student
  attr_accessor :learning_units

  def self.map student
    student.discipline_units.includes(:learning_unit).distinct.group_by(&:name).map do |name, discipline_units|
      d = self.new
      d.name = name
      d.student = student
      d.learning_units = discipline_units.map(&:learning_unit)
      d.learning_units.each{ |u| u.student = student }
      d
    end
  end

end
