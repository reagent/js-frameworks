module Polymorphism
  def polymorphic_belongs_to(name)
    property :"#{name}_id",   Integer
    property :"#{name}_type", String

    validates_with_method :"#{name}_required", :unless => :"#{name}_set?"

    define_method :"#{name}=" do |resource|
      if resource
        send("#{name}_id=",   resource.id)
        send("#{name}_type=", resource.class.to_s)
      else
        send("#{name}_id=",   nil)
        send("#{name}_type=", nil)
      end
    end

    define_method name.to_sym do
      if send("#{name}_set?")
        send(:"#{name}_type").constantize.get(send(:"#{name}_id"))
      end
    end

    define_method :"#{name}_set?" do
      send(:"#{name}_type") && send(:"#{name}_id")
    end

    define_method :"#{name}_required" do
      errors.add(name.to_sym, 'is required')
    end
  end

  def polymorphic_many(association, options)
    define_method association do
      ivar_name = :"@#{association}"

      if (!instance_variable_defined?(ivar_name))
        klass     = association.to_s.classify.constantize
        id_name   = :"#{options[:as]}_id"
        type_name = :"#{options[:as]}_type"

        instance_variable_set(ivar_name, klass.all(id_name => id, type_name => self.class.to_s))
      end
      instance_variable_get(ivar_name)
    end
  end

end