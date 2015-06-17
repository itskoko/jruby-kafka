# Jruby::Kafka

## Prerequisites

* [Apache Kafka] version 0.8.2.1 installed and running.

* [JRuby] installed.

[Apache Kafka]: http://kafka.apache.org/
[JRuby]: http://jruby.org/

## About

This gem is primarily used to wrap most of the [Kafka 0.8.2.1 high level consumer] and [Kafka 0.8.2.1 producer] API into
jruby.
The [Kafka Consumer Group Example] is pretty much ported to this library.

  - [Kafka 0.8.2.1 high level consumer](http://kafka.apache.org/documentation.html#highlevelconsumerapi)
  - [Kafka 0.8.2.1 java producer](http://kafka.apache.org/082/javadoc/index.html?org/apache/kafka/clients/producer/KafkaProducer.html)
  - [Kafka 0.8.1.0 scala producer](http://kafka.apache.org/081/documentation.html#producerapi)
  - [Kafka Consumer Group Example](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example)
  
Note that the Scala `Kafka::Producer` will deprecate and Java `Kafka::KafkaProducer` is taking over. 

## Installation

This package is now distributed via [RubyGems.org](http://rubygems.org) but you can build it using the following instructions.

From the root of the project run:

    $ bundle install
    $ rake setup jar package

You can run the following to install the resulting package:

    $ gem install jruby-kafka*.gem

Add this line to your application's Gemfile:

    gem 'jruby-kafka'

## Usage

If you want to run the tests, make sure you already have downloaded Kafka 0.8.X, followed the [kafka quickstart]
instructions and have KAFKA_PATH set in the environment.

[kafka quickstart]: http://kafka.apache.org/documentation.html#quickstart

#### Usage

The following producer code sends a message to a `test` topic

```ruby
require 'jruby-kafka'

producer_options = {:broker_list => "192.168.59.103:9092", "serializer.class" => "kafka.serializer.StringEncoder"}

producer = Kafka::Producer.new(producer_options)
producer.connect()
100.times { |i| producer.send_msg("test", i.to_s, i.to_s) }
```

The following consumer example indefinitely listens to the `test` topic and prints out messages as they are received from Kafka:

```ruby
require 'jruby-kafka'

consumer_options = {
  :topic_id => "test",
  :zk_connect => "192.168.59.103:2181",
  :group_id => "test_group",
  :auto_commit_enable => "#{false}",
  :auto_offset_reset => "smallest",
}

messages = Queue.new

consumer_group = Kafka::Group.new(consumer_options)
consumer_group.run(2) do |message, metadata|
  messages << [message, metadata]
  consumer_group.commit(metadata)
  sleep 0.5
  print message
end

trap('SIGINT') do
  consumer_group.shutdown()
  puts "Consumed #{messages.size} messages"
end
```

#### Using in logstash:

Check out this repo: https://github.com/joekiller/logstash-kafka

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

