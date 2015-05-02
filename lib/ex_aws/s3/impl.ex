defmodule ExAws.S3.Impl do

  # @moduledoc false
  # Implementation of the AWS S3 API.
  #
  # See ExAws.S3.Client for usage.

  ## Buckets
  #############

  def list_buckets(client, opts \\ %{}) do
    client.request(:get, "", "/", params: opts)
  end

  def delete_bucket(client, bucket) do
    client.request(:delete, bucket, "/")
  end

  def delete_bucket_cors(client, bucket) do
    client.request(:delete, bucket, "/", resource: "cors")
  end

  def delete_bucket_lifecycle(client, bucket) do
    client.request(:delete, bucket, "/", resource: "lifecycle")
  end

  def delete_bucket_policy(client, bucket) do
    client.request(:delete, bucket, "/", resource: "policy")
  end

  def delete_bucket_replication(client, bucket) do
    client.request(:delete, bucket, "/", resource: "replication")
  end

  def delete_bucket_tagging(client, bucket) do
    client.request(:delete, bucket, "/", resource: "tagging")
  end

  def delete_bucket_website(client, bucket) do
    client.request(:delete, bucket, "/", resource: "website")
  end

  @params [:delimiter, :marker, :prefix, :encoding_type, :max_keys]
  def list_objects(client, bucket, opts \\ %{}) do
    params = opts |> format_and_take(@params)
    client.request(:get, bucket, "/", params: params)
  end

  def get_bucket_acl(client, bucket) do
    client.request(:get, bucket, "/", resource: "acl")
  end

  def get_bucket_cors(client, bucket) do
    client.request(:get, bucket, "/", resource: "cors")
  end

  def get_bucket_lifecycle(client, bucket) do
    client.request(:get, bucket, "/", resource: "lifecycle")
  end

  def get_bucket_policy(client, bucket) do
    client.request(:get, bucket, "/", resource: "policy")
  end

  def get_bucket_location(client, bucket) do
    client.request(:get, bucket, "/", resource: "location")
  end

  def get_bucket_logging(client, bucket) do
    client.request(:get, bucket, "/", resource: "logging")
  end

  def get_bucket_notification(client, bucket) do
    client.request(:get, bucket, "/", resource: "notification")
  end

  def get_bucket_replication(client, bucket) do
    client.request(:get, bucket, "/", resource: "replication")
  end

  def get_bucket_tagging(client, bucket) do
    client.request(:get, bucket, "/", resource: "tagging")
  end

  def get_bucket_object_versions(client, bucket, opts \\ %{}) do
    client.request(:get, bucket, "/", resource: "versions", params: opts)
  end

  def get_bucket_request_payment(client, bucket) do
    client.request(:get, bucket, "/", resource: "requestPayment")
  end

  def get_bucket_versioning(client, bucket) do
    client.request(:get, bucket, "/", resource: "versioning")
  end

  def get_bucket_website(client, bucket) do
    client.request(:get, bucket, "/", resource: "website")
  end

  def head_bucket(client, bucket) do
    client.request(:head, bucket, "/")
  end

  @params [:delimiter, :encoding_type, :max_uploads, :key_marker, :prefix, :upload_id_marker]
  def list_multipart_uploads(client, bucket, opts \\ %{}) do
    params = @params |> format_and_take(opts)
    client.request(:get, bucket, "/", resource: "uploads", params: params)
  end

  @headers [:acl, :grant_read, :grant_write, :grant_read_acp, :grant_write_acp, :grant_full_control]
  def put_bucket(client, bucket, region, grants \\ %{}) do
    headers = grants |> format_grant_headers(@headers)

    body = """
    <CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
      <LocationConstraint>#{region}</LocationConstraint>
    </CreateBucketConfiguration>
    """
    client.request(:put, bucket, "/", body: body, headers: headers)
  end

  @headers [:acl, :grant_read, :grant_write, :grant_read_acp, :grant_write_acp, :grant_full_control]
  def put_bucket_acl(client, bucket, grants) do
    headers = grants |> format_grant_headers(@headers)

    client.request(:put, bucket, "/", headers: headers)
  end

  def put_bucket_cors(client, bucket, cors_rules) do
    rules = cors_rules
    |> Enum.map(&build_cors_rule/1)
    |> IO.iodata_to_binary

    body = "<CORSConfiguration>#{rules}</CORSConfiguration>"
    client.request(:put, bucket, "/", body: body)
  end

  def put_bucket_lifecycle(client, bucket, _livecycle_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_policy(client, bucket, _policy) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_logging(client, bucket, _logging_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_notification(client, bucket, _notification_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_replication(client, bucket, _replication_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_tagging(client, bucket, _tags) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_requestpayment(client, bucket, _payer) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_versioning(client, bucket, _version_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  def put_bucket_website(client, bucket, _website_config) do
    raise "not yet implemented"
    client.request(:put, bucket, "/")
  end

  ## Objects
  ###########

  def delete_object(client, bucket, object, opts \\ %{}) do
    client.request(:delete, bucket, object, headers: opts)
  end

  def delete_multiple_objects(client, bucket, _objects) do
    raise "not yet implemented"
    client.request(:post, bucket, "/?delete")
  end

  @response_params [:content_type, :content_language, :expires, :cach_control, :content_disposition, :content_encoding]
  @request_headers [:range, :if_modified_since, :if_unmodified_since, :if_match, :if_none_match]
  @encryption_headers [:customer_algorithm, :customer_key, :customer_key_md5]
  def get_object(client, bucket, object, opts \\ %{}) do
    response_opts = opts
    |> Map.get(:response)
    |> format_and_take(@response_params)

    headers = opts
    |> Map.get(:request)
    |> format_and_take(@headers)

    headers = headers ++ opts
    |> Map.get(:encryption)
    |> namespace("x-amz-server-side-encryption")

    client.request(:get, bucket, object, headers: headers, params: response_opts)
  end

  def get_object_acl(client, bucket, object, opts \\ %{}) do
    client.request(:get, bucket, object, resource: "acl", headers: opts)
  end

  def get_object_torrent(client, bucket, object) do
    client.request(:get, bucket, object, resource: "torrent")
  end

  def head_object(client, bucket, object, opts \\ %{}) do
    client.request(:head, bucket, object, headers: opts)
  end

  def options_object(client, bucket, object, origin, request_method, request_headers \\ []) do
    headers = [
      {"Origin", origin},
      {"Access-Control-Request-Method", request_method},
      {"Access-Control-Request-Headers", request_headers |> Enum.join(",")},
    ]
    client.request(:options, bucket, object, headers: headers)
  end

  def post_object(client, bucket, object, _opts \\ %{}) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def post_object_restore(client, bucket, object, _version_id, _number_of_days) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def put_object(client, bucket, object, body, opts \\ %{}) do
    headers = [
      {"Content-Type", "binary/octet-stream"} |
      opts |> Map.to_list
    ]
    client.request(:put, bucket, object, body: body, headers: headers)
  end

  def put_object_acl(client, bucket, object, _acl) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def put_object_copy(client, dest_bucket, dest_object, _src_bucket, _src_object, _opts \\ %{}) do
    raise "not yet implemented"
    client.request(:get, dest_bucket, dest_object)
  end

  def initiate_multipart_upload(client, bucket, object, _opts \\ %{}) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def upload_part(client, bucket, object, _upload_id, _part_number) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def upload_part_copy(client, dest_bucket, dest_object, _src_bucket, _src_object, _opts \\ %{}) do
    raise "not yet implemented"
    client.request(:get, dest_bucket, dest_object)
  end

  def complete_multipart_upload(client, bucket, object, _upload_id, _parts) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def abort_multipart_upload(client, bucket, object, _upload_id) do
    raise "not yet implemented"
    client.request(:get, bucket, object)
  end

  def list_parts(client, bucket, object, upload_id, opts \\ %{}) do
    params = %{"uploadId" => upload_id}
    |> Map.merge(opts)
    client.request(:get, bucket, object, params: params)
  end

  ## Formatting and helpers

  def format_and_take(opts, param_list) do
    param_list
    |> Enum.map(&normalize_param/1)
    |> Enum.reduce(%{}, fn({elixir_opt, aws_opt}, params) ->
      case Map.get(opts, elixir_opt) do
        nil   -> params
        value -> Map.put(params, aws_opt, value)
      end
    end)
  end

  def format_grant_headers(grants, headers) do
    headers = headers |> namespace("x-amz")

    grants
    |> format_and_take(headers)
    |> Map.to_list
    |> Enum.filter(&match?({_, [_|_]}, &1))
    |> Enum.map(&format_grant_header/1)
  end

  defp format_grant_header({permission, grantees}) do
    grants = grantees
    |> Enum.map(fn
      {:email, email} -> "emailAddress=\"#{email}\""
      {key, value}    -> "#{key}=\"#{value}\""
    end)
    |> Enum.join(", ")
    {permission, grants}
  end

  def build_cors_rule(rule) do
    mapping = [
      allowed_origins: "AllowedOrigin",
      allowed_methods: "AllowedMethod",
      allowed_headers: "AllowedHeader",
      exposed_headers: "ExposeHeader"]

    properties = mapping
    |> Enum.flat_map(fn({key, property}) ->
      Map.get(rule, key, [])
      |> Enum.map(&("<#{property}>#{&1}</#{property}>"))
    end)
    |> IO.iodata_to_binary

    properties = case Map.get(rule, :max_age_seconds) do
      nil -> properties
      value -> "<MaxAgeSeconds>#{value}</MaxAgeSeconds>" <> properties
    end

    "<CORSRule>#{properties}</CORSRule>"
  end

  defp normalize_param(param) when is_atom(param) do
    aws_param = param
    |> Atom.to_string
    |> String.replace("_", "-")

    {param, aws_param}
  end
  defp normalize_param(other), do: other

  def namespace(list, value) do
    list |> Enum.map(&({&1, "#{value}-#{&1}" |> String.replace("_", "-")}))
  end

end
