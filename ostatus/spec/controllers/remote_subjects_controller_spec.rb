require 'spec_helper'

describe RemoteSubjectsController do
  render_views

  context "with remote subject" do
    before do
      @remote_subject = Factory(:remote_subject)
    end

    it "should redirect index to show" do
      get :index, q: @remote_subject.webfinger_id

      response.should redirect_to(@remote_subject)
    end

    it "should render show" do
      get :show, id: @remote_subject.slug

      response.should be_success
    end


    describe "refreshing show" do
      before do
        RemoteSubject.should_receive(:find_by_slug!).with(@remote_subject.slug) { @remote_subject }
        @remote_subject.should_receive(:refresh_webfinger!)
      end

      it "should refresh remote_subject" do
        get :show, id: @remote_subject.slug, refresh: true

        response.should be_success
      end
    end
  end
end
