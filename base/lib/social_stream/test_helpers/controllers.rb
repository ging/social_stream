module SocialStream
  module TestHelpers
    module Controllers
      # Post for PostsController
      def model_class
        @model_class ||=
          described_class.to_s.sub!("Controller", "").singularize.constantize
      end

      # :post for PostsController
      def model_sym
        @model_sym ||=
          model_class.to_s.underscore.to_sym
      end

      # :client for Site::ClientsController
      def demodulized_model_sym
        @demodulized_model_sym ||=
          model_class.to_s.demodulize.underscore.to_sym
      end

      # Factory.attributes_for(:post) for PostsController
      def model_attributes
        @model_attributes ||=
          Factory.attributes_for(model_sym)
      end

      def attributes
        { model_sym => model_attributes }
      end

      def updating_attributes
        attributes.merge({ :id => @current_model.to_param })
      end

      # Post.count
      def model_count
        model_class.count
      end

      def model_assigned_to contact, relation_ids
        model_attributes[:owner_id]  = contact.receiver.id
        model_attributes[:relation_ids] = Array(relation_ids).map(&:id)
      end

      shared_examples_for "Allow Creating" do
        it "should create" do
          count = model_count
          post :create, attributes

          resource = assigns(demodulized_model_sym)

          model_count.should eq(count + 1)
          resource.should be_valid
          response.should redirect_to(resource)
        end
      end

      shared_examples_for "Deny Creating" do
        it "should not create" do
          count = model_count
          begin
            post :create, attributes
          rescue CanCan::AccessDenied
          end

          resource = assigns(demodulized_model_sym)

          model_count.should eq(count)
          resource.should be_new_record
        end
      end

      shared_examples_for "Allow Reading" do
        it "should read" do
          get :show, :id => @current_model.to_param

          response.should be_success
        end
      end

      shared_examples_for "Deny Reading" do
        it "should not read" do
          begin
            get :show, :id => @current_model.to_param

            assert false
          rescue CanCan::AccessDenied
          end
        end
      end

      shared_examples_for "Allow Updating" do
        it "should update" do
          put :update, updating_attributes

          resource = assigns(demodulized_model_sym)

          resource.should_receive(:update_attributes).with(attributes)
          assert resource.valid?
          response.should redirect_to(resource)
        end
      end

      shared_examples_for "Deny Updating" do
        it "should not update" do
          begin
            put :update, updating_attributes
          rescue CanCan::AccessDenied
          end

          resource = assigns(demodulized_model_sym)

          resource.should_not_receive(:update_attributes)
        end
      end

      shared_examples_for "Allow Destroying" do
        it "should destroy" do
          count = model_count
          delete :destroy, :id => @current_model.to_param

          resource = assigns(demodulized_model_sym)

          model_count.should eq(count - 1)
        end
      end

      shared_examples_for "Deny Destroying" do
        it "should not destroy" do
          count = model_count
          begin
            delete :destroy, :id => @current_model.to_param
          rescue CanCan::AccessDenied
          end

          resource = assigns(demodulized_model_sym)

          model_count.should eq(count)
        end
      end

    end
  end
end
