require 'minitest/autorun'
require File.expand_path('../lib/slideshare', File.dirname(__FILE__))

class TestClient < Minitest::Test
  def setup
    @client = SlideShare::Client.new
    @client.configuration.load_from File.expand_path('../slideshare.config.test.yml', File.dirname(__FILE__))
  end

  def test_configuration
    @client = SlideShare::Client.new

    assert_nil @client.configuration.api_key
    assert_nil @client.configuration.shared_secret

    @client.configuration.api_key = '123'
    assert_equal @client.configuration.api_key, '123'

    @client.configuration.shared_secret = 'abc'
    assert_equal @client.configuration.shared_secret, 'abc'
  end

  def test_underscore_keys_creates_new_keys
    orig_hash = {
      "Foo" => 1,
      "FooBar" => {
        "baz" => 2,
        "FooBarFooBar" => 3
      }
    }
    new_hash = Marshal.load(Marshal.dump(orig_hash))
    SlideShare::Client.underscore_keys new_hash
    assert new_hash.key?('foo')
    assert new_hash.key?('foo_bar')
    assert new_hash['foo_bar'].key?('baz')
    assert new_hash['foo_bar'].key?('foo_bar_foo_bar')
  end

  def test_underscore_keys_deletes_old_keys
    orig_hash = {
      "Foo" => 1,
      "FooBar" => {
        "baz" => 2,
        "FooBarFooBar" => 3
      }
    }
    new_hash = Marshal.load(Marshal.dump(orig_hash))
    SlideShare::Client.underscore_keys new_hash
    assert !new_hash.key?('Foo')
    assert !new_hash.key?('FooBar')
    assert !new_hash['foo_bar'].key?('FooBarFooBar')
  end

  def test_http_options_keys_set
    ops = @client.http_options
    [:api_key, :ts, :hash].each do |key|
      assert ops.key?(key), "Client hash doesn't contain key:#{key}"
    end
  end

  def test_http_options_digest
    ops = @client.http_options
    assert_equal(ops[:hash],
                 OpenSSL::Digest::SHA1.hexdigest(@client.configuration.shared_secret + ops[:ts]),
                 "Digest is not as expected")
  end
end
