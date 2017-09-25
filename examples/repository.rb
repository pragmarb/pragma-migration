module API
  module V1
    class MigrationRepository < Pragma::Migration::Repository
      # How do we define version ordering? Just by name?

      version '2017-09-25', [
        API::V1::User::Migration::ChangeCreatedAtFromStringToInteger,
        # ...
      ]

      version '2017-09-18', [
        API::V1::Post::Migration::RemoveEmbeddedComments,
        # ...
      ]
    end
  end
end
