require 'spec_helper'

describe ActivityObjectProperty do
  describe "siblings" do
    it "should work" do
      holder, one, two, three = 4.times.map{ Factory(:post) }

      p = ActivityObjectProperty.create! activity_object_id: holder.activity_object_id,
                                         property_id:        one.activity_object_id

      p.siblings.should be_blank
      p.main.should be_true

      q = ActivityObjectProperty.create! activity_object_id: holder.activity_object_id,
                                         property_id:        two.activity_object_id

      p.siblings.should include(q)
      p.reload.main.should be_true
      q.main.should be_false

      r = ActivityObjectProperty.create! activity_object_id: holder.activity_object_id,
                                         property_id:        three.activity_object_id,
                                         main:               true

      r.siblings.should include(p)
      r.siblings.should include(q)

      p.reload.main.should be_false
      q.reload.main.should be_false
      r.main.should be_true
    end
  end

  context "with main_holder_object_ids" do
    it "should be created" do
      @holder = Factory(:post)

      prop = Post.create! text: "Text",
                          author: @holder.author,
                          main_holder_object_ids: [ @holder.activity_object_id ]

      @holder.posts.should include(prop)
      @holder.main_post.should eq(prop)
    end
  end

  context "with add_holder_post_id" do
    it "should be created" do
      @holder = Factory(:post)

      prop = Post.create! text: "Text",
                          author: @holder.author,
                          add_holder_post_id: @holder.id

      @holder.posts.should include(prop)
      @holder.main_post.should eq(prop)
    end
  end
end
