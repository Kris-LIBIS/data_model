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
        return true if value.nil?
        value.is_a?(Array) && value.all? {|x| x.is_a?(type_class)}
      end

      def unique?(column, value)
        return true if form.model.nil?
        query = form.model.class.where.not(id: form.model.id).find_by(column => value)
        query.nil?
      end

      def unique_scope?(columns, value)
        hash = columns.each_with_object({}) do |column, hash|
          hash[column] = form.model.send(column) || form.input_params[column]
        end
        hash[columns.last] = value
        query = form.model.class.where.not(id: form.model.id).find_by(hash)
        query.nil?
      end

      def exists?(column, value)
        !form.model.class.find_by(Hash[column, value]).nil?
      end

      def model_exist?(model, id)
        !model.find_by(id: id).nil?
      end

      def matches_inst_code?(model, id)
        return true if id.nil?
        ref_id = form.model.send(:organization_id) || form.input_params[:organization_id]
        ref_code = Teneo::DataModel::Organization.find_by(id: ref_id)[:inst_code]
        code = model.find_by(id: id)[:inst_code]
        ref_code == code
      end

      def matches_ingest_model?(from_id)
        return true if from_id.nil?
        ref_id = form.model.send(:ingest_model_id) || form.input_params[:ingest_model_id]
        form.model.class.find_by(id: from_id).send(:ingest_model_id) == ref_id
      end

      def from_with_lower_order?(from_id)
        return true if from_id.nil?
        ref_order = form.model.send(:order) || form.input_params[:order]
        form.model.class.find_by(id: from_id).send(:order) < ref_order
      end

      def matches_package?(parent_id)
        return true if parent_id.nil?
        ref_id = form.model.send(:package_id) || form.input_params[:package_id]
        form.model.class.find_by(id: parent_id).send(:package_id) == ref_id
      end

    end
  end

end
