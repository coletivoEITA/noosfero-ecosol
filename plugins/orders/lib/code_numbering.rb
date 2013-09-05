module CodeNumbering
  module ClassMethods
    def code_numbering(field, options = {})
      cattr_accessor :code_numbering_field
      cattr_accessor :code_numbering_options

      self.code_numbering_field = field
      self.code_numbering_options = options

      before_create :create_code_numbering

      include CodeNumbering::InstanceMethods
    end
  end

  module InstanceMethods
    def create_code_numbering
      scope = code_numbering_options[:scope]
      if scope
        max = case scope
              when Symbol
                send(scope).maximum(code_numbering_field)
              when Proc
                instance_eval(&scope).maximum(code_numbering_field)
              end rescue 0
      else
        max = self.class.maximum(code_numbering_field)
      end

      max ||= code_numbering_options[:start] || 0
      send "#{code_numbering_field}=", max+1
    end
  end
end

ActiveRecord::Base.extend CodeNumbering::ClassMethods
