require '3scale_toolbox'

RSpec.shared_context :import_oas_basepath_stubbed do
  include_context :oas_common_mocked_context

  let(:external_account) do
    {
      'account' => {
        'id' => 1000
      }
    }
  end

  let(:external_app_plans) do
    {
      'application_plan' => {
        'id' => 2000
      }
    }
  end

  let(:external_app) do
    {
      'application' => {
        'id' => 2000,
        'user_key' => 987756
      }
    }
  end

  let(:external_proxy) do
    {
      'proxy' => {
        'service_id' => fake_service_id,
        'endpoint' => 'https://production.gw.apicast.io:443',
        'sandbox_endpoint' => 'https://staging.gw.apicast.io:443',
        'api_backend' => 'https://echo-api.3scale.net:443',
        'credentials_location' => 'query',
        'auth_app_key' => 'app_key',
        'auth_app_id' => 'app_id',
        'oidc_issuer_endpoint' => 'https://issuer.com',
        'auth_user_key' => 'api_key'
      }
    }
  end

  before :example do
    allow(external_http_client).to receive(:post).with('/admin/api/signup', anything)
                                                 .and_return(external_account)
    allow(external_http_client).to receive(:post).with('/admin/api/services/100/application_plans', anything)
                                                 .and_return(external_app_plans)
    allow(external_http_client).to receive(:post).with('/admin/api/accounts/1000/applications', anything)
                                                 .and_return(external_app)
    allow(external_http_client).to receive(:delete).with('/admin/api/accounts/1000/applications/2000')
    allow(external_http_client).to receive(:delete).with('/admin/api/accounts/1000')

    # Stubbed net client
    body = JSON.dump(path: '/private/pet/findByStatus')
    stub_request(:get, %r{staging.gw.apicast.io/public/pet/findByStatus})
      .to_return(body: body, status: 200)
  end
end

RSpec.describe 'OpenAPI import basepath diff' do
  include_context :oas_common_context
  include_context :import_oas_basepath_stubbed unless ENV.key?('ENDPOINT')

  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }

  let(:command_line_str) do
    "import openapi -t #{system_name} -d #{destination_url}" \
    ' --override-private-basepath=/private' \
    ' --override-public-basepath=/public' \
    " #{oas_resource_path}"
  end

  let(:backend_version) { '1' }
  let(:path) { '/public/pet/findByStatus' }
  let(:sandbox_host) { service_proxy.fetch('sandbox_endpoint') }
  let(:account_name) { "account_#{random_lowercase_name}" }
  let(:account) { api3scale_client.signup(name: account_name, username: account_name) }
  let(:application_plan) do
    api3scale_client.create_application_plan(service_id,
                                             'name' => "appplan_#{random_lowercase_name}")
  end
  let(:application) do
    api3scale_client.create_application(account['id'],
                                        plan_id: application_plan['id'],
                                        user_key: random_lowercase_name)
  end
  let(:api_key) { application['user_key'] }

  let(:response) do
    uri = URI("#{sandbox_host}#{path}")
    uri.query = URI.encode_www_form(api_key: api_key)
    Net::HTTP.get_response(uri)
  end

  after :example do
    api3scale_client.delete_application(account['id'], application['id'])
    api3scale_client.delete_account(account['id'])
  end

  it 'request url is rewritten' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(response.class).to be(Net::HTTPOK)
    expect(JSON.parse(response.body)).to include('path' => '/private/pet/findByStatus')
  end
end
