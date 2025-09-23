require 'rails'
require 'global_id/railtie'
require 'active_support/testing/isolation'


module BlogApp
  class Application < Rails::Application; end
end

class RailtieTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    Rails.env = 'development'
    @app = BlogApp::Application.new
    @app.config.eager_load = false
    @app.config.logger = Logger.new(nil)
    @app.config.secret_key_base = ('x' * 30)
    # Rails supports `cache_format` up to `7.1`.
    # https://github.com/rails/rails/blob/aa66aece44f191e6330c04ce4942c3edf31d85d7/activesupport/lib/active_support/cache.rb#L800-L809
    @app.config.active_support.cache_format_version = if Rails::VERSION::STRING.to_f < 8
      Rails::VERSION::STRING.to_f
    else
      7.1
    end
    @app.config.active_support.to_time_preserves_timezone = :zone
  end

  test 'GlobalID.app for Blog::Application defaults to blog' do
    @app.initialize!
    assert_equal 'blog-app', GlobalID.app
  end

  test 'GlobalID.app can be set with config.global_id.app =' do
    @app.config.global_id.app = 'foo'
    @app.initialize!
    assert_equal 'foo', GlobalID.app
  end

  test 'SignedGlobalID.expires_in can be explicitly set to nil with config.global_id.expires_in' do
    @app.config.global_id.expires_in = nil
    @app.initialize!
    assert_nil SignedGlobalID.expires_in
  end

  test 'config.global_id can be used to set configurations after the railtie has been loaded' do
    @app.config.eager_load = true
    @app.config.before_eager_load do
      @app.config.global_id.app = 'foobar'
      @app.config.global_id.expires_in = 1.year
    end

    @app.initialize!
    assert_equal 'foobar', GlobalID.app
    assert_equal 1.year, SignedGlobalID.expires_in
  end

  test 'config.global_id can be used to explicitly set SignedGlobalID.expires_in to nil after the railtie has been loaded' do
    @app.config.eager_load = true
    @app.config.before_eager_load do
      @app.config.global_id.expires_in = nil
    end

    @app.initialize!
    assert_nil SignedGlobalID.expires_in
  end


  test 'SignedGlobalID.verifier defaults to Blog::Application.message_verifier(:signed_global_ids) when secret_key_base is present' do
    @app.initialize!
    message = {id: 42}
    signed_message = SignedGlobalID.verifier.generate(message)
    assert_equal @app.message_verifier(:signed_global_ids).generate(message), signed_message
  end

  test 'SignedGlobalID.verifier can be set with config.global_id.verifier =' do
    custom_verifier = @app.config.global_id.verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: SERIALIZER)
    @app.initialize!
    message = {id: 42}
    signed_message = SignedGlobalID.verifier.generate(message)
    assert_equal custom_verifier.generate(message), signed_message
  end

end
