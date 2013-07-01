module DataMapper
  module Validations
    class ValidationErrors

      def keyed
        errors.to_hash
      end

    end
  end
end