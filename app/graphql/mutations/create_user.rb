module Mutations
    class CreateUser < BaseMutation
        argument :first_name, String, required: true
        argument :last_name, String, required: true
        argument :email, String, required: true

        field :user, Types::UserType, null: true

        def resolve(first_name:, last_name:, email:)
            user = User.new(first_name: first_name, last_name: last_name, email: email)
            if user.save
                { user: user }
            else
                raise GraphQL::ExecutionError, user.errors.full_messages.join(", ")
            end
        end
    end
end
