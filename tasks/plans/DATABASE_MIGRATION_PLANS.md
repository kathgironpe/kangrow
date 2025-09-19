# Affiliate Marketing Management App

## Problem Statement
- Sites like Rewardful only allow me to create a single campaign for all affiliates.
- I have 20 SaaS apps to promote and build with about 7 apps to ship this year alone.
- I need to grow faster than my competitors via effective engaging onboarding of affiliates into my own affiliate management app.
- Rewardful has limited features and does not even help affiliates with custom banners, use of free APIs for marketing and so on. Initially, I only like affiliate performance tracking to work along with onboarding them well on understanding the company goals and the app goals so they can effectively find leads.


## Project and Tecnical Overview
- We will use Elixir Phoenix 1.8.1 and Elixir version Elixir 1.19.0-rc.0 which is way faster for compilation of complex apps now. https://hexdocs.pm/elixir/1.19.0-rc.0/changelog.html
- Each affiliate will have a unique coupon code every time a new campaign is created. This is how Rewardful works. It generates a unique coupon code per campaign and per affiliate.
- When affiliates join a new campaign, they get a unique coupon code for that campaign tied to a SaaS application of the company. They have a minimum 30% recurring revenue for every referral.
- When their referral cancels, unfortunately they have to be notified about the cancellation.
- We will have 20 Core Elixir Phoenix APIs, 1 Payments API in Elixir Phoenix and 1 Affiliates Management App called KanGrow
- This KanGrow app should use Phoenix Gen Auth. Security should be a priority. I have working code for the authentication but everything else needs work.
- We use PostgreSQL 18 Beta2 in production with UUIDv7 for all primary and secondary IDs

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
      add :approved_affiliate, :boolean, default: false, null: false
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

## Basic Features
- An affiliate can sign up as a user
- An affiliate needs to verify the email
- An affiliate needs to be approved after email verification. This requires a new boolean field on `users` called `approved_affiliate`.
- There will be a `super_admin` user or `admin_user` managing all records using Kaffy on `/admin` route. That is even safer.

## Tasks
- [ ] Focus on database design
- [ ] Understand the business requirements of campaign creation, coupon code tracking and so on
- [ ] Detail database design in MERMAID format ONLY with complete description of tables and fields
- [ ] At the moment we can only support PayPal for mass payouts and the minimum withdrawal threshold is $100