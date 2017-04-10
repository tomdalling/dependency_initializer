module DependencyInitializer
  InvalidDependency = Class.new(StandardError)
  MissingDependency = Class.new(StandardError)

  def self.[](*deps_input)
    declared_deps = standardize_deps(deps_input)
    Module.new do |mod|
      const_set(:DECLARED_DEPENDENCIES, declared_deps)
      declared_deps.each { |attr, _| attr_reader(attr) }

      # Accepts a single hash of dependencies
      define_method(:initialize) do |given_deps|
        # call super
        superclass = self.class.ancestors.drop_while{ |c| c != mod }[1]
        if superclass.const_defined?(:DECLARED_DEPENDENCIES)
          super(given_deps)
        else
          super()
        end

        # set attributes
        declared_deps.each do |attr, lookup_key|
          instance_variable_set("@#{attr}", given_deps[lookup_key])
        end
      end

      # Gives the module a nicer name, something like Whatever::DependencyInitializerMixin
      # instead of #<Module 0xA3B4C5939393>
      def self.included(descendant)
        descendant.const_set(:DependencyInitializerMixin, self)
      end
    end
  end

  def self.dependencies_for(klass)
    klass
      .ancestors
      .reverse
      .select { |k| k.const_defined?(:DECLARED_DEPENDENCIES, false)}
      .map{ |k| k::DECLARED_DEPENDENCIES }
      .reduce({}, &:merge!)
  end

  def self.standardize_deps(deps_input)
    deps_input.map do |dep|
      case dep
      when Hash then dep.map{ |k, v| [k.to_sym, v] }.to_h
      when Symbol then { dep => dep }
      when String then { dep.to_sym => dep }
      else raise InvalidDependency, "Invalid dependency: #{dep.inspect}"
      end
    end.reduce({}, :merge!)
  end
end
