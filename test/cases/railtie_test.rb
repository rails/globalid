require 'rails'
require 'global_id/railtie'
require 'active_support/testing/isolation'


module Blog
  class Application < Rails::Application; end
end

class RailtieTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    Rails.env = 'development'
    @app = Blog::Application.new do
      config.eager_load = false
      config.logger = Logger.new(nil)
    end
  end

  test 'GlobalID.app for Blog::Application defaults to blog' do
    @app.initialize!
    assert_equal 'blog', GlobalID.app
  end

  test 'GlobalID.app can be set with config.global_id.app =' do
    @app.config.global_id.app = 'foo'
    @app.initialize!
    assert_equal 'foo', GlobalID.app
  end

  test 'SignedGlobalID.verifier defaults to Blog::Application.message_verifier(:signed_global_ids) when secret_token is present' do
    @app.config.secret_token = ('x' * 30)
    @app.initialize!
    message = {id: 42}
    signed_message = SignedGlobalID.verifier.generate(message)
    assert_equal @app.message_verifier(:signed_global_ids).generate(message), signed_message
  end

  test 'SignedGlobalID.verifier defaults to nil when secret_token is not present' do
    @app.initialize!
    assert_nil SignedGlobalID.verifier
  end

  test 'SignedGlobalID.verifier can be set with config.global_id.verifier =' do
    custom_verifier = @app.config.global_id.verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: StringSerializer.new)
    @app.initialize!
    message = {id: 42}
    signed_message = SignedGlobalID.verifier.generate(message)
    assert_equal custom_verifier.generate(message), signed_message
  end

end
