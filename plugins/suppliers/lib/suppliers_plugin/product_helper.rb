module SuppliersPlugin::ProductHelper

  protected

  def supplier_choices profile
    @supplier_choices ||= profile.suppliers.map do |s|
      [s.name, s.id]
    end.sort{ |a,b| a[0].downcase <=> b[0].downcase }
  end

end
