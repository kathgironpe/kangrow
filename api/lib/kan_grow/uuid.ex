defmodule KanGrow.UUID do
  @moduledoc """
  A UUID v7 implementation and `Ecto.Type` for Elixir.

  Based on the RFC for the version 7 UUID: [RFC 9562](https://datatracker.ietf.org/doc/rfc9562/).

  Borrowed from https://github.com/martinthenth/uuidv7

  ## Usage

  In the database schema, change primary key attribute from `:binary_id` to `KanGrow.UUID`:

  ```elixir
  defmodule KanGrow.Schemas.User do
    @primary_key {:id, KanGrow.UUID, autogenerate: true}
  end
  ```
  """

  use Ecto.Type

  @typedoc """
  A hex-encoded UUID string.
  """
  @type t :: <<_::288>>

  @typedoc """
  A raw binary representation of a UUID.
  """
  @type raw :: <<_::128>>

  @doc false
  @spec type() :: :uuid
  def type, do: :uuid

  defdelegate cast(value), to: Ecto.UUID
  defdelegate cast!(value), to: Ecto.UUID
  defdelegate dump(value), to: Ecto.UUID
  defdelegate dump!(value), to: Ecto.UUID
  defdelegate load(value), to: Ecto.UUID
  defdelegate load!(value), to: Ecto.UUID

  @doc false
  @spec autogenerate() :: t()
  def autogenerate, do: generate()

  @doc """
  Generates a version 7 UUID.
  """
  @spec generate() :: t()
  def generate, do: cast!(bingenerate())

  @doc """
  Generates a version 7 UUID based on the timestamp (ms).
  """
  @spec generate(non_neg_integer()) :: t()
  def generate(milliseconds), do: milliseconds |> bingenerate() |> cast!()

  @doc """
  Generates a version 7 UUID in the binary format.
  """
  @spec bingenerate() :: raw()
  def bingenerate, do: :millisecond |> System.system_time() |> bingenerate()

  @doc """
  Generates a version 7 UUID in the binary format based on the timestamp (ms).
  """
  @spec bingenerate(non_neg_integer()) :: raw()
  def bingenerate(milliseconds) do
    <<u1::12, u2::62, _::6>> = :crypto.strong_rand_bytes(10)
    <<milliseconds::48, 7::4, u1::12, 2::2, u2::62>>
  end

  @doc """
  Extracts the timestamp (ms) from the version 7 UUID.
  """
  @spec timestamp(t() | raw()) :: non_neg_integer()
  def timestamp(<<milliseconds::48, 7::4, _::76>>), do: milliseconds
  def timestamp(<<_::288>> = uuid), do: uuid |> dump!() |> timestamp()
end
