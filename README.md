# DependencyInitializer

:notes: I have a class :notes:

```ruby
require 'dependency_initializer'

class Barn
  include DependencyInitializer[
    :pig,
    chicken: 'poultry.chicken',
  ]
end
```

:notes: I have dependencies :notes:

```ruby
dependencies = {
  :pig => 'oink',
  'poultry.chicken' => 'cluck',
}
```

:notes: Uhng, initialized object :notes:

```ruby
barn = Barn.new(dependencies)
barn.pig #=> 'oink'
barn.chicken #=> 'cluck'
```

(See the tests for better docs)
