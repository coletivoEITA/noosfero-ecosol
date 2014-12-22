# from http://stackoverflow.com/questions/1251178/calling-another-method-in-super-class-in-ruby
class SuperProxy
  def initialize obj
    @obj = obj
  end

  def method_missing meth, *args, &blk
    @obj.class.superclass.instance_method(meth).bind(@obj).call(*args, &blk)
  end
end

class Object
  protected

  def sup
    SuperProxy.new self
  end
end
