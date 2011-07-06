require 'spec_helper'

describe Video do
  
  it "should not share attachment definitons" do
    assert Video.attachment_definitions != Document.attachment_definitions
  end 

end
