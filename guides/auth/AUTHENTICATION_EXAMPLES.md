# Authentication Migrations

```elixir
defmodule KanGrow.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuidv7()")
      add :email, :citext, null: false
      add :email_verified, :boolean, default: false, null: false
      add :first_name, :string
      add :last_name, :string
      add :hashed_password, :string, null: true
      add :identities, :map, null: true
      add :avatar_url, :string
      add :last_login, :utc_datetime
      add :last_ip, :string
      add :last_password_reset, :utc_datetime
      add :logins_count, :integer, default: 0, null: false
      add :verified, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false
      add :blocked, :boolean, default: false, null: false
      add :reset_password_token, :string
      # More precise with microseconds
      add :reset_password_sent_at, :utc_datetime_usec
      add :confirmed_at, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime, inserted_at: :created_at)
    end

    create unique_index(:users, [:email])
    create index(:users, [:banned])

    create index(:users, [:reset_password_token],
             where: "reset_password_sent_at IS NOT NULL",
             name: "users_reset_password_token_index"
           )
  end
end

defmodule KanGrow.Repo.Migrations.CreateUsersTokens do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuidv7()")
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false, inserted_at: :created_at)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end

defmodule KanGrow.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuidv7()")
      add :token, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :expires_at, :utc_datetime, null: false
      add :revoked, :boolean, default: false, null: false
      add :device_info, :string  # Optional: for device tracking
      add :last_used_at, :utc_datetime

      timestamps(type: :utc_datetime, inserted_at: :created_at)
    end

    create unique_index(:refresh_tokens, [:token])
    create index(:refresh_tokens, [:user_id])
    create index(:refresh_tokens, [:expires_at])
    create index(:refresh_tokens, [:user_id, :revoked])
  end
end

```