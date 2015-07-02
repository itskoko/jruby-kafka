require 'java'
require 'jruby-kafka/namespace'

# noinspection JRubyStringImportInspection
class Kafka::Consumer
  java_import 'kafka.consumer.ConsumerIterator'
  java_import 'kafka.consumer.KafkaStream'
  java_import 'kafka.common.ConsumerRebalanceFailedException'
  java_import 'kafka.consumer.ConsumerTimeoutException'

  include Java::JavaLang::Runnable
  java_signature 'void run()'

  def initialize(a_stream, a_thread_number, restart_on_exception, a_sleep_ms, callback)
    @m_thread_number = a_thread_number
    @m_stream = a_stream
    @m_restart_on_exception = restart_on_exception
    @m_sleep_ms = 1.0 / 1000.0 * Float(a_sleep_ms)
    @m_callback = callback
  end

  def run
    it = @m_stream.iterator
    begin
      while it.hasNext
        begin
          message = it.next
          @m_callback.call(message.message.to_s, MetaData.new(message.key.to_s, message.topic, message.partition, message.offset))
        end
      end
    rescue Exception => e
      # Log exception (or only retry if consumer timed out)
      if @m_restart_on_exception
        sleep(@m_sleep_ms)
        retry
      else
        raise e
      end
    end
  end

  class MetaData < Struct.new(:key, :topic, :partition, :offset); end
end
