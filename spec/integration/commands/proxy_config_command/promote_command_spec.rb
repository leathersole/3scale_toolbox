RSpec.describe 'ProxyConfig Promote command' do
  include_context :real_api3scale_client
  include_context :random_name
  include_context :resources
  include_context :proxy_config_real_cleanup

  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:remote) { client_url }
  let(:service_ref) { "svc_#{random_lowercase_name}" }
  let(:environment_sandbox) { "sandbox" }
  let(:environment_prod) { "production" }

  context "Trying to promote a Proxy configuration version" do
    let (:command_line_str) { "proxy-config promote #{remote} #{service_ref}" }

    context "That hasn't been promoted" do
      before :example do
        svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref})
        # Service needs backend api. Otherwise proxy config will not be promoted to sandbox
        svc.update_proxy('api_backend' => 'https://example.com')
      end

      it "promotes the configuration version into production" do
        expect { subject }.to output("Proxy Configuration version 1 promoted to '#{environment_prod}'\n").to_stdout
        expect(subject).to eq(0)
      end
    end

    context "That has already been promoted" do
      before :example do
        svc = ThreeScaleToolbox::Entities::Service::create(remote: api3scale_client, service_params: {"name" => service_ref})
        # Service needs backend api. Otherwise proxy config will not be promoted to sandbox
        svc.update_proxy('api_backend' => 'https://example.com')
        pc_sandbox_1 = nil
        Helpers.wait do
          pc_sandbox_1 = ThreeScaleToolbox::Entities::ProxyConfig::find(service: svc, environment: environment_sandbox, version: 1)
          !pc_sandbox_1.nil? 
        end
        pc_sandbox_1.promote(to: environment_prod)
      end

      it "results in not being promoted and a warning shown" do
        expect { subject }.to output(/warning*/).to_stderr
        expect(subject).to eq(0)
      end
    end
  end
end
