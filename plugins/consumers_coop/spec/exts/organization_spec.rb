require 'spec_helper'

describe 'organization extensions' do

  fixtures :environments, :roles

  before do
    @org = create Community
    @org.consumers_coop_settings.enabled = true
    @org.save!

    @admin = create_user.person
    @org.add_admin @admin
  end

  describe 'closed community' do
    before do
      @person = create_user.person
      @org.update closed: true
      @org.add_member @person
    end

    it 'add consumer on affiliation' do
      @task = @org.tasks.select{ |t| t.is_a? AddMember }.first
      expect(@task).not_to be_nil

      expect_any_instance_of(Community).to receive(:affiliate).and_call_original
      expect_any_instance_of(Community).to receive(:add_consumer).and_call_original
      @task.finish

      @consumer = SuppliersPlugin::Consumer.find_by consumer_id: @person.id
      expect(@org.consumers).to include @consumer
    end
  end

  describe 'open community' do
    before do
      @person = create_user.person
      @org.update closed: false
      @org.add_member @person

      expect(@org.tasks).to be_empty
    end

    it 'add consumer on affiliation' do
      @consumer = SuppliersPlugin::Consumer.find_by consumer_id: @person.id
      expect(@org.consumers).to include @consumer
    end
  end

end
