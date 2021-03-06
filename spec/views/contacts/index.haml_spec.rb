require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index" do
  include ContactsHelper

  before do
    login_and_assign
  end

  it "should render a list of contacts if it's not empty" do
    assign(:contacts, [ FactoryGirl.create(:contact) ].paginate)

    render
    view.should render_template(:partial => "_contact")
    view.should render_template(:partial => "shared/_paginate")
  end

  it "should render a message if there're no contacts" do
    assign(:contacts, [].paginate)

    render
    view.should_not render_template(:partial => "_contact")
    view.should render_template(:partial => "shared/_empty")
    view.should render_template(:partial => "shared/_paginate")
  end

end

