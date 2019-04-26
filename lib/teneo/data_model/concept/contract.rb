# frozen_string_literal: true

require 'teneo/data_model'

require 'reform'
require 'reform/form/dry'
# require 'dry/validation/compat/form'
# require 'dry/types/compat/form_types'


class Teneo::DataModel::Concept::Contract < Reform::Form

  feature Reform::Form::Dry

  # module Types
  #   Dry::Types.module()
  # end

  validation name: :default, with: {form: true} do
    configure do
      # noinspection RubyResolve
      config.messages_file = File.join(Teneo::DataModel.root, 'config', 'errors.yml')

      def is_nil?(value)
        value.nil?
      end

      def not_nil?(value)
        !value.nil?
      end

      def array_of?(type_class, value)
        value.is_a?(Array) && value.all? {|x| x.is_a?(type_class)}
      end

      def unique?(column, _value)
        return true if form.model.nil?
        hash = (column.is_a?(Array) ? column : [column]).inject({}) {|hash, key| hash[key] = form.send(key); hash}
        form.model.class.where.not(id: form.model.id).find_by(hash).nil?
      end

      def exists?(column, value)
        !form.model.class.find_by(Hash[column, value]).nil?
      end
    end
  end

end
