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

producer = Kafka::KafkaProducer.new(producer_options)
producer.connect()
producer.send_msg("test", nil, "here's a test message")    
```

The following consumer example indefinitely listens to the `test` topic and prints out messages as they are received from Kafka:

```ruby
require 'jruby-kafka'

consumer_options = {
  :topic_id => "test", 
  :zk_connect => "192.168.59.103:2181", 
  :group_id => "test_group", 
  :auto_commit_enable => "#{true}",
  :auto_offset_reset => "smallest"
}

consumer_group = Kafka::Group.new(consumer_options)
queue = SizedQueue.new(1)
consumer_group.run(1,queue)

count = 0

trap('SIGINT') do
  consumer_group.shutdown()
  puts "Consumed #{count} messages"
  exit
end

loop do
  if !queue.empty?
    puts "#{count}\t#{queue.pop.message.to_s}"
    count += 1
  end
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

