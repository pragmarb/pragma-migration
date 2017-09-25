module API
  module V1
    module User
      module Migration
        class ChangeCreatedAtFromStringToInteger < Pragma::Migration::Base
          affects API::V1::User::Decorator::Instance do |migration|
            # From old decorator value:
            migration.translate_property :created_at do |old_value|
              Time.zone.parse(old_value).to_i
            end

            # Or, from model attribute:
            migration.remove_property :created_at

            # This can be done without a migration.
            # Adding a property is not a backwards-incompatible change.
            migration.add_property :created_at do |represented|
              represented.created_at.to_i
            end
          end

          affects API::V1::User::Contract::Base do |migration|
            # From old contract value:
            migration.translate_property :created_at do |old_value|
              Time.zone.parse(old_value).to_i
            end
          end
        end
      end
    end
  end
end
