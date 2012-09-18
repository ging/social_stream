require 'spec_helper'

describe ActorKey do
  it "should generate openssl key" do
    actor_key = ActorKey.create! actor_id: 1

    actor_key.key.class.should == OpenSSL::PKey::RSA
  end
end
