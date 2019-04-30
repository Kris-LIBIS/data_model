# frozen_string_literal: true

class DbSetup < ActiveRecord::Migration[5.2]

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
      t.jsonb :upload_areas

      t.column :lock_version, :integer, null: false, default: 0
    end

    add_index :organizations, :upload_areas, using: :gin

    create_table :memberships do |t|
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true

      t.index [:user_id, :organization_id]

      t.column :lock_version, :integer, null: false, default: 0
    end

    reversible do |change|

      change.up do

        execute <<-SQL
          CREATE TYPE user_role AS ENUM ('uploader', 'ingester', 'admin');
        SQL

        # noinspection RailsParamDefResolve
        add_column :memberships, :role, :user_role, index: true

        # noinspection RailsParamDefResolve
        add_index :memberships, [:user_id, :organization_id, :role], unique: true

      end

      change.down do

        remove_index :memberships, column: [:user_id, :organization_id, :role]

        execute <<-SQL
          DROP TYPE user_role;
        SQL

      end

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
      t.string :usage_type
      t.string :representation_code

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :converters do |t|
      t.string :name
      t.string :description
      t.string :class_name
      t.jsonb :parameters, array: true
    end

    add_index :converters, :parameters, using: :gin

    create_table :workflows do |t|
      t.string :stage
      t.string :name
      t.string :description
      t.jsonb :tasks, array: true
      t.jsonb :inputs, array: true
    end

    add_index :workflows, :tasks, using: :gin
    add_index :workflows, :inputs, using: :gin

    # Ingest Agreements
    # #################

    create_table :ingest_agreements do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :project_name
      t.string :collection_name
      t.string :contact_ingest, array: true
      t.string :contact_collection, array: true
      t.string :contact_system, array: true
      t.string :collection_description
      t.string :ingest_job_name

      t.references :producer, foreign_key: true, null: false
      t.references :material_flow, foreign_key: true, null: false

      t.string :collector

      t.references :organization, foreign_key: true, null: false

      t.column :lock_version, :integer, null: false, default: 0
    end

    # Packages and Items
    # ##################

    create_table :packages do |t|
      t.string :name, null: false
      t.string :stage
      t.string :status
      t.string :base_dir
      t.jsonb :config

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

    # Ingest Models, Manifestations and Conversions
    # #############################################

    create_table :ingest_models do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :description
      t.string :entity_type
      t.string :user_a
      t.string :user_b
      t.string :user_c
      t.string :identifier
      t.string :status

      t.references :access_right, foreign_key: true, null: false
      t.references :retention_policy, foreign_key: true, null: false

      t.references :template, foreign_key: {to_table: :ingest_models}
      t.references :ingest_agreement, foreign_key: true, null: false

      t.column :lock_version, :integer, null: false, default: 0
    end

    create_table :manifestations do |t|
      t.integer :order, null: false, index: true
      t.string :name, null: false
      t.string :label, null: false
      t.boolean :optional, default: false

      t.references :access_right, foreign_key: true
      t.references :representation_info, foreign_key: true, null: false

      t.references :from, foreign_key: {to_table: :manifestations}, null: true
      t.references :ingest_model, foreign_key: true, null: false
    end

    create_table :conversion_jobs do |t|
      t.integer :order, null: false, index: true
      t.string :format_filter
      t.string :filename_filter
      t.jsonb :config

      t.references :manifestation, foreign_key: true
      t.references :converter, foreign_key: true

      t.index :config, using: :gin
    end

    create_table :ingest_jobs do |t|
      t.integer :order, null: false, index: true
      t.jsonb :config

      t.references :ingest_agreement, foreign_key: true
      t.references :workflow, foreign_key: true

      t.index :config, using: :gin
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
