require 'test/unit'

class TestKafka < Test::Unit::TestCase
  BROKER_IP = `docker-machine ip default`.strip

  def setup
    $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
    require 'jruby-kafka'
  end

  def send_msg
    options = {
      :broker_list => "#{BROKER_IP}:9092",
      :serializer_class => 'kafka.serializer.StringEncoder'
    }
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.send_msg('test',nil, nil, 'test message')
  end

  def send_msg_deprecated
    options = {
      :broker_list => "#{BROKER_IP}:9092",
      :serializer_class => 'kafka.serializer.StringEncoder'
    }
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.sendMsg('test',nil, 'test message')
  end

  def producer_compression_send(compression_codec='none')
    options = {
      :broker_list => "#{BROKER_IP}:9092",
      :compression_codec => compression_codec,
      :serializer_class => 'kafka.serializer.StringEncoder'
    }
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.send_msg('test', nil, nil,  "codec #{compression_codec} test message")
  end

  def send_compression_none
    producer_compression_send('none')
  end

  def send_compression_gzip
    producer_compression_send('gzip')
  end

  def send_compression_snappy
    #snappy test may fail on mac, see https://code.google.com/p/snappy-java/issues/detail?id=39
    producer_compression_send('snappy')
  end

  def send_test_messages
    send_compression_none
    send_compression_gzip
    send_compression_snappy
    send_msg
  end

  def test_run
    options = {
      :zk_connect => "#{BROKER_IP}:2181",
      :group_id => 'test',
      :topic_id => 'test',
      :zk_connect_timeout => '1000',
      :consumer_timeout_ms => '10',
      :consumer_restart_sleep_ms => '5000',
      :consumer_restart_on_error => true
    }
    group = Kafka::Group.new(options)
    assert(!group.running?)
    messages = Queue.new
    group.run(1) do |message, metadata|
      messages << message
    end
    send_test_messages
    assert(group.running?)
    sleep 10
    group.shutdown

    found = []
    until messages.empty?
      found << messages.pop
    end
    assert_equal([ "codec gzip test message",
                   "codec none test message",
                   "codec snappy test message",
                   "test message" ],
                  found.to_a.uniq.sort)
  end

  def test_from_beginning
    options = {
      :zk_connect => "#{BROKER_IP}:2181",
      :group_id => 'beginning',
      :topic_id => 'test',
      :reset_beginning => 'from-beginning',
      :auto_offset_reset => 'smallest'
    }
    group = Kafka::Group.new(options)
    messages = []
    group.run(2) do |message, metadata|
      messages << message
    end
    sleep 1
    group.shutdown

    found = []
    until messages.empty?
      found << messages.pop
    end
    assert_equal([ "codec gzip test message",
                   "codec none test message",
                   "codec snappy test message",
                   "test message" ],
                 found.uniq.sort)
  end

  def produce_to_different_topics
    options = {
      :broker_list => "#{BROKER_IP}:9092",
      :serializer_class => 'kafka.serializer.StringEncoder'
    }
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.send_msg('apple', nil, nil, 'apple message')
    producer.send_msg('cabin', nil, nil, 'cabin message')
    producer.send_msg('carburetor', nil, nil, 'carburetor message')
  end

  def test_topic_whitelist
    options = {
      :zk_connect => "#{BROKER_IP}:2181",
      :group_id => 'topics',
      :allow_topics => 'ca.*',
    }
    group = Kafka::Group.new(options)
    messages = []
    produce_to_different_topics
    group.run(2) do |message, metadata|
      messages << message
    end
    sleep 1
    group.shutdown

    found = []
    until messages.empty?
      found << messages.pop
    end
    assert(found.include?("cabin message"))
    assert(found.include?("carburetor message"))
    assert(!found.include?("apple message"))
  end

  def test_topic_blacklist
    options = {
      :zk_connect => "#{BROKER_IP}:2181",
      :group_id => 'topics',
      :filter_topics => 'ca.*',
    }
    group = Kafka::Group.new(options)
    messages = []
    produce_to_different_topics
    group.run(2) do |message, metadata|
      messages << message
    end
    sleep 1
    group.shutdown

    found = []
    until messages.empty?
      found << messages.pop
    end
    assert(!found.include?("cabin message"))
    assert(!found.include?("carburetor message"))
    assert(found.include?("apple message"))
  end
end
