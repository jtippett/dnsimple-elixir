defmodule Dnsimple.Domains do
  @moduledoc """
  This module provides functions to interact with the domain related endpoints.

  See https://developer.dnsimple.com/v2/domains/
  """

  alias Dnsimple.List
  alias Dnsimple.Client
  alias Dnsimple.Response
  alias Dnsimple.Domain

  @doc """
  Lists the domains.

  See https://developer.dnsimple.com/v2/domains/#list

  ## Examples:

    client = %Dnsimple.Client{access_token: "a1b2c3d4"}

    Dnsimple.Domains.list_domains(client, account_id = 1010)
    Dnsimple.Domains.list_domains(client, account_id = 1010, sort: "name:asc")
    Dnsimple.Domains.list_domains(client, account_id = 1010, per_page: 50, page: 4)
    Dnsimple.Domains.list_domains(client, account_id = 1010, filter: [name_like: ".com"])

  """
  @spec list_domains(Client.t, String.t | integer) :: Response.t
  def list_domains(client, account_id, options \\ []) do
    url = Client.versioned("/#{account_id}/domains")

    List.get(client, url, options)
    |> Response.parse(%{"data" => [%Domain{}], "pagination" => %Response.Pagination{}})
  end

  @spec domains(Client.t, String.t | integer) :: Response.t
  defdelegate domains(client, account_id, options \\ []), to: __MODULE__, as: :list_domains


  @doc """
  List all domains from the account. This function will automatically
  page through to the end of the list, returning all domain objects.
  """
  @spec all_domains(Client.t, String.t | integer, Keyword.t) :: [Domain.t]
  def all_domains(client, account_id, options \\ []) do
    new_options = Keyword.merge([page: 1], options)
    all_domains(client, account_id, new_options, [])
  end

  defp all_domains(client, account_id, options, domain_list) do
    {:ok, response} = domains(client, account_id, options)
    all_domains(client, account_id, Keyword.put(options, :page, options[:page] + 1), domain_list ++ response.data, response.pagination.total_pages - options[:page])
  end

  defp all_domains(_, _, _, domain_list, 0) do
    domain_list
  end
  defp all_domains(client, account_id, options, domain_list, _) do
    all_domains(client, account_id, options, domain_list)
  end


  @doc """
  Get a domain.

  See https://developer.dnsimple.com/v2/domains/#get

  ## Examples:

    client = %Dnsimple.Client{access_token: "a1b2c3d4"}

    Dnsimple.Domains.get_domain(client, account_id = 1010, domain_id = 123)
    Dnsimple.Domains.get_domain(client, account_id = 1010, domain_id = "example.com")

  """
  @spec get_domain(Client.t, String.t | integer, String.t | integer, Keyword.t) :: Response.t
  def get_domain(client, account_id, domain_id, options \\ []) do
    url = Client.versioned("/#{account_id}/domains/#{domain_id}")

    Client.get(client, url, options)
    |> Response.parse(%{"data" => %Domain{}})
  end

  @spec domain(Client.t, String.t | integer, String.t | integer, Keyword.t) :: Response.t
  defdelegate domain(client, account_id, domain_id, options \\ []), to: __MODULE__, as: :get_domain


  @doc """
  Creates a new domain in the account.

  This won't register the domain and will only add the domain as hosted. To
  register a domain please use
  [`Dnsimple.Registrar.register_domain`](https://developer.dnsimple.com/v2/registrar/#register).

  See https://developer.dnsimple.com/v2/domains/#create

  ## Examples:

    client = %Dnsimple.Client{access_token: "a1b2c3d4"}

    Dnsimple.Domains.create_domain(client, account_id = 1010, %{name: "example.io"})

  """
  @spec create_domain(Client.t, String.t | integer, map, Keyword.t) :: Response.t
  def create_domain(client, account_id, attributes, options \\ []) do
    url = Client.versioned("/#{account_id}/domains")

    Client.post(client, url, attributes, options)
    |> Response.parse(%{"data" => %Domain{}})
  end


  @doc """
  PERMANENTLY deletes a domain from the account.

  See https://developer.dnsimple.com/v2/domains/#delete

  ## Examples:

    client = %Dnsimple.Client{access_token: "a1b2c3d4"}

    Dnsimple.Domains.delete_domain(client, account_id = 1010, domain_id = 237)
    Dnsimple.Domains.delete_domain(client, account_id = 1010, domain_id = "example.io")

  """
  @spec delete_domain(Client.t, String.t | integer, String.t | integer, Keyword.t) :: Response.t
  def delete_domain(client, account_id, domain_id, options \\ []) do
    url = Client.versioned("/#{account_id}/domains/#{domain_id}")

    Client.delete(client, url, options)
    |> Response.parse(nil)
  end


  @doc """
  Resets the domain API token used for authentication in APIv1.

  See https://developer.dnsimple.com/v2/domains/#reset-token

  ## Examples:

    client = %Dnsimple.Client{access_token: "a1b2c3d4"}

    Dnsimple.Domains.reset_domain_token(client, account_id = 1010, domain_id = 123)
    Dnsimple.Domains.reset_domain_token(client, account_id = 1010, domain_id = "example.io")

  """
  @spec reset_domain_token(Client.t, String.t | integer, String.t | integer, Keyword.t) :: Response.t
  def reset_domain_token(client, account_id, domain_id, options \\ []) do
    url = Client.versioned("/#{account_id}/domains/#{domain_id}/token")

    Client.post(client, url, Client.empty_body, options)
    |> Response.parse(%{"data" => %Domain{}})
  end

end
