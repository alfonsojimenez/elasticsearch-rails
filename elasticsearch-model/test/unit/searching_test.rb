require 'test_helper'

class Elasticsearch::Model::SearchingTest < Test::Unit::TestCase
  context "Searching module" do
    class ::DummySearchingModel
      extend Elasticsearch::Model::Searching::ClassMethods

      def self.index_name;    'foo'; end
      def self.document_type; 'bar'; end
    end

    setup do
      @client = mock('client')
      DummySearchingModel.stubs(:client).returns(@client)
    end

    should 'have the search and scroll method' do
      [:search, :scroll].each do |method|
        assert_respond_to DummySearchingModel, method
      end
    end

    should "initialize the search object" do
      Elasticsearch::Model::Searching::SearchRequest
        .expects(:new).with do |klass, query, options|
          assert_equal DummySearchingModel, klass
          assert_equal 'foo', query
          assert_equal({default_operator: 'AND'}, options)
          true
        end
        .returns( stub('search') )

      DummySearchingModel.search 'foo', default_operator: 'AND'
    end

    should "not execute the search" do
      Elasticsearch::Model::Searching::SearchRequest
        .expects(:new).returns( mock('search').expects(:execute!).never )

      DummySearchingModel.search 'foo'
    end

    scroll_id = 'cXVlcnlUaGVuRmV0Y2g7NTs2ODA6RXhhbXBsZQ=='

    should 'initializes a ScrollRequest object' do
      Elasticsearch::Model::Searching::ScrollRequest.expects(:new)
        .with(DummySearchingModel, scroll_id, scroll: '5m')
        .returns(mock('scroll'))

      DummySearchingModel.scroll(scroll_id, scroll: '5m')
    end
  end
end
