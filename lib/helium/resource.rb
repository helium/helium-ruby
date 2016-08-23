module Helium
  # Abstract base class for Helium Resources returned by the API
  class Resource
    attr_reader :id

    def initialize(client:, params:)
      @client     = client
      @id         = params["id"]
      @created_at = params.dig('meta', 'created')
      @updated_at = params.dig('meta', 'updated')
    end

    class << self
      def resource_name
        self.name.split('::').last.downcase
      end

      # TODO seems a bit out of place to be doing client work here, but it
      # makes sense for the Eigenclass to be responsable for constructing
      # instances of its inheriting class.

      # Returns all resources
      # @return [Array<Resource>] an Array of all of the inheriting Resource
      def all(client:)
        response = client.get("/#{resource_name}")
        resources_data = JSON.parse(response.body)["data"]

        resources = resources_data.map do |resource_data|
          self.new(client: client, params: resource_data)
        end

        return resources
      end

      # Finds a single Resource by id
      # @return [Resource]
      def find(id, client:)
        response = client.get("/#{resource_name}/#{id}")
        resource_data = JSON.parse(response.body)["data"]

        return self.new(client: client, params: resource_data)
      end

      def create(attributes, client:)
        path = "/#{resource_name}"

        body = {
          data: {
            attributes: attributes,
            type: resource_name
          }
        }

        response = client.post(path, body: body)
        resource_data = JSON.parse(response.body)["data"]

        return self.new(client: client, params: resource_data)
      end
    end # << self

    # Override equality to use id for comparisons
    # @return [Boolean]
    def ==(other)
      self.id == other.id
    end

    # Override equality to use id for comparisons
    # @return [Boolean]
    def eql?(other)
      self == other
    end

    # Override equality to use id for comparisons
    # @return [Integer]
    def hash
      id.hash
    end

    # @return [DateTime, nil] when the resource was created
    def created_at
      return nil if @created_at.nil?
      @_created_at ||= DateTime.parse(@created_at)
    end

    # @return [DateTime, nil] when the resource was last updated
    def updated_at
      return nil if @updated_at.nil?
      @_updated_at ||= DateTime.parse(@updated_at)
    end

    # Inheriting resources should implement this with super
    # @return [Hash] a Hash of the object's attributes for JSON
    def as_json
      {
        id: id,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    # @return [String] a JSON-encoded String representing the resource
    def to_json(*options)
      as_json.to_json(*options)
    end
  end
end
