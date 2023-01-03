require 'helper'

class URI::PatternMatchingTest < ActiveSupport::TestCase
  setup do
    @gid = URI::GID.parse('gid://bcx/Person/5?hello=worlds&param=value')
  end

  test 'URI::GID pattern matching' do
    case @gid
    in app: 'bcx', model_name: 'Person', model_id: '5', params: { hello: _ => world, param: _ => _ }
      assert_equal world, 'worlds'
    else
      raise
    end
  end
end

class GlobalIDPatternMatchingTest < ActiveSupport::TestCase
  setup do
    @gid = GlobalID.parse('gid://bcx/Person/5?hello=worlds&param=value')
  end

  test 'GlobalID pattern matching' do
    case @gid
    in app: 'bcx', model_name: 'Person', model_id: '5', params: { hello: _ => world, param: _ => _ }
      assert_equal world, 'worlds'
    else
      raise
    end
  end
end
