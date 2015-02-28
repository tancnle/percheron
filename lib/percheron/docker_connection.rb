module Percheron
  class DockerConnection

    def initialize(config)
      @config = config
    end

    def setup!
      set_url!
      set_options!
    end

    private

      attr_reader :config

      def cert_path
        @cert_path ||= ENV['DOCKER_CERT_PATH'] ? File.expand_path(ENV['DOCKER_CERT_PATH']) : nil
      end

      def set_url!
        Docker.url = config.docker.host
      end

      def set_options!
        Docker.options = docker_options
      end

      def docker_options
        base_docker_options.merge(extra_docker_opts)
      end

      def base_docker_options
        {
          connect_timeout:  config.docker.timeout,
          scheme:          'https'
        }
      end

      def extra_docker_opts
        if cert_path
          {
            client_cert:  File.join(cert_path, 'cert.pem'),
            client_key:   File.join(cert_path, 'key.pem'),
            ssl_ca_file:  File.join(cert_path, 'ca.pem')
          }
        else
          {}
        end
      end

  end
end
