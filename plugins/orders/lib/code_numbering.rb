module CodeNumbering
  module ClassMethods
    def code_numbering field, options = {}
      cattr_accessor :code_numbering_field
      cattr_accessor :code_numbering_options

      self.code_numbering_field = field
      self.code_numbering_options = options

      before_create :create_code_numbering

      include CodeNumbering::InstanceMethods
    end
  end

  module InstanceMethods
    def code
      self.attributes[self.code_numbering_field.to_s]
    end

    def create_code_numbering
      scope = self.code_numbering_options[:scope]

      max = code_numbering_options[:start] || 0
      max = case scope
            when Symbol
              self.send(scope).maximum self.code_numbering_field
            when Proc
              instance_exec(&scope).maximum self.code_numbering_field
            end || 0 rescue nil if scope
      max ||= self.class.maximum self.code_numbering_field

      self.send "#{code_numbering_field}=", max+1
    end
  end
end

ActiveRecord::Base.extend CodeNumbering::ClassMethods
