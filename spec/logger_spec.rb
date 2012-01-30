require 'spec_helper'
require 'stringio'
require 'tempfile'

# Tests heavily based upon Fluentd original tests
module FluentLoggerRails
describe Logger do

if RUBY_VERSION < "1.9.2"
  pending "fluentd only works in Ruby 1.9.2"
else

  require 'fluent/load'

  # Override fluentd logger
  $log = Fluent::Log.new(StringIO.new)

  let(:appname)      { 'fluent-logger-rails-test' }
  let(:fluentd_tag)  { 'fluent-logger-rails-test.stdout' }
  let(:fluentd_host) { 'localhost' }
  let(:fluentd_port) {
    port = 24225
    # Find a port to connect and execute the test
    loop do
      begin
        TCPServer.open(fluentd_host, port).close
        break
      rescue Errno::EADDRINUSE
        port += 1
      end
    end
    port
  }

  let (:output) {
    sleep 0.001
    Fluent::Engine.match(fluentd_tag).output
  }

  let(:queue) {
    queue = []
    output.emits.each {|tag, time, log|
      queue << [tag, :log => log ]
    }
    queue
  }

  # after(:each) do
  #   output.emits.clear rescue nil
  # end

  context "running fluentd" do
    before(:each) do
      tmp = Tempfile.new('fluent-logger-config')
      tmp.close(false)

      File.open(tmp.path, 'w') { |f|
        f.puts <<EOF
<source>
  type tcp
  port #{fluentd_port}
</source>
<match #{appname}.**>
  type test
</match>
EOF
      }
      Fluent::Test.setup
      Fluent::Engine.read_config(tmp.path)
      @coolio_default_loop = nil
      @thread = Thread.new {
        @coolio_default_loop = Coolio::Loop.default
        Fluent::Engine.run
      }
      # wait_transfer
      sleep 0.1
    end

    after(:each) do
      @coolio_default_loop.stop
      Fluent::Engine.send :shutdown
      @thread.join
    end

    context "logging to fluentd" do
      before(:each) do
        @options = {
          :host     => fluentd_host,
          :port     => fluentd_port,
          :appname  => appname
        }
        @logger = Logger.new(@options)
      end

       it "should add something to the log with the :debug level" do
        @logger.debug("DEBUG!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "DEBUG!", "level" => "DEBUG" }}]
      end

      it "should add something to the log with the :info level" do
        @logger.info("INFO!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "INFO!", "level" => "INFO" }}]
      end

      it "should add something to the log with the :warn level" do
        @logger.warn("WARN!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "WARN!", "level" => "WARN" }}]
      end

      it "should add something to the log with the :error level" do 
        @logger.error("ERROR!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "ERROR!", "level" => "ERROR" }}]
      end

      it "should add something to the log with the :fatal level" do 
        @logger.fatal("FATAL!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "FATAL!", "level" => "FATAL" }}]
      end

      it "should add something to the log with the :unknown level" do 
        @logger.unknown("UNKNOWN!").should be_true
        queue.last.should == [fluentd_tag, { :log => { "text" => "UNKNOWN!", "level" => "UNKNOWN" }}]
      end

      it "should swap Rails 3.0 stable default logger by reading fluent_config.yml file" do 
        `cd assets/rails3_tests/rails3_0_app/ && ruby -Itest test/functional/messages_controller_test.rb -n test_should_get_index`
         queue.first.should == [fluentd_tag, { :log => { "text"=>"  Processing by MessagesController#index as HTML", "level"=>"INFO"}}]
      end

      it "should swap Rails 3.0 stable default logger by using ENV variables file" do 
        `cd assets/rails3_tests/rails3_0_with_env/ && APPLICATION_NAME=#{appname} FLUENTD_HOST=#{fluentd_host} FLUENTD_PORT=#{fluentd_port} ruby -Itest test/functional/messages_controller_test.rb -n test_should_get_index`
         queue.first.should == [fluentd_tag, { :log => { "text"=>"  Processing by MessagesController#index as HTML", "level"=>"INFO"}}]
      end

    end

  end

end # <= Ruby version check
end
end
