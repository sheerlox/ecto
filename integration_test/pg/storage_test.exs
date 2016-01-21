defmodule Ecto.Integration.StorageTest do
  use ExUnit.Case, async: true

  alias Ecto.Adapters.Postgres

  @moduletag :capture_log

  def correct_params do
    Ecto.Repo.Supervisor.parse_url(
      Application.get_env(:ecto, :pg_test_url) <> "/storage_mgt"
    )
  end

  def wrong_user do
    Keyword.merge correct_params,
      [username: "randomuser",
       password: "password1234"]
  end

  def create_database do
    :os.cmd 'psql -U postgres -c "CREATE DATABASE storage_mgt;"'
  end

  def drop_database do
    :os.cmd 'psql -U postgres -c "DROP DATABASE IF EXISTS storage_mgt;"'
  end

  setup do
    on_exit fn -> drop_database end
    :ok
  end

  test "storage up (twice in a row)" do
    assert Postgres.storage_up(correct_params) == :ok
    assert Postgres.storage_up(correct_params) == {:error, :already_up}
  end

  test "storage up (wrong credentials)" do
    assert {:error, msg} = Postgres.storage_up(wrong_user)
    assert msg =~ "FATAL"
  end

  test "storage down (twice in a row)" do
    create_database

    assert Postgres.storage_down(correct_params) == :ok
    assert Postgres.storage_down(correct_params) == {:error, :already_down}
  end
end
