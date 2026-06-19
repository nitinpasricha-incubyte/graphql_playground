module Mutations
    class UpdateUser < BaseMutation
        argument :id, ID, required: true
        argument :first_name, String, required: false
        argument :last_name, String, required: false
        argument :email, String, required: false

        field :user, Types::UserType, null: true

        def resolve(id:, first_name: nil, last_name: nil, email: nil)
            user = User.find(id)
            raise GraphQL::ExecutionError, "User not found" unless user

            attrs = { first_name: first_name, last_name: last_name, email: email }.compact
            if attrs.empty?
                raise GraphQL::ExecutionError, "No attributes to update"
            end

            if user.update(attrs)
                { user: user }
            else
                raise GraphQL::ExecutionError, user.errors.full_messages.join(",")
            end
        end
    end
end
