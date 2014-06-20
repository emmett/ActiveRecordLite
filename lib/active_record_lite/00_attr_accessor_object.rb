class AttrAccessorObject
  def self.my_attr_accessor(*names)
		ivar_names = names.map{ |name| name.to_s }
		ivar_names.each do |name|
			define_method name do
				instance_variable_get("@#{name}")
			end
			
			define_method "#{name}=" do |arg|
				instance_variable_set("@#{name}", arg)
			end
		end
  end
end
