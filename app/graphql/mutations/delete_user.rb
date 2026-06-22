module Mutations
    class DeleteUser < BaseMutation
        argument :id, ID

        field :user, Types::UserType, null: true

        def resolve(id:)
            user = User.find_by(id: id)
            raise GraphQL::ExecutionError, "User not found with id: #{id}" unless user

            if user.destroy
                { user: user }
            else
                raise GraphQL::ExecutionError, user.errors.full_messages.join(",")
            end
        end
    end
end
