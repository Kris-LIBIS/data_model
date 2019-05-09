# frozen_string_literal: true

require 'teneo/data_model'

module Teneo::DataModel::IngestAgreement::Contract

  class Create < Base

    property :organization_id
    property :name
    property :project_name
    property :collection_name
    property :contact_ingest
    property :contact_collection
    property :contact_system
    property :collection_description
    property :ingest_job_name
    property :collector
    property :producer_id
    property :material_flow_id

    validation name: :default, inherit: true do
      required(:organization_id).filled {model_exist? Teneo::DataModel::Organization}
      required(:name).filled(:str?) {unique_scope? [:organization_id, :name]}
      optional(:project_name).maybe(:str?)
      optional(:collection_name).maybe(:str?)
      optional(:contact_ingest).maybe {array_of? String}
      optional(:contact_collection).maybe {array_of? String}
      optional(:contact_system).maybe {array_of? String}
      optional(:collection_description).maybe(:str?)
      optional(:ingest_job_name).maybe(:str?)
      optional(:collector).maybe(:str?)
      optional(:producer_id).maybe {model_exist?(Teneo::DataModel::Producer) && matches_inst_code?(Teneo::DataModel::Producer)}
      optional(:material_flow_id).maybe {model_exist?(Teneo::DataModel::MaterialFlow) && matches_inst_code?(Teneo::DataModel::MaterialFlow)}

      # TODO: does not work
      # rule(producer_inst_code: [:organization_id, :producer_id]) do |organization_id, producer_id|
      #   producer_id == nil || begin
      #     org = Teneo::DataModel::Organization.find_by(id: organization_id)
      #     producer = Teneo::DataModel::Producer.find_by(id: producer_id)
      #     org.inst_code == producer.inst_code
      #   end
      # end
      #
      # rule(material_flow_inst_code: [:organization_id, :material_flow_id]) do |organization_id, material_flow_id|
      #   material_flow_id == nil || begin
      #     org = Teneo::DataModel::Organization.find_by(id: organization_id)
      #     material_flow = Teneo::DataModel::MaterialFlow.find_by(id: material_flow_id)
      #     org.inst_code == material_flow.inst_code
      #   end
      # end

    end

  end

end
