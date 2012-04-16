# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  username            :string(32)      default(""), not null
#  email               :string(64)      default(""), not null
#  first_name          :string(32)
#  last_name           :string(32)
#  title               :string(64)
#  company             :string(64)
#  alt_email           :string(64)
#  phone               :string(32)
#  mobile              :string(32)
#  aim                 :string(32)
#  yahoo               :string(32)
#  google              :string(32)
#  skype               :string(32)
#  password_hash       :string(255)     default(""), not null
#  password_salt       :string(255)     default(""), not null
#  persistence_token   :string(255)     default(""), not null
#  perishable_token    :string(255)     default(""), not null
#  last_request_at     :datetime
#  last_login_at       :datetime
#  current_login_at    :datetime
#  last_login_ip       :string(255)
#  current_login_ip    :string(255)
#  login_count         :integer         default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean         default(FALSE), not null
#  suspended_at        :datetime
#  single_access_token :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe User do
  it "should create a new instance given valid attributes" do
    User.create!(
      :username => "username",
      :email    => "user@example.com",
      :password => "password",
      :password_confirmation => "password"
    )
  end

  describe "Destroying users with and without related assets" do
    before do
      @user = FactoryGirl.create(:user)
    end

    %w(account campaign lead contact opportunity).each do |asset|
      it "should not destroy the user if she owns #{asset}" do
        FactoryGirl.create(asset, :user => @user)
        @user.destroy
        lambda { User.find(@user) }.should_not raise_error(ActiveRecord::RecordNotFound)
        @user.destroyed?.should == false
      end

      it "should not destroy the user if she has #{asset} assigned" do
        FactoryGirl.create(asset, :assignee => @user)
        @user.destroy
        lambda { User.find(@user) }.should_not raise_error(ActiveRecord::RecordNotFound)
        @user.destroyed?.should == false
      end
    end

    it "should not destroy the user if she owns a comment" do
      login
      account = FactoryGirl.create(:account, :user => @current_user)
      FactoryGirl.create(:comment, :user => @user, :commentable => account)
      @user.destroy
      lambda { User.find(@user) }.should_not raise_error(ActiveRecord::RecordNotFound)
      @user.destroyed?.should == false
    end

    it "should not destroy the current user" do
      login
      @current_user.destroy
      lambda { @current_user.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
      @current_user.destroyed?.should == false
    end

    it "should destroy the user" do
      @user.destroy
      lambda { User.find(@user) }.should raise_error(ActiveRecord::RecordNotFound)
      @user.destroyed?.should == true
    end

    it "once the user gets deleted all her permissions must be deleted too" do
      FactoryGirl.create(:permission, :user => @user, :asset => FactoryGirl.create(:account))
      FactoryGirl.create(:permission, :user => @user, :asset => FactoryGirl.create(:contact))
      @user.permissions.count.should == 2
      @user.destroy
      @user.permissions.count.should == 0
    end

    it "once the user gets deleted all her preferences must be deleted too" do
      FactoryGirl.create(:preference, :user => @user, :name => "Hello", :value => "World")
      FactoryGirl.create(:preference, :user => @user, :name => "World", :value => "Hello")
      @user.preferences.count.should == 2
      @user.destroy
      @user.preferences.count.should == 0
    end
  end

  it "should set suspended timestamp upon creation if signups need approval and the user is not an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = FactoryGirl.create(:user, :suspended_at => nil)
    @user.suspended?.should == true
  end

  it "should not set suspended timestamp upon creation if signups need approval and the user is an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = FactoryGirl.create(:user, :admin => true, :suspended_at => nil)
    @user.suspended?.should == false
  end

  describe "Setting I18n.locale" do
    before do
      @user = FactoryGirl.create(:user)
      @locale = I18n.locale
    end

    after do
      I18n.locale = @locale
    end

    it "should update I18n.locale if proference[:locale] is set" do
      @user.preference[:locale] = :esperanto
      @user.set_individual_locale
      I18n.locale.should == :esperanto
    end

    it "should not update I18n.locale if proference[:locale] is not set" do
      @user.preference[:locale] = nil
      @user.set_individual_locale
      I18n.locale.should == @locale
    end
  end

  describe "Setting single access token" do
    it "should update single_access_token attribute if it is not set already" do
      @user = FactoryGirl.create(:user, :single_access_token => nil)

      @user.set_single_access_token
      @user.single_access_token.should_not == nil
    end

    it "should not update single_access_token attribute if it is set already" do
      @user = FactoryGirl.create(:user, :single_access_token => "token")

      @user.set_single_access_token
      @user.single_access_token.should == "token"
    end
  end
end

