module TentD
  module Model
    class User

      # Automigrate custom fields
      unless ([:status_app_id, :admin_app_id] - User.columns).empty?
        Post.db.alter_table(:users) do
          add_column :status_app_id, 'bigint'
          add_column :admin_app_id, 'bigint'
        end

        # Load newly created columns
        User.send(:set_columns, User.db[:users].naked.columns)
      end

    end
  end
end
