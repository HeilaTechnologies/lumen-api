# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'user' do
    let(:user) { User.new }
    specify { expect(user).to respond_to(:first_name) }
    specify { expect(user).to respond_to(:last_name) }
    specify { expect(user).to respond_to(:email) }
    specify { expect(user).to respond_to(:home_data_view)}

  end

  it 'responds to name' do
    u = build(:user, first_name: 'Bill', last_name: 'Test')
    expect(u.name).to match('Bill Test')
    u.first_name=nil
    u.last_name=nil
    u.email="test@email.com"
    expect(u.name).to match('test@email.com')
    u.email=nil
    expect(u.name).to match("UNKNOWN NAME")
  end


  describe
  describe "permission management" do
    context "Given the Donnal's House and the Lab" do
      before(:each) do
        #users
        @john = create(:user, first_name: "John")
        @nicky = create(:user, first_name: "Nicky")
        @pete = create(:user, first_name: "Pete")
        @leeb = create(:user, first_name: "Leeb")
        @other_user = create(:user, first_name: "Other")
        #groups
        @donnals = create(:user_group, name: "Donnals", members: [@john, @nicky])
        @labmates = create(:user_group, name: "Labmates", members: [@john, @pete, @leeb])
        @public = create(:user_group, members:[@john, @nicky, @pete, @leeb])
        #nilms
        @donnal_house = create(:nilm, name: "Donnal House",
                               admins: [@john], owners: [@donnals])
        @lab = create(:nilm, name: "LEES Lab", admins: [@john, @leeb],
                      owners: [@labmates], viewers: [@public])
      end
      it "associates nilms with permissions" do
        expect(@john.get_nilm_permission(@donnal_house)).to eq('admin')
        expect(@pete.get_nilm_permission(@lab)).to eq('owner')
        expect(@nicky.get_nilm_permission(@lab)).to eq('viewer')
        expect(@other_user.get_nilm_permission(@donnal_house)).to eq ('none')
      end
      it "lets John admin his house and the lab" do
        expect(@john.admins_nilm?(@donnal_house)).to eq(true)
        expect(@john.owns_nilm?(@donnal_house)).to eq(true)
        expect(@john.views_nilm?(@donnal_house)).to eq(true)
        expect(@john.admins_nilm?(@lab)).to eq(true)
        expect(@john.owns_nilm?(@lab)).to eq(true)
        expect(@john.views_nilm?(@lab)).to eq(true)
      end
      it "lets Nicky own her house and view the lab" do
        expect(@nicky.admins_nilm?(@donnal_house)).to eq(false)
        expect(@nicky.owns_nilm?(@donnal_house)).to eq(true)
        expect(@nicky.views_nilm?(@donnal_house)).to eq(true)
        expect(@nicky.admins_nilm?(@lab)).to eq(false)
        expect(@nicky.owns_nilm?(@lab)).to eq(false)
        expect(@nicky.views_nilm?(@lab)).to eq(true)
      end
      it "lets Pete own the lab but hides the Donnal's house" do
        expect(@pete.admins_nilm?(@donnal_house)).to eq(false)
        expect(@pete.owns_nilm?(@donnal_house)).to eq(false)
        expect(@pete.views_nilm?(@donnal_house)).to eq(false)
        expect(@pete.admins_nilm?(@lab)).to eq(false)
        expect(@pete.owns_nilm?(@lab)).to eq(true)
        expect(@pete.views_nilm?(@lab)).to eq(true)
      end
      it "lets Leeb admin the lab but hides the Donnal's house" do
        expect(@leeb.admins_nilm?(@donnal_house)).to eq(false)
        expect(@leeb.owns_nilm?(@donnal_house)).to eq(false)
        expect(@leeb.views_nilm?(@donnal_house)).to eq(false)
        expect(@leeb.admins_nilm?(@lab)).to eq(true)
        expect(@leeb.owns_nilm?(@lab)).to eq(true)
        expect(@leeb.views_nilm?(@lab)).to eq(true)
      end

    end
  end
end
