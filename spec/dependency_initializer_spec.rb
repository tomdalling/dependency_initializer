require "spec_helper"

RSpec.describe DependencyInitializer do
  class FarmBase
    attr_reader :base_init_was_called
    def initialize
      @base_init_was_called = true
    end
  end

  class Farm < FarmBase
    include DependencyInitializer[:cat, 'dog', rabbit: 'animal.rabbit']

    attr_reader :farm_init_was_called

    def initialize(*args)
      super
      @farm_init_was_called = true
    end
  end

  it 'exposes the declared dependencies' do
    expect(Farm::DECLARED_DEPENDENCIES).to eq({
      cat: :cat,
      dog: 'dog',
      rabbit: 'animal.rabbit',
    })
  end

  it 'extracts the dependencies using #[] on the intializer argument' do
    deps = double
    expect(deps).to receive(:[]).with(:cat)
    expect(deps).to receive(:[]).with('dog')
    expect(deps).to receive(:[]).with('animal.rabbit')

    farm = Farm.new(deps)
  end

  it 'creates an attr_reader for each dependency' do
    farm = Farm.new({
      cat: 'meow',
      'dog' => 'woof',
      'animal.rabbit' => 'twitch'
    })

    expect(farm).to have_attributes(
      cat: 'meow',
      dog: 'woof',
      rabbit: 'twitch',
    )
  end

  it 'calls #initialize on the superclass with no args' do
    expect(Farm.new({}).base_init_was_called).to be(true)
  end

  describe 'Inheritance behaviour' do
    class OldMcDonaldsFarm < Farm
      include DependencyInitializer[:eieio, rabbit: 'bugsbunny']
    end

    it 'allows attributes to be overwritten in subclasses' do
      farm = OldMcDonaldsFarm.new(
        'bugsbunny' => 'child_class',
        'animal.rabbit' => 'superclass'
      )

      expect(farm.rabbit).to eq('child_class')
    end

    it 'does not expose ancestor class declarations' do
      expect(OldMcDonaldsFarm::DECLARED_DEPENDENCIES) == {
        eieio: :eieio,
        rabbit: 'bugsbunny',
      }
    end

    it 'provides a way to get declared dependencies for ALL ancestors' do
      expect(DependencyInitializer.dependencies_for(OldMcDonaldsFarm)).to eq({
        cat: :cat,
        dog: 'dog',
        eieio: :eieio,
        rabbit: 'bugsbunny',
      })
    end

    it 'calls #initialize on the superclass' do
      omd_farm = OldMcDonaldsFarm.new({})
      expect(omd_farm.base_init_was_called).to be(true)
      expect(omd_farm.farm_init_was_called).to be(true)
    end
  end

end

