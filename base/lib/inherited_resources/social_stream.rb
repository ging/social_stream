# Monkey path inherited_resources
#
#
# Fix https://github.com/josevalim/inherited_resources/issues/216
module InheritedResources::BaseHelpers
  private

  def resource_params
    @resource_params ||=
      build_resource_params
  end

  def build_resource_params
    rparams = [params[resource_request_name] || params[resource_instance_name] || {}]
    rparams << as_role if role_given?
    rparams
  end
end
