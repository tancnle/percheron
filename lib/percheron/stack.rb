module Percheron
  class Stack

    extend Forwardable

    def_delegators :stack_config, :name, :description

    def initialize(config, stack_name)
      @config = config
      @stack_name = stack_name
      valid?
      self
    end

    def self.all(config)
      all = {}
      config.stacks.each do |stack_name, _|
        stack = new(config, stack_name)
        all[stack.name] = stack
      end
      all
    end

    def self.get(config, stack_name)
      if stack = all(config)[stack_name]
        { stack.name => stack }
      else
        {}
      end
    end

    def container_configs
      stack_config.containers.inject({}) do |all, container|
        all[container.name] = container unless all[container.name]
        all
      end
    end

    def containers
      containers = {}
      stack_config.containers.each do |container|
        container = Container::Main.new(config, self, container.name)
        containers[container.name] = container
      end
      containers
    end

    def stop!
      exec_on_containers { |container| container.stop! }
    end

    def start!
      exec_on_containers { |container| container.start! }
    end

    def restart!
      exec_on_containers { |container| container.restart! }
    end

    def create!
      exec_on_containers { |container| container.create! }
    end

    def recreate!(bypass_auto_recreate: false)
      exec_on_containers { |container| container.recreate!(bypass_auto_recreate: bypass_auto_recreate) }
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    private

      attr_reader :config, :stack_name

      def stack_config
        @stack_config ||= config.stacks[stack_name] || Hashie::Mash.new({})
      end

      def exec_on_containers
        containers.each do |container_name, container|
          yield(container)
        end
      end
  end
end
