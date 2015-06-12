require 'java'
java_import "kafka.common.TopicAndPartition"
java_import "kafka.javaapi.consumer.ZookeeperConsumerConnector"

class ZookeeperConsumerConnector
  field_reader :underlying

  def commitOffset(topic, partition, offset)
    self.underlying.commitOffsetToZooKeeper(TopicAndPartition.new(topic, partition), offset)
  end
end
