Sequel.migration do
  change do
    db = self

    extension :date_arithmetic

    deadline_opts = proc do |days|
      {null: false, default: Sequel.date_add(Sequel::CURRENT_TIMESTAMP, days: days)}
    end

    # Used by the account verification and close account features
    create_table(:account_statuses) do
      Integer :id, primary_key: true
      String :name, null: false, unique: true
    end
    from(:account_statuses).import([:id, :name], [[1, "Unverified"], [2, "Verified"], [3, "Closed"]])

    # Accounts base table
    create_table(:accounts) do
      primary_key :id
      String :email, null: false, unique: true
      column :status, Integer, default: 1, null: false
      if db.database_type == :postgres
        constraint :valid_email, email: /^[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+$/
      end
      index :email, unique: true
      foreign_key :status_id, :account_statuses, null: false, default: 1
    end

    # Store the password hashes
    create_table(:account_password_hashes) do
      foreign_key :id, :accounts, primary_key: true

      String :password_hash, text: true, null: false
    end

    # Used by the account verification feature
    create_table(:account_verification_keys) do
      foreign_key :id, :accounts, primary_key: true, type: :Bignum
      String :key, null: false
      DateTime :requested_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :email_last_sent, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    # Used by the password reset feature
    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, primary_key: true, type: :Bignum
      String :key, null: false
      DateTime :deadline, deadline_opts[1]
      DateTime :email_last_sent, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    if db.database_type == :postgres
      user = get(Sequel.lit("current_user")).sub(/_password\z/, "")

      run "REVOKE ALL ON account_password_hashes FROM public"
      run "GRANT INSERT, UPDATE, DELETE ON account_password_hashes TO #{user}"
      run "GRANT SELECT(id) ON account_password_hashes TO #{user}"
    end
  end

  down do
    drop_table(
      :account_password_hashes,
      :account_password_reset_keys,
      :account_verification_keys,
      :accounts,
      :account_statuses
    )
  end
end
