require 'rails_helper'

RSpec.describe IncludableResources, type: :concern do
  # Create a test controller to include our concern
  class TestController < ActionController::Base
    include Pagy::Backend
    include IncludableResources
    
    configure_includes do |config|
      config.allowed_includes = %w[users posts comments]
      config.default_limits = { users: 5, comments: 10 }
    end
    
    attr_accessor :params
    
    def initialize
      @params = {}
    end
  end
  
  let(:controller) { TestController.new }
  
  describe "#parse_includes" do
    it "returns empty array when no includes are specified" do
      controller.params = {}
      expect(controller.parse_includes).to eq([])
    end
    
    it "parses and filters includes based on allowed_includes" do
      controller.params = { include: "users,posts,invalid" }
      expect(controller.parse_includes).to eq(["users", "posts"])
    end
    
    it "handles whitespace and empty values" do
      controller.params = { include: "users, ,posts, " }
      expect(controller.parse_includes).to eq(["users", "posts"])
    end
  end
  
  describe "#apply_includes" do
    let(:query) { double("ActiveRecord::Relation") }
    
    it "applies includes to query when valid includes exist" do
      controller.params = { include: "users,posts" }
      expect(query).to receive(:includes).with("users", "posts").and_return(query)
      
      result, valid_includes = controller.apply_includes(query)
      expect(result).to eq(query)
      expect(valid_includes).to eq(["users", "posts"])
    end
    
    it "doesn't modify query when no valid includes exist" do
      controller.params = { include: "invalid" }
      
      result, valid_includes = controller.apply_includes(query)
      expect(result).to eq(query)
      expect(valid_includes).to eq([])
    end
  end
  
  describe "#apply_association_limits" do
    let(:user1) { double("User") }
    let(:user2) { double("User") }
    let(:users) { [user1, user2] }
    let(:record) { double("Record") }
    let(:users_association) { double("Association", loaded?: true) }
    let(:posts_association) { double("Association", loaded?: true) }
    
    before do
      allow(record).to receive(:association).with(:users).and_return(users_association)
      allow(record).to receive(:association).with(:posts).and_return(posts_association)
      allow(record).to receive(:users).and_return(users)
      allow(record).to receive(:users=)
    end
    
    it "applies limits to associations with default limits" do
      controller.params = {}
      
      expect(record).to receive(:users=).with(users)
      controller.apply_association_limits(record, ["users"])
    end
    
    it "applies custom limits from params" do
      controller.params = { users_limit: 3 }
      
      expect(record).to receive(:users=).with(users)
      controller.apply_association_limits(record, ["users"])
    end
    
    it "handles collection of records" do
      controller.params = {}
      records = [record, record]
      
      expect(record).to receive(:users=).with(users).twice
      controller.apply_association_limits(records, ["users"])
    end
  end
  
  describe "#prepare_include_options" do
    it "returns nil when no valid includes exist" do
      expect(controller.prepare_include_options([])).to be_nil
    end
    
    it "prepares include options hash for valid includes" do
      result = controller.prepare_include_options(["users", "posts"])
      expect(result).to eq({ users: {}, posts: {} })
    end
  end
  
  describe "#with_includes_and_pagination" do
    let(:query) { double("ActiveRecord::Relation") }
    let(:pagy) { double("Pagy", page: 1, pages: 2, count: 10) }
    let(:records) { [double("Record")] }
    
    before do
      allow(controller).to receive(:pagy).and_return([pagy, records])
      allow(controller).to receive(:apply_includes).and_return([query, ["users"]])
      allow(controller).to receive(:apply_association_limits).and_return(records)
      allow(controller).to receive(:prepare_include_options).and_return({ users: {} })
    end
    
    it "returns records with pagination and include options" do
      result = controller.with_includes_and_pagination(query)
      
      expect(result[:records]).to eq(records)
      expect(result[:include_options]).to eq({ users: {} })
      expect(result[:pagination]).to include(
        per_page: 15,
        current_page: 1,
        total_pages: 2,
        total_count: 10,
        next_page: 2
      )
      expect(result[:success]).to be true
    end
    
    it "handles Pagy::OverflowError" do
      allow(controller).to receive(:pagy).and_raise(Pagy::OverflowError)
      
      result = controller.with_includes_and_pagination(query, page_number: 999)
      
      expect(result[:records]).to eq([])
      expect(result[:include_options]).to be_nil
      expect(result[:pagination]).to include(
        per_page: 15,
        current_page: 999,
        total_pages: 0,
        total_count: 0,
        next_page: nil
      )
      expect(result[:success]).to be true
    end
  end
  
  describe "#with_includes_for_record" do
    let(:record) { double("Record", id: 1, class: double("Class")) }
    let(:record_with_includes) { double("RecordWithIncludes") }
    
    before do
      allow(controller).to receive(:parse_includes).and_return(["users"])
      allow(controller).to receive(:apply_association_limits).and_return(record_with_includes)
      allow(controller).to receive(:prepare_include_options).and_return({ users: {} })
      allow(record.class).to receive(:includes).and_return(record.class)
      allow(record.class).to receive(:find).and_return(record_with_includes)
    end
    
    it "returns record with include options" do
      result = controller.with_includes_for_record(record)
      
      expect(result[:record]).to eq(record_with_includes)
      expect(result[:include_options]).to eq({ users: {} })
      expect(result[:success]).to be true
    end
  end
end
