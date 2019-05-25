# frozen_string_literal: true

class DbSetup < ActiveRecord::Migration[5.2]

  # noinspection RubyResolve
  def change

    # Users and Organizations
    # #######################

    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :users do |t|
      t.string :uuid, null: false, index: {unique: true}
      t.string :email, null: false, default: '', index: {unique: true}

      t.string :first_name
      t.string :last_name

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :organizations do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :inst_code, null: false
      t.string :ingest_dir
      t.string :description

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :storages do |t|
      t.string :name, null: false
      t.string :protocol, null: false
      t.jsonb :options, default: {}

      t.column :lock_version, :integer, null: false, default: 0

      t.index [:organization_id, :name], unique: true

      t.references :organization, foreign_key: true, null: false
    end

    create_table :memberships do |t|
      t.string :role, null: false
      t.references :user, foreign_key: true, null: false
      t.references :organization, foreign_key: true, null: false

      t.index [:user_id, :organization_id, :role], unique: true

      t.column :lock_version, :integer, null: false, default: 0
    end

    # Code tables
    # ###########

    create_table :material_flows do |t|
      t.string :name, null: false
      t.string :ext_id, null: false
      t.string :inst_code
      t.string :description

      t.index [:inst_code, :name], unique: true

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :producers do |t|
      t.string :name, null: false
      t.string :ext_id, null: false
      t.string :inst_code, null: false
      t.string :description
      t.string :agent, null: false
      t.string :password, null: false

      t.index [:inst_code, :name], unique: true

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :retention_policies do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :ext_id, null: false
      t.string :description

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :access_rights do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :ext_id, null: false
      t.string :description

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :representation_infos do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :preservation_type, null: false, index: true
      t.string :usage_type, null: false
      t.string :representation_code

      t.column :lock_version, :integer, null: false, default: 0
    end

    # Converters
    # ##########

    create_table :converters do |t|
      t.string :name
      t.string :description
      t.string :class_name
      t.string :script_name
      t.jsonb :parameters, default: {}

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0
    end

    # Workflows
    # #########

    create_table :workflows do |t|
      t.string :stage
      t.string :name
      t.string :description
      t.jsonb :tasks, array: true, default: []
      t.jsonb :inputs, array: true, default: []

      t.index :tasks, using: :gin
      t.index :inputs, using: :gin

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0
    end

    # Ingest Agreements
    # #################

    create_table :ingest_agreements do |t|
      t.string :name, null: false
      t.string :project_name
      t.string :collection_name
      t.string :contact_ingest, array: true
      t.string :contact_collection, array: true
      t.string :contact_system, array: true
      t.string :collection_description
      t.string :ingest_job_name
      t.string :collector

      t.references :producer, foreign_key: true
      t.references :material_flow, foreign_key: true

      t.references :organization, foreign_key: true, null: false

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0

      t.index [:organization_id, :name], unique: true
    end

    # Ingest Models, Manifestations and ConversionJobs
    # ################################################

    create_table :ingest_models do |t|
      t.string :name, null: false
      t.string :description
      t.string :entity_type
      t.string :user_a
      t.string :user_b
      t.string :user_c
      t.string :identifier
      t.string :status

      t.references :access_right, foreign_key: true, null: false
      t.references :retention_policy, foreign_key: true, null: false

      t.references :ingest_agreement, foreign_key: true, null: true

      t.references :template, foreign_key: {to_table: :ingest_models}

      t.index [:ingest_agreement_id, :name], unique: true

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :manifestations do |t|
      t.integer :position, null: false
      t.string :label, null: false
      t.boolean :optional, default: false

      t.references :access_right, foreign_key: true
      t.references :representation_info, foreign_key: true, null: false

      t.references :from, foreign_key: {to_table: :manifestations}
      t.references :ingest_model, foreign_key: true, null: false

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0

      t.index [:ingest_model_id, :position], unique: true
      t.index [:ingest_model_id, :label], unique: true
    end

    create_table :conversion_jobs do |t|
      t.string :name, null: false
      t.integer :position, null: false
      t.string :format_filter
      t.string :filename_filter
      t.jsonb :config, default: {}

      t.references :manifestation, foreign_key: true
      t.references :converter, foreign_key: true

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0

      t.index [:manifestation_id, :name], unique: true
      t.index [:manifestation_id, :position], unique: true
      t.index :config, using: :gin

    end

    # Ingest Jobs
    # ###########

    create_table :ingest_jobs do |t|
      t.integer :stage, null: false
      t.jsonb :config, default: {}

      t.references :ingest_agreement, foreign_key: true
      t.references :workflow, foreign_key: true

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0

      t.index [:ingest_agreement_id, :stage], unique: true
      t.index :config, using: :gin
    end

    # Packages and Items
    # ##################

    create_table :packages do |t|
      t.string :name, null: false
      t.string :stage
      t.string :status
      t.string :base_dir
      t.jsonb :config, default: {}

      t.references :ingest_agreement, foreign_key: true, null: false

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :items do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :label

      t.references :parent, foreign_key: {to_table: :items, on_delete: :cascade}
      t.references :package, foreign_key: {on_delete: :cascade}

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :status_logs do |t|
      t.string :task
      t.string :status
      t.integer :progess
      t.integer :max

      t.references :item, foreign_key: {on_delete: :cascade}

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}
    end

    # Formats database
    # ################

    create_table :formats do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :category, null: false
      t.string :description
      t.string :mime_types, array: true, null: false
      t.string :puids, array: true
      t.string :extensions, array: true, null: false

      t.timestamps default: -> {'CURRENT_TIMESTAMP'}

      t.index :mime_types, using: :gin
      t.index :puids, using: :gin
      t.index :extensions, using: :gin
    end

  end
end
